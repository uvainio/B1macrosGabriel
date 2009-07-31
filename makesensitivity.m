function [sens,errorsens,old] = makesensitivity(fsn1,fsn2,fsnend,fsnDC,energymeas,energycalib,energyfluorescence,orix,oriy)

% function [sens,errorsens] = makesensitivity(fsn1,fsn2,fsnend,fsnDC,energymeas,energycalib,energyfluorescence,orix,oriy)
%
% IN:
% fsn1 = file sequence number for first measurement of foil at energy E1
% fsn2 = file sequence number for first measurement of foil at energy E2
% fsnend = last file sequence number in the sensitivity measurement
%          series 
% fsnDC = file sequence numbers of a dark current measurements, e.g. [3 35]
% origx and origy are the center positions of beamstop
%
% USAGE:
%        e.g. sens = makesensitivity(2780,2783,2850,2430);
%
% OUT:
% sens = the sensitivity matrix of the 2d detector
%        by which all measured data should be divided by
%        The matrix is normalised to 1 on the average
%
% Created 13.8.2007 Ulla Vainio, ulla.vainio@desy.de
% 11.10.2007 Added angle dependent transmission correction and
% correction for geometrical distortion (for the fluoresence energy)

%pixelsize = 0.793;
pixelsize = 0.8;

% Sum the first foil measurements
disp('Summing foil measurements at E1.');
[A1,header1,summed1] = addfsns('ORG',[fsn1:fsnend],'.dat'); 
% Sum the second foil measurements
disp('Summing foil measurements at E2.');
[A2,header2,summed2] = addfsns('ORG',[fsn2:fsnend],'.dat'); 

% The empty measurements for these measurements
FSNempty1 = getfield(header1(1),'FSNempty');
% Sum empty beam measurements
[EB1,headerEB1,summedEB1] = addfsns('ORG',[FSNempty1:fsnend],'.dat');
FSNempty2 = getfield(header2(1),'FSNempty');
% Sum empty beam measurements
[EB2,headerEB2,summedEB2] = addfsns('ORG',[FSNempty2:fsnend],'.dat');

% Load dark current
disp('Loading dark current measurement(s).')
if(length(fsnDC>1))
   [Adc,headerdc,summeddc] = addfsns('ORG',fsnDC,'.dat'); 
else
   [Adc,headerdc] = read2dB1data('ORG',fsnDC,'.dat');
   summeddc = 1;
end;

% Subtract dark current and normalise measurements
disp('Subtracting dark current from foil measurements and empty beam measurements.')
[B1,errB1] = subdc(A1,header1,summed1,Adc,headerdc,summeddc,ones(256,256),zeros(256,256));
[B2,errB2] = subdc(A2,header2,summed2,Adc,headerdc,summeddc,ones(256,256),zeros(256,256));
[EmptyB1,errEmptyB1] = subdc(EB1,headerEB1,summedEB1,Adc,headerdc,summeddc,ones(256,256),zeros(256,256));
[EmptyB2,errEmptyB2] = subdc(EB2,headerEB2,summedEB2,Adc,headerdc,summeddc,ones(256,256),zeros(256,256));

if(getfield(header1(1),'Energy') > getfield(header2(1),'Energy'))
   Babove = B1; errBabove = errB1; Emptyabove = EmptyB1; errEmptyabove = errEmptyB1;
   headerabove = header1;
   Bbelow = B2; errBbelow = errB2; Emptybelow = EmptyB2; errEmptybelow = errEmptyB2;
   headerbelow = header2;
   summedbelow = summed2;    summedabove = summed1;
else
   Babove = B2; errBabove = errB2; Emptyabove = EmptyB2; errEmptyabove = errEmptyB2;
   headerabove = header2;
   Bbelow = B1; errBbelow = errB1; Emptybelow = EmptyB1; errEmptybelow = errEmptyB1;
   headerbelow = header1;
   summedbelow = summed1;    summedabove = summed2;
end;
% Correct for the detector flatness. Fluorescence is not as strong at the
% edges.
% Approximately the energy.
energy1 = getfield(headerabove(1),'Energy');
energyabove = interp1(energymeas,energycalib,energy1,'spline');
energy2 = getfield(headerbelow(1),'Energy');
energybelow = interp1(energymeas,energycalib,energy2,'spline');

[qabove,tthabove] = qfrompixelsizeB1(getfield(headerabove(1),'Dist'),pixelsize,energyabove,[1:256]);
[qbelow,tthbelow] = qfrompixelsizeB1(getfield(headerbelow(1),'Dist'),pixelsize,energybelow,[1:256]);
% Correct for transmission of foil and subtract empty beam
transmabove = headerabove(1).Transm;
for(k = 2:length(summedabove))
   transmbove = [transmabove headerabove(k).Transm];
end;
transmcorr = absorptionangledependent(tthabove,mean(transmbove))/mean(transmbove);
for(k = 1:256)
  for(l = 1:256)
      C1(k,l) = (Babove(k,l)-Emptyabove(k,l))*transmcorr(1+round(sqrt((k-orix)^2+(l-oriy)^2)));
      % Approximation of error propagation (error of transmission is not fully transmitted)
      errC1(k,l) = sqrt(errBabove(k,l).^2+ errEmptyabove(k,l).^2)*(transmcorr(1+round(sqrt((k-orix)^2+(l-oriy)^2))));
  end;
end;
transmbelow = headerbelow(1).Transm;
for(k = 2:length(summedbelow))
   transmbelow = [transmbelow headerbelow(k).Transm];
end;
transmcorr = absorptionangledependent(tthbelow,mean(transmbelow))/mean(transmbelow);
for(k = 1:256)
  for(l = 1:256)
      C2(k,l) = (Bbelow(k,l)-Emptybelow(k,l))*transmcorr(1+round(sqrt((k-orix)^2+(l-oriy)^2)));
      % Approximation of error propagation (error of transmission is not fully transmitted)
      errC2(k,l) = sqrt(errBbelow(k,l).^2+errEmptybelow(k,l).^2)*(transmcorr(1+round(sqrt((k-orix)^2+(l-oriy)^2))));
  end;
end;
% Subtract below edge from above edge and correct the fluorescence for spatial disortion
C = C1 - 1.4*C2; % 20.2.2009 Correction factor ~ 2.5??
% Geometrical correction, cos(2theta)^3, removed 27.11.2008
%corgeom = 1./(cos(tthabove*pi/180).^3); % tth should be the same independent of energy
% Gas & window absorption correction
cor = gasabsorptioncorrection(energyfluorescence,qabove);
for(k = 1:256)
    for(l = 1:256)
%        C(k,l) = C(k,l)*corgeom(1+round(sqrt((k-orix)^2+(l-oriy)^2)))*cor(1+round(sqrt((k-orix)^2+(l-oriy)^2)));
%        Cerr(k,l) = sqrt(errC1(k,l).^2 + errC2(k,l).^2)*corgeom(1+round(sqrt((k-orix)^2+(l-oriy)^2)))*cor(1+round(sqrt((k-orix)^2+(l-oriy)^2)));
        C(k,l) = C(k,l)*cor(1+round(sqrt((k-orix)^2+(l-oriy)^2)));
        Cerr(k,l) = sqrt(errC1(k,l).^2 + errC2(k,l).^2)*cor(1+round(sqrt((k-orix)^2+(l-oriy)^2)));
    end;
end;

% Make mask for areas that are not included in the sensitivity
mask = makemask(ones(size(C)),C);
C = (1-mask).*C;

cc = imageint(C,[orix oriy],mask);
sens = C/mean(cc(70:120)); % Normalising to 1
errorsens = Cerr/mean(cc(70:120));
%old = (B1-EmptyB1)-(B2-EmptyB2);

% Taking care of zeros
for(k = 1:256)
    for(l = 1:256)
        if(sens(k,l)==0)
            sens(k,l) = 1;
            errorsens(k,l) = 0;
        end;
    end;
end;
% Setting the outside to 1
sens(1:22,1:256) = 1;
sens(1:256,1:20) = 1;
sens(234:256,1:256) = 1;
sens(1:256,236:256) = 1;

% Setting beamstop position to 1
%if(nargin>6)
%  for(k = 1:256)
%   for(l = 1:256)
%      if((k-orix)^2+(l-oriy)^2<ring^2)
%          sens(k,l) = 1;
%      end;
%   end;
%  end;
%end;

imagesc(sens);colorbar
axis equal