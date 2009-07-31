function [mc1,mc2,angle] = Si311angleB1(energy)

% function [mc1,mc2,angle] = Si311angleB1(energy)
%
% Calculates what are the motor positions for certain energy
% on B1.
%
% IN:
% energy = energy in eV
%
% OUT:
%
% mc1 = position of first crystal motor
% mc2 = position of second crystal motor
%
% Created: 19.9.2008 Ulla Vainio (ulla.vainio@desy.de)

alfa1 = 0.005;
alfa2 = -3.1454;

d311 = 3.287251/2*0.1; % in nm
hc = 197.326960*2*pi; % From X-ray data booklet, page 5-2
% Bragg law: 2d sin (theta) = lambda
% E = hc/lambda
angle = asin(hc/energy/(2*d311))*180/pi;

mc1 = angle+alfa1;
mc2 = angle+alfa2;