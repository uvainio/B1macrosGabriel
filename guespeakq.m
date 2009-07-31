function newlam = guespeak(data,axv,axh,pixaxh)

% function newlam = guespeak(data,axv,axh)
%
% NOTE: Used by macro gausmultiple
%
% Author: Ulla Vainio, ulla.vainio@helsinki.fi (Univ. of Helsinki)
%         Edited: 19.10.2004

newlam(1) = max(axv)-min(axv);
newlam(2) = (max(axh)-min(axh))/2+min(axh);
newlam(3) = (max(axh)-min(axh))/6;
newlam(4) = (data(max(pixaxh))-data(min(pixaxh)))/(max(axh)-min(axh));
newlam(5) = axv(1) - newlam(4)*axh(1);
