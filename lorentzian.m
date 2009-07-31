function [f,int,width,height] = lorentzian(lam,x)

% function [f,int,width,height] = lorentzian(lam,x)
%
% Lorentzian peaks with x + constant background.
% 
% NOTE: macro lorentzfit.m uses this.

n = length(lam);
f = 0;
j=1;
while j < n-3
   int    = lam(j);
   pos = lam(j+1);
   width = lam(j+2);
   f = f + int*0.5*width./((x-pos).^2+(0.5*width)^2)/pi;
   j = j + 3;
end;

f = f + lam(length(lam)-1)*x + lam(length(lam));
%f = f + lam(length(lam)-1)*x.^lam(length(lam)-2) + lam(length(lam));
%f = f + lam(length(lam)-1)*x.^2 + lam(length(lam));

height = 2/(pi*width);
