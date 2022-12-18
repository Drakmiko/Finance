function [y] = getMomentum(thisPermno,thisYear,thisMonth, crsp)
  
endYear = thisYear
endMonth= thisMonth -1

if endMonth == 0
    endMonth=12
    endYear = endYear - 1
end

endPrice = crsp.adjustedPrice(crsp.year==endYear & ...
    crsp.month == endMonth & crsp.PERMNO == thisPermno)

startMonth = thisMonth
startYear = thisYear - 1

startprice = crsp.adjustedPrice(crsp.year==startYear & ...
    crsp.month == startMonth & crsp.PERMNO == thisPermno)

y = endPrice/startprice;

% NaN values for empty cells
if isempty(y) == true
    y = NaN
end
end
