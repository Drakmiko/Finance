clear
clc
%% Importing Data
crsp=readtable('testData.csv');

%% Datenum, Year, and Month
crsp.datenum = datenum(num2str(crsp.DateOfObservation),'yyyymmdd');
crsp.year = year(crsp.datenum);
crsp.month = month(crsp.datenum);

%% Calculate Momentum 

% Creating new momentum column
[n, k] = size(crsp);
crsp.momentum = NaN(n,1)

%Populating the momentum column
for i = 1:n;
    thisPermno = crsp.PERMNO(i);
    thisYear = crsp.year(i);
    thisMonth = crsp.month(i);
    crsp.momentum(i) = getMomentum(thisPermno,thisYear,thisMonth,crsp);
end

%% Momentum Returns

% Creating new momentum table 
Date = unique(crsp.DateOfObservation);
momentum = table;
momentum.datenum = datenum(num2str(Date),'yyyymmdd');
momentum.year = year(momentum.datenum);
momentum.month = month(momentum.datenum);
momentum.mom1 = NaN(size(momentum.datenum));
momentum.mom10 = NaN(size(momentum.datenum));


% Populating the momentum table
[o p] = size(momentum);
for i = 1 : o;
    year_m = momentum.year(i);
    month_m = momentum.month(i);

 % Creating the proper decile quantiles
   quantiles = quantile(crsp.momentum(crsp.year == year_m & crsp.month == month_m),9);

 % Indexing from crsp table with the momentum quantiles
   momentum.mom1(i) = mean(crsp.Returns(crsp.year == year_m & crsp.month == month_m ...
       & crsp.momentum<=quantiles(1)));
   momentum.mom1(i)=momentum.mom1(i) + 1;
   momentum.mom10(i)=mean(crsp.Returns(crsp.year == year_m & crsp.month == month_m & ...
       crsp.momentum>=quantiles(9)));
   momentum.mom10(i) = momentum.mom10(i) + 1;
   momentum.mom(i) = momentum.mom10(i)-momentum.mom1(i) + 1;
end

%% Calculate Cumulative Returns
% Changing the NaN values into 0
momentum.mom(isnan(momentum.mom))= 0;
momentum.mom10(isnan(momentum.mom10))= 0;
momentum.mom1(isnan(momentum.mom1))= 0;
momentum.date = datetime(momentum.datenum, 'ConvertFrom', 'datenum', 'Format', 'MM-yyyy')

% Cumulative Returns on the long-short momentum portfolio
momentum.mom(13)=1
momentum.mom10(13)=1
momentum.mom1(13)=1
momentum = momentum(13:end,:)
momentum.cumulativeRet = cumprod(momentum.mom);
momentum.cumulativewin = cumprod(momentum.mom10);
momentum.cumulativelose = cumprod(momentum.mom1);

% Plotting the Graph
plot(momentum.date, momentum.cumulativeRet)
hold on
plot(momentum.date, momentum.cumulativewin)
plot(momentum.date, momentum.cumulativelose)
hold off
legend("Long Short", "Winners", "Losers")
datetick("x","yyyy-mm","keeplimits")




