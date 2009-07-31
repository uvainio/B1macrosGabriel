function [Aout,Aouterr] = subdc(A1,header1,summed1,Adc,headerdc,summeddc,sens,senserr,transm)

% function [Aout,Aouterr] = subdc(A1,header1,summed1,Adc,headerdc,summeddc,sens,senserr)
%
% IN:
% A1 = matrix from which dark currect is to be subtracted
% header1 = headers of the files from which matrix A1 was obtained
% summed1 = put 1 if you haven't added the data
%           otherwise a vector of the FSNs of the added data
% Adc = matrix of dark current
% headerdc = header of dark current measurement
% summeddc = put 1 if you haven't added the dark current data
%           otherwise a vector of the FSNs of the added dark current data
% sens = sensitivity matrix of the detector, put ones(256,256) if you don't
%        have one
% senserr = error of sensitivity, put zeros(256,256) if you don't have it
%
% OUT:
% Aout = 
%      The data has been corrected for:
%      - corrected for change in primary intensity (monitor)
%      - the dark current has been subtracted
%      - corrected for detector sensitivity (divided by)
%      - corrected for transmission (divided by)
%      - normalised by pixel size
%      - corrected for detector dead time (Sum/Total)
% 
% Aouterr = the error matrix of the data
% 
% Created: 20.8.2007 Ulla Vainio, ulla.vainio@desy.de
% Edited: 2.1.2008 UV, normalisation with cm^2 to beamsize instead of mm^2
% Edited: 7.5.2008 UV, normalization changed to pixel size to mm^2,
%         this has no effect in ASAXS, but it
%         does affect the calculation of the primary intensity in absolute units
% Edited: 17.7.2009 UV, corrected the help (normalized by pixel size not by
%         beam cross section)

% Take average transmission
if(nargin < 9) % Normal case
  transm1 = getfield(header1(1),'Transm');
else % special case when using theoretical transmission given separately
    transm1 = transm;
end;
% Get anode counts, monitor counts, and measurement time of sample
an1 = getfield(header1(1),'Anode');
mo1 = getfield(header1(1),'Monitor');
meastime1 = getfield(header1(1),'MeasTime');
if(length(summed1)>1) % if matrix is from many measurements
  for(k = 2:length(summed1))
    transm1 = [transm1 getfield(header1(k),'Transm')];
    an1 = an1 + getfield(header1(k),'Anode');
    mo1 = mo1 + getfield(header1(k),'Monitor');
    meastime1 = meastime1 + getfield(header1(k),'MeasTime');
  end;
end;
transm1ave = mean(transm1);
transm1err = std(transm1);
disp(sprintf('FSN %d \tTitle %s \tEnergy %.1f \tDistance %d',getfield(header1(1),'FSN'),getfield(header1(1),'Title'),getfield(header1(1),'Energy'),getfield(header1(1),'Dist')));
disp(sprintf('Average transmission %.4f +/- %.4f',transm1ave,transm1err))

% Get anode counts, monitor counts, and measurement time of dark current
andc = getfield(headerdc(1),'Anode');
modc = getfield(headerdc(1),'Monitor');
meastimedc = getfield(headerdc(1),'MeasTime');
if(length(summeddc)>1)
  for(k = 2:length(summeddc))
    andc = andc + getfield(headerdc(k),'Anode');
    modc = modc + getfield(headerdc(k),'Monitor');
    meastimedc = meastimedc + getfield(headerdc(k),'MeasTime');
  end;
end;
% Subtracting the dark current from the monitor counts
monitor1corrected = mo1-modc*meastime1/meastimedc;

% Sum of detector counts after dark current subtraction
sumA2 = sum(sum(A1-Adc*meastime1/meastimedc));
% Error of sum of detector counts after dark current subtraction
sumA2err = sqrt(sum(sum(A1 + ... % Error of sum(sum(A1)) squared, fixed from sum(sum(sqrt)) from to this 18.5.2009 UV, thanks AW
    (meastime1/meastimedc).^2.*Adc)));
% Anode counts after dark current subtraction
anA2 = an1 - andc*meastime1/meastimedc;
% Error of anode counts
anA2err = sqrt(an1 + (meastime1/meastimedc)^2*andc);

% Subtract dark current
A2 = (A1 - Adc*meastime1/meastimedc)./sens/monitor1corrected;

disp(sprintf('Sum/Total of dark current: %.2f. Counts/s %.1f.',100*sum(sum(Adc))/andc,andc/meastimedc))
disp(sprintf('Sum/Total before dark current correction: %.2f. Counts on anode %.1f cps. Monitor %.1f cps.',100*sum(sum(A1))/an1,an1/meastime1,monitor1corrected/meastime1))
disp(sprintf('Sum/Total after dark current correction: %.2f.',100*sumA2/anA2))
errA1 = sqrt(A1);
errAdc = sqrt(Adc);

% Error propagation of  dark current subtraction
errA2 = sqrt((1./sens/monitor1corrected).^2.*errA1.^2 + ...
    (Adc.*meastime1/meastimedc./sens/monitor1corrected^2).^2*(mo1+modc*(meastime1/meastimedc)^2) + ...
    ((1./sens/monitor1corrected*meastime1/meastimedc).^2).*errAdc.^2 + ...
    ((A1 - Adc.*meastime1/meastimedc)./monitor1corrected./(sens.^2)).^2.*senserr.^2);

% Correct for lost anode counts and transmission (angle dependence of transmission
% correction is treated later)
A3 = A2*anA2/sumA2/(transm1ave);
% Error propagation of anode counts and transmission
errA3 = sqrt((anA2/sumA2/transm1ave).^2.*errA2.^2 + ...
    (A2/sumA2/transm1ave).^2.*anA2err.^2 + ...
    (A2*anA2/sumA2^2/transm1ave).^2.*sumA2err.^2); % + ...
%    (A2*anA2/sumA2/transm1ave^2).^2.*transm1err^2);

% Normalise finally also by beam size.
%BX = getfield(header1(1),'BeamsizeX'); % in mm
%BY = getfield(header1(1),'BeamsizeY'); % in mm
%Aout = A3/(BX*BY);
%Aouterr = errA3/(BX*BY);
% Normalise by pixel size
BX = getfield(header1(1),'XPixel'); % in mm
BY = getfield(header1(1),'YPixel'); % in mm
Aout = A3/(BX*BY);
Aouterr = errA3/(BX*BY);
