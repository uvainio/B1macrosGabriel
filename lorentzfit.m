function g = lorentzfit(lam,data,dataerror,x)

% function g = lorentzfit(lam,data,dataerror,x)
%
% NOTE: Used by macro qrange.m!

data = data(:); x = x(:);
dataerror = dataerror(:);
%lam = abs(lam);

f = lorentzian(lam,x)';

f = f(:);

g = sum(((data-f)./dataerror).^2);
