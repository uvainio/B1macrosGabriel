function B1integrateall(fsn1,fsndc,sens,errorsens,orifsn,mask,distminus,energymeas,energycalib)

% function B1integrateall(fsn1,fsndc,sens,errorsens,orifsn,mask,distminus,energymeas,energycalib)
%
% Finds automatically empty beam and reference measurements and the samples
% related to those measurements and integrates, subtract dark current,
% divides by detector sensitivity, angle dependent transmission, absorption due
% to air and windows in the beam path and for geometrical distortion
% Finally the matrices are integrated to get 1d patterns.
%
% So no background subtraction or absolute intensity normalization!
%
% IN:
%
% fsn1 = all FSNs that you want to analyse (including empty beams
%        and references)
% fsndc = FSN of the dark current measurement
% orifsn = which measurement counting from the empty beam (1) is the
%          measurement from which the center of the beam is to be
%          determined from, use 1 for glassy carbon before measurement
%          sequence or the origin in format [x y]
% sens = sensitivity matrix of the detector
% errorsens = error of the sensitivity matrix
% mask = mask to mask out the center area, detector edges and bad spots
%        caused by for example reflections form beamstop
% energymeas = two or more measured energies in a vector
%             (1st inflection points of foils)
% energycalib = the true energies corresponding to the measured 1st
%               inflection points (for example from Kraft et al. 1996)
% subfiletitle = title of the subtracted measurement, e.g. 'Empty beam'
%
% OUT:
%
% Saved files:
%
% intnormFSN.dat has three columns in which there are the q-scale,
%                intensity in relative units and the error of the intensity,
%                likewise in the same units as intensity
%
% Created 5.11.2007 UV (ulla.vainio@desy.de)

% Finding the empty beams from fsn1s

maxpix = 170; % Vectors will be of this length to be sure that they fit
pixelsize = 0.8;

[A1,header] = read2dB1data('ORG',fsn1,'.dat');
[Adc,headerdc] = read2dB1data('ORG',fsndc,'.dat');

sizeA = size(A1);
if(numel(sizeA)==2) % If only one matrix
   sizeA(3) = 1;
end;

for(k = 1:sizeA(3)) % Subtracting dark current
  [temp,errtemp] = subdc(A1(:,:,k),header(k),1,Adc,headerdc,1,sens,errorsens);
  Asub(:,:,k) = temp; errAsub(:,:,k) = errtemp;
  % Interpolating the energy to the real energy scale
  energy1 = getfield(header(k),'Energy');
  energyreal(k) = interp1(energymeas,energycalib,energy1,'spline','extrap');
  distance(k) = getfield(header(k),'Dist')-distminus;
  transm(k) = getfield(header(k),'Transm');
end;

if(numel(orifsn)==1)
  disp(sprintf('Determining origin from file FSN %d %s',fsn1(orifsn),getfield(header(orifsn),'Title')))
  orig = [135.5 120.5]; % Initial guess.
  % orig = [160 123];
  ll = [30:120];
  for(k = 1:3)
    orig = fminsearch(@agbeori,orig,[],Asub(:,:,orifsn),mask,ll);
  end;
  disp(sprintf('Determined origin to be %.2f %.2f.',orig(1),orig(2)))
else
    orig = orifsn; % If you give the origin in advance in format [x y]
    orifsn = 2;
    ll = [30:120];
end;
  fi = [35 55];
  c1 = sectint(Asub(:,:,orifsn),fi,orig,mask); 
  c2 = sectint(Asub(:,:,orifsn),fi+90,orig,mask); 
  c3 = sectint(Asub(:,:,orifsn),fi+180,orig,mask); 
  c4 = sectint(Asub(:,:,orifsn),fi+270,orig,mask);
  hold off
  plot(c1,'-b'); hold on; plot(c2,'r'); plot(c3,'.b'); plot(c4,'.r');
 legend(sprintf('%d - %d degrees',fi(1),fi(2)),'first + 90 degrees','first + 180 degrees','first + 270 degrees')
  plot([1 1]*ll(1),[min(c1) max(c1)],'--k',[1 1]*ll(end),[min(c1) max(c1)],'--k'); hold off
  xlabel('Pixel')
  ylabel('Intensity (arb. units)')
  pause

disp('Integrating data. Press Return after inspecting the image.')
ints = zeros(maxpix,sizeA(3)-1);
errs = zeros(maxpix,sizeA(3)-1);

for(l = 1:sizeA(3))
    % Polarization factor
    Apolcor = polarizationcorrection(distance(l),pixelsize,orig(1));
    temp = imageint(Asub(:,:,l).*Apolcor,orig,mask);
    ints(1:length(temp),l) = temp;
    title(sprintf('FSN %d',getfield(header(l),'FSN')))
    pause  
    [temp, NI] = imageint((errAsub(:,:,l).*Apolcor).^2,orig, mask); 
    title(sprintf('Error matrix of FSN %d',getfield(header(l),'FSN')))
    errs(1:length(temp),l) = temp;
    % Error propagation
    j = find(NI>0); % Don't divide by zero
    % The next statement is actually
    % the same as sqrt(errorinpixel1^2 + errorinpixel2^2 + ...)/(number of pixels summed)
    % because in imageint the vector given out is always divided by NI once
    errs(j,l) = sqrt(errs(j,l)./NI(j));
    % Q-scale
    [qs(:,l),tth(:,l)] = qfrompixelsizeB1(distance(l),pixelsize,energyreal(l),[0:(length(ints)-1)]);
    % Correct for geometrical distortion and angle dependent absorption (for a flat sample)
    spatialcorr = geomcorrection(qs(:,l),energyreal(l),distance(l));
    % Gas absorption correction
    gas = gasabsorptioncorrection(energyreal(l),qs(:,l));
    % Angle dependent transmission correction, only the angle dependent part.
    transmcorr = absorptionangledependent(tth(:,l),transm(l));
    ints(:,l) = ints(:,l).*spatialcorr.*transmcorr.*gas;
    errs(:,l) = errs(:,l).*spatialcorr.*transmcorr.*gas;
    % Writing data to files.
    writelogfile(header(l),orig,0,fsndc,energyreal(l),distance(l),1,0,0,0,'-','-',pixelsize);
    writeintfile(qs(:,l),ints(:,l),errs(:,l),header(l));
end;
