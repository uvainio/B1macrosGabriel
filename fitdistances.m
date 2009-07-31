function [f,q] = fitdistances(lam,pix,Energy,s)

% function [f,q] = fitpixelsizeanddistance(lam,pix,Energy,s)
%
%
% Created 11.10.2007 UV

dist = lam; % distances
hc = 2*pi*1973.269601;

q = 4*pi/hc*sin(0.5*atan(s*pix./dist)).*Energy;

f = sum((q - 2*pi/58.43*ones(size(q))).^2);