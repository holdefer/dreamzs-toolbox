function [propChild] = setToBounds(propChild,dreamPar)
% Checks the bounds of the parameters

pointCount = size(propChild,1);

rangeMin = repmat(dreamPar.propChild,pointCount,1); 
rangeMax = repmat(dreamPar.rangeMax,pointCount,1);

% Check whether the points are within bounds and, if not, set them
% exactly on the bounds
[outBoundIdx] = find(propChild<rangeMin);
propChild(outBoundIdx)= rangeMin(outBoundIdx); % set to min range value

[outBoundIdx] = find(propChild>rangeMax); 
propChild(outBoundIdx)= rangeMax(outBoundIdx); % set to max range value