function [Asub,errAsub,header,injectionEB] = subtractbg(fsn1,fsndc,sens,senserr,transm)

% function [Asub,errAsub,header] = subtractbg(fsn1,fsndc,sens,senserr)
%
% Subtracts from the 2D SAXS measurement of the sample a dark current and
% the empty beam measurement and normalizes the measurement with
% transmission, monitor counts, with Sum/Total (the number of photons for
% which a position was determined compared to the number of photons detected on the
% anode of the detector) and by the sensitivity of the detector.
%
% IN:
% fsn1 = FSN(s) of the sample measurement(s), e.g. [256:500]
% fsndc = FSN(s) of dark current measurement(s)
% sens = sensitivity matrix of the detector (from makesensitivity.m)
% senserr = error of the sensitivity matrix (from makesensitivity.m)
%
% OUT:
% Asub = normalised 2D data from which dark current and empty beam
%           backgrounds have been subtracted
% errAsub = error matrix of Asub
% header = headers of the sample files with dark current FSN added
%
% Created: 5.9.2007 UV

% Read in dark current measurement file(s)
[Adc,headerdc,summeddc] = addfsns('ORG',fsndc,'.DAT');
% Read in samples
[A1,header1] = read2dB1data('ORG',fsn1,'.DAT');
sizeA1 = size(A1);
if(numel(sizeA1)<3)
    sizeA1(3) = 1; % To recover from only one FSN
end;

% Read in empty beam measurements
FSNempty = zeros(1,sizeA1(3));
for(k = 1:sizeA1(3))
   FSNempty(k) = getfield(header1(k),'FSNempty');
end;
notfound = 0;
noemptys = find(FSNempty~=0);

if(noemptys == 0)% In case background subtraction is not possible
    disp('No backround to subtract!')
    return;
end;

[Abg,headerbg,notfound] = read2dB1data('ORG',FSNempty(noemptys),'.DAT');
sizebg = size(Abg);
if(numel(sizebg)<3)
    sizebg(3) = 1; % To recover from only one FSN
end;

% Checking all empty beam measurements are found
if(notfound(1)~=0) 
   disp(sprintf('Cannot find all empty beam measurements.\nWhere is the empty FSN %d belonging to FSN %d? Stopping.',notfound(1),fsn1(find(FSNEmpty==notfound(1)))))
   return
end;

% Subtracting dark current and normalising
counter = 1;
for(k = 1:sizeA1(3))
   if(FSNempty(k)~=0)
     if(counter ==1)
        [Abg(:,:,counter),Abgerr(:,:,counter)] = subdc(Abg(:,:,counter),headerbg(counter),1,Adc,headerdc,summeddc,sens,senserr);
     elseif(getfield(headerbg(counter),'FSN')==getfield(headerbg(counter-1),'FSN'))
        Abg(:,:,counter) = Abg(:,:,counter-1); Abgerr(:,:,counter) = Abgerr(:,:,counter-1);
     end;
     if(nargin < 5) % Normal case
        [A2(:,:,counter),A2err(:,:,counter)] = subdc(A1(:,:,k),header1(k),1,Adc,headerdc,summeddc,sens,senserr);
     else % in case theoretical transmission is used
        [A2(:,:,counter),A2err(:,:,counter)] = subdc(A1(:,:,k),header1(k),1,Adc,headerdc,summeddc,sens,senserr,transm);
     end;
     header2(counter) = header1(k);
     counter = counter + 1;
   end;
end;

% Subtracting background from data
counter2 = 1;
for(k = 1:(counter-1))
   % Checking first for an injection
    if(getfield(header2(k),'Current1')>getfield(headerbg(k),'Current2'))
      disp('Possibly an injection between sample and its background:')
      getsamplenames('ORG',header2(k).FSN,'.DAT');
      getsamplenames('ORG',header2(k).FSNempty,'.DAT',1);
      disp(sprintf('Current in DORIS at the end of empty beam measurement %.2f.\nCurrent in DORIS at the beginning of sample measurement %.2f',getfield(headerbg(k),'Current2'),getfield(header2(k),'Current1')))
      injectionEB(k) = 'y';
    else
        injectionEB(k) = 'n';
    end;
      Asub(:,:,counter2) = A2(:,:,k) - Abg(:,:,k);
      errAsub(:,:,counter2) = sqrt(A2err(:,:,k).^2 + Abgerr(:,:,k).^2);
      header(counter2) = header2(k);
     % Add DC measurement FSN to header
      setfield(header(counter2),'FSNdc',fsndc);
      counter2 = counter2 + 1;
end;