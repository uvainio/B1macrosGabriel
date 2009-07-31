function [f,q] = fitpixelsizeanddistance(lam,pix,dist,Energy)

% function f = fitpixelsizeanddistance(lam,pix,dist,Energy)
%
%
% Created 11.10.2007 UV

s = lam(1); % pixel size
d0 = lam(2); % Distance error
hc = 2*pi*1973.269601;

q = 4*pi/hc*sin(0.5*atan(s*pix./(d0 + dist))).*Energy;

f = sum((q - 2*pi/58.43*ones(size(q))).^2);