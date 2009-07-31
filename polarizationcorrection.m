function [Aout,polcor] = polarizationcorrection(distance,pixelsize,orix,oriy)

% function Aout = polarizationcorrection(distance,pixelsize,orix,oriy)
%
% Corrects for the polarization effects in the scattering, taking
% into account that the radiation is linearly polarised
% on the sample. Acorrected = Ameasured.*Aout
%
% Created 12.10.2007 UV

pix = [1:256]; % NUmber of pixels in x-direction
xdist = round(abs(pixelsize*(pix - orix))); % Distance in x-direction
beta = atan(xdist/distance); % Angles in radians
beta = beta(:); % Make it a column vector

Aout = ones(256,256);
for(k = 1:256)
  Aout(:,k) = Aout(256,k)./cos(beta).^2; % Polarization correction cos^2
end;

if(nargin > 3)
  polcor = imageint(Aout,[orix oriy]);
end;