function [qout,intout,errout,header,errmult,energyreal,distance] = B1normint1sect(fsn1,thicknesses,orifsn,fsndc,sens,errorsens,mask,energymeas,energycalib,fii1,fii2,fii3,fii4,orig)

% [qout,intout,errout,header] = B1normint1sect(fsn1,thicknesses,orifsn,fsndc,sens,errorsens,orifsn,mask,energymeas,energycalib,fii1,fii2,fii3,fii4,orig)
%
% IN:
% thicknesses = either one thickness in cm or a structure containing
% thicknesses of all samples.
% 
% OUT:
%
% qs = q-scales of intensities
% ints = intensities corresponding to fsn1s (excluding empty beams)
%        normalised to absolute intensities (1/cm)
% errs = errors of intensities
% header = header data of the corresponding intensities (first is glassy carbon)
% errmult = error of the absolute intensity scale calibration
%           multiplication factor
% energyreal = calibrated energy of the measured sample
% distance = measurement distance
%
% Created: 10.9.2007 UV
% Edited: R^2 correction to intensities 30.9.2007 UV
% Edited: 2.11.2007 qfrompixelsizeB1 was called with pix = [1:length(ints)]
%         corrected to [0:length(ints)]
%         In other words, the q-scale was off by one pixel.
% Edited: 27.11.2007 In titles spaces are replaced by "_" sign
% Edited: 2.1.2008 Added gasabsorption correction
% Edited: 7.5.2008 saving the angle corrected data of glassy carbons

pixelsize = 0.8; % mm
distancefromreferencetosample = 219; % mm, distance from reference sample holder to normal sample holder

if(isstruct(thicknesses)) % This property does not work yet. 
  % Contains or should contain structure variable 'thicknesses':
  sizethick = size(thicknesses);
  flagthick = 0; % Flag for thickness found from the struct thicknesses
else
    thick = thicknesses;
    flagthick = 1; % Flag for thickness found from the struct thicknesses or not
    disp(sprintf('Using thickness %f cm for all samples except references.',thick))
end;

[ints,errs,header,ori,injectionEB,ints1,ints2,ints3,ints4,errs1,errs2,errs3,errs4] = B1integratesect(fsn1,fsndc,sens,errorsens,orifsn,mask,fii1,fii2,fii3,fii4,orig);

if(numel(energycalib)~=numel(energymeas) | numel(energycalib)<2)
   disp('STOPPING. Variables energycalib and energymeas should contain equal amount of\npoints and at least two points to be able to make the energy calibration.')
   return
end;    

sizeints = size(ints);
counterref = 0;
for(k = 1:sizeints(2))
% Interpolating the energy to the real energy scale
  energy1 = getfield(header(k),'Energy');
  energyreal(k) = interp1(energymeas,energycalib,energy1,'spline','extrap');
  transm(k) = getfield(header(k),'Transm');
  % Correcting for the distance of the reference holder
  if(strcmp(getfield(header(k),'Title'),'Reference_on_GC_holder_before_sample_sequence'))
     distance(k) = getfield(header(k),'Dist')-distancefromreferencetosample;
     referencemeas = getfield(header(k),'PosRef');
     referencesfsn = getfield(header(k),'FSN');
     referencenumber = k;
     counterref = counterref + 1;
     currentGC = getfield(header(k),'Current2'); % DORIS current end of measurement
  elseif(strcmp(getfield(header(k),'Title'),'Reference_on_GC_holder_after_sample_sequence')) % For example AgBeh
     distance(k) = getfield(header(k),'Dist')-distancefromreferencetosample;
     current(k) = getfield(header(k),'Current2');
  else
     distance(k) = getfield(header(k),'Dist');
     current(k) = getfield(header(k),'Current2');
  end;
  [qs(:,k),tths(:,k)] = qfrompixelsizeB1(distance(k),pixelsize,energyreal(k),[0:(length(ints)-1)]);
end;

if(counterref == 1) % Found at least one reference measurement
% Positions of reference samples in the reference sample holder.
posref155 = 129;
posref500 = 139;
posref1000 = 159;
%posref155 = 130.4; % old positions
%posref500 = 140.4;
%posref1000 = 160.4;
 if(round(referencemeas)==round(posref155))
     load calibrationfiles\GC155.dat;
     GCdata(:,1:3) = GC155; thickGC = 143*10^-4; % in cm, According to measurements in autumn 2007
     % Assumption has been made that the density of all samples is the same
 elseif(round(referencemeas)==round(posref500))
     load calibrationfiles\GC500.dat;
     GCdata(:,1:3) = GC500; thickGC = 508*10^-4;% in cm
 elseif(round(referencemeas)==round(posref1000))
     load calibrationfiles\GC1000.dat;
     GCdata(:,1:3) = GC1000; thickGC = 992*10^-4; % in cm
 end;
end;
%     load GC500.dat;
%     GCdata(:,1:3) = GC500; thickGC = 508*10^-4;% in cm
disp(sprintf('FSN %d: Using GLASSY CARBON REFERENCE with nominal thickness %.f micrometers.',referencesfsn,thickGC*10^4));

% Binning reference data and comparing to reference measurements done
% earlier
maxpix = min(find(ints(45:end,referencenumber)==0)); % Finding the last zeros and taking the lowest of them
if(GCdata(end,1)<qs(maxpix,referencenumber)) % If measurement range exceed that of saved in GC file
      lq = GCdata(end,1); % Last q-value
      GCint = GCdata(:,:);
else
      lq = qs(maxpix,referencenumber);
      GCint = GCdata(1:max(find(GCdata(:,1)<lq)),:); % Shorten the reference data
      lq = GCint(end,1);
end;
minpix = max(find(ints(1:30,referencenumber)==0))+2;
if(GCint(1,1)>qs(minpix,referencenumber))
      fq = GCint(1,1); % First q-value
else
      fq = qs(minpix,referencenumber);
      GCint2 = GCint(min(find(GCint(:,1)>fq)):end,:); % Shorten the reference data
      clear GCint; GCint = GCint2;
      fq = GCint(1,1);
end;
points = length(GCint(:,1)); % Number of intervals
% Geometrical correction for detector flatness (includes R^2 correction).
spatialcorr = geomcorrection(qs(:,referencenumber),energyreal(referencenumber),distance(referencenumber));
% Angle dependent transmission correction, 2.1.2008 added gas absorption
% correction
transmcorr = absorptionangledependent(tths(:,referencenumber),transm(referencenumber)).*gasabsorptioncorrection(energyreal(referencenumber),qs(:,referencenumber));
% Binning the now measured data to same intervals as the reference data
% Also divide by thickness of the sample ------ in binning points -1 was
% changed to points on April 4th 2008.
[qbinGC,intsbinGC,errsbinGC] = tobins(qs(:,referencenumber),ints(:,referencenumber)/thickGC.*spatialcorr.*transmcorr,errs(:,referencenumber)/thickGC.*spatialcorr.*transmcorr,points,fq,lq);
% Integrate (trapezoidal) over the area to get a multiplication factor for the
% intensitities to absolute scale.
ll = 2:(points-1);
mult = trapz(GCint(ll,2))/trapz(intsbinGC(ll));
% Error estimation:
errmult = trapz(GCint(ll,2)+GCint(ll,3))/trapz(intsbinGC(ll,1)-errsbinGC(ll,1)) - mult;
writelogfile(header(referencenumber),ori,thickGC,fsndc,energyreal(referencenumber),distance(referencenumber),mult,errmult,0,thickGC,'n',injectionEB(k),pixelsize);
%writeintfile(qs(:,referencenumber),mult*ints(:,referencenumber)*distance(referencenumber)^2/thickGC,mult*errs(:,referencenumber)*distance(referencenumber)^2/thickGC,header(:,referencenumber));
% Saving the angle corrected data instead, starting 7.5.2008
writeintfile(qs(:,referencenumber),mult*ints(:,referencenumber)/thickGC.*spatialcorr.*transmcorr,mult*errs(:,referencenumber)/thickGC.*spatialcorr.*transmcorr,header(:,referencenumber));

plot(qbinGC(ll),intsbinGC(ll,referencenumber)*mult,'.',GCint(ll,1),GCint(ll,2),'o');
xlabel(sprintf('q (1/%c)',197));
ylabel('Intensity (1/cm)');
legend('Your reference','Calibrated reference')
title(sprintf('Reference FSN %d multiplied by %.2e, error percentage %.2f\n',referencesfsn,mult,100*errmult/mult))
pause

% Normalise to 1/cm

counter = 1;
for(k = 1:sizeints(2))
  if(k ~= referencenumber)
    if(isstruct(thicknesses)) % If thicknesses are given in file       
      if(isfield(thicknesses,header(k).Title))
          thick = getfield(thicknesses,header(k).Title);
          disp(sprintf('Using thickness %f cm for sample %s',thick,header(k).Title));
          flagthick = 1; % Found thickness for this sample
      end;
    end;
    if(flagthick) % Make correction to absolute intensities if thickness was found.
% Sample thickness -(10*thick/2) was taken into account in sample-to-detector distance
% when calculating the q-scale, removed 27.11.2007:
       [qout(:,counter),tthout(:,counter)] = qfrompixelsizeB1(distance(k),pixelsize,energyreal(k),[1:length(ints)]);
       [qout1(:,counter),tthout1(:,counter)] = qfrompixelsizeB1(distance(k),pixelsize,energyreal(k),[1:length(ints1)]);
       [qout2(:,counter),tthout2(:,counter)] = qfrompixelsizeB1(distance(k),pixelsize,energyreal(k),[1:length(ints2)]);
       [qout3(:,counter),tthout3(:,counter)] = qfrompixelsizeB1(distance(k),pixelsize,energyreal(k),[1:length(ints3)]);
       [qout4(:,counter),tthout4(:,counter)] = qfrompixelsizeB1(distance(k),pixelsize,energyreal(k),[1:length(ints4)]);
% Geometrical correction
       spatialcorr = geomcorrection(qout(:,counter),energyreal(k),distance(k)); % energyreal(counter) to energyreal(k) 12.11.2007
% Angle dependent transmission correction, 2.1.2008 added gas absorption
% correction
       transmcorr = absorptionangledependent(tthout(:,counter),transm(k)).*gasabsorptioncorrection(energyreal(k),qout(:,counter)); % transm(counter) to transm(k) on 12.11.2007
       intout(:,counter) = mult*ints(:,k)/thick.*spatialcorr.*transmcorr;
       errout(:,counter) = sqrt((mult*errs(:,k)).^2+(errmult*ints(:,k)).^2)/thick.*spatialcorr.*transmcorr;       
       intout1(:,counter) = mult*ints1(:,k)/thick.*spatialcorr(1:length(qout1)).*transmcorr(1:length(qout1));
       errout1(:,counter) = sqrt((mult*errs1(:,k)).^2+(errmult*ints1(:,k)).^2)/thick.*spatialcorr(1:length(qout1)).*transmcorr(1:length(qout1));       
       intout2(:,counter) = mult*ints2(:,k)/thick.*spatialcorr(1:length(qout2)).*transmcorr(1:length(qout2));
       errout2(:,counter) = sqrt((mult*errs2(:,k)).^2+(errmult*ints2(:,k)).^2)/thick.*spatialcorr(1:length(qout2)).*transmcorr(1:length(qout2));       
       intout3(:,counter) = mult*ints3(:,k)/thick.*spatialcorr(1:length(qout3)).*transmcorr(1:length(qout3));
       errout3(:,counter) = sqrt((mult*errs3(:,k)).^2+(errmult*ints3(:,k)).^2)/thick.*spatialcorr(1:length(qout3)).*transmcorr(1:length(qout3));       
       intout4(:,counter) = mult*ints4(:,k)/thick.*spatialcorr(1:length(qout4)).*transmcorr(1:length(qout4));
       errout4(:,counter) = sqrt((mult*errs4(:,k)).^2+(errmult*ints4(:,k)).^2)/thick.*spatialcorr(1:length(qout4)).*transmcorr(1:length(qout4));       
       if((current(k)>currentGC) && (k > referencenumber))
            injectionGC = 'y';
       elseif((current(k)<currentGC) && (k < referencenumber))
            injectionGC == 'y'
       else
            injectionGC = 'n'; % (although not necessarily!)
       end;
       writelogfilesect(header(k),ori,thick,fsndc,energyreal(k),distance(k),mult,errmult,referencesfsn,thickGC,injectionGC,injectionEB(k),pixelsize,fii1,fii2,fii3,fii4);
       writeintfile(qout(:,counter),intout(:,counter),errout(:,counter),header(k));
       writeintfilesect(qout1(:,counter),intout1(:,counter),errout1(:,counter),header(k),1);
       writeintfilesect(qout2(:,counter),intout2(:,counter),errout2(:,counter),header(k),2);
       writeintfilesect(qout3(:,counter),intout3(:,counter),errout3(:,counter),header(k),3);
       writeintfilesect(qout4(:,counter),intout4(:,counter),errout4(:,counter),header(k),4);
       counter = counter + 1;
       if(isstruct(thicknesses)) % If thicknesses are given in a structure
         flagthick = 0; % Resetting flag.
       end;
    else
         disp(sprintf('Did not find thickness for sample %s. Stopping.',getfield(header(k),'Title')))
         return;
    end;
  end;
end;