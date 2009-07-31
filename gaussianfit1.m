function g = gaussianfit1(lam,data,dataerror,x)

% function g = gaussianfit1(lam,data,dataerror,x)
%
% Created 4.10.2007 Ulla Vainio

data = data(:); x = x(:);
dataerror = dataerror(:);

f = gaussianline(lam,x);

f = f(:);

g = sum(abs((data-f)./dataerror).^2);
