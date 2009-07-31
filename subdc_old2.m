function [Aout,Aouterr] = subdc(A1,header1,summed1,Adc,headerdc,summeddc,sens,senserr)

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
% A2 = 
%      The data has been corrected for:
%      - corrected for change in primary intensity (monitor)
%      - the dark current has been subtracted
%      - corrected for detector sensitivity (divided by)
%      - corrected for transmission (divided by)
%      - normalised by beam cross section which is obtained from
%        width of slit 2 (divided by)
% 
% A2err = the error matrix of the data
% 
% Created: 20.8.2007 Ulla Vainio, ulla.vainio@desy.de

% Take average transmission
transm1 = getfield(header1(1),'Transm');
% Get anode counts, monitor counts, and measurement time of sample
an1 = getfield(header1(1),'Anode');
mo1 = getfield(header1(1),'Monitor');
meastime1 = getfield(header1(1),'MeasTime');
if(length(summed1)>1) % if matrix is only from one measurement
  for(k = 2:length(summed1))
    transm1 = [transm1 getfield(header1(k),'Transm')];
    an1 = an1 + getfield(header1(k),'Anode');
    mo1 = mo1 + getfield(header1(k),'Monitor');
    meastime1 = meastime1 + getfield(header1(k),'MeasTime');
  end;
end;
transm1ave = mean(transm1);
transm1err = std(transm1);
disp(sprintf('Title %s:',getfield(header1(1),'Title')));
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
sumA2 = sum(sum((A1-Adc*meastime1/meastimedc)./sens));
% Error of sum of detector counts after dark current subtraction
sumA2err = sum(sum(sqrt(A1./(sens.^2) + ... % Error of sum(sum(A1)) squared
    (meastime1/meastimedc./sens).^2.*Adc + ...
    (Adc*meastime1/meastimedc./(sens.^2)).^2.*senserr.^2)));

% Anode counts after dark current subtraction
anA2 = an1 - andc*meastime1/meastimedc;
% Error of anode counts
anA2err = sqrt(an1 + (meastime1/meastimedc)^2*andc);

% Subtract dark current
A2 = (A1 - Adc*meastime1/meastimedc)./sens/monitor1corrected;

disp(sprintf('Sum/Total before sensitivity and dark current correction: %.2f.',100*sum(sum(A1))/an1))
disp(sprintf('Sum/Total after sensitivity and dark current correction: %.2f.',100*sumA2/anA2))
errA1 = sqrt(A1);
errAdc = sqrt(Adc);

% Error propagation of  dark current subtraction
errA2 = sqrt((1./sens/monitor1corrected).^2.*errA1.^2 + ...
    (Adc.*meastime1/meastimedc./sens/monitor1corrected^2).^2*(mo1+modc*(meastime1/meastimedc)^2) + ...
    ((1./sens/monitor1corrected*meastime1/meastimedc).^2).*errAdc.^2 + ...
    ((A1 - Adc.*meastime1/meastimedc)./monitor1corrected./(sens.^2)).^2.*senserr.^2);

% Correct for lost anode counts and transmission
A3 = A2*anA2/sumA2/transm1ave;
% Error propagation of anode counts and transmission
errA3 = sqrt((anA2/sumA2/transm1ave).^2.*errA2.^2 + ...
    (A2/sumA2/transm1ave).^2.*anA2err.^2+ ...
    (A2*anA2/sumA2^2/transm1ave).^2.*sumA2err.^2 + ...
    (A2*anA2/sumA2/transm1ave^2).^2.*transm1err^2);

% Normalise finally also by beam size.
BX = getfield(header1(1),'BeamsizeX'); % in mm
BY = getfield(header1(1),'BeamsizeY'); % in mm
Aout = A3/(BX*BY);
Aouterr = errA3/(BX*BY);
