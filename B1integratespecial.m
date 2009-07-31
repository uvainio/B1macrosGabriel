function [qs,ints,errs] = B1integratespecial(fsn1,fsndc,sens,errorsens,orifsn,mask,distminus,energymeas,energycalib)

% [qs,ints,errs] = B1integratespecial(fsn1,fsndc,sens,errorsens,orifsn,mask,distminus,energymeas,energycalib)
%
% 1st file is subtracted as background.
% If samples were in reference sample holder put distminus = 219 (mm)
% Otherwise put 0.
%
% Created: 17.9.2007 UV
% Edited: 2.11.2007 qfrompixelsizeB1 was called with pix = [1:length(ints)]
%         corrected to [0:length(ints)]
%         In other words, the q-scale was off by one pixel.
%         Effective pixel size is also adjusted now accordingly.

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
  distance(k) = getfield(header(k),'Dist');
  transm(k) = getfield(header(k),'Transm');
end;

if(numel(orifsn)==1)
  disp(sprintf('Determining origin from file FSN %d %s',fsn1(orifsn),getfield(header(orifsn),'Title')))
  orig = [122.5 123.5]; % Initial guess.
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

counter = 1;
for(l = 2:sizeA(3))
    % Polarization factor
    Apolcor = polarizationcorrection(distance(l),pixelsize,orig(1));
% Subtracting empty beam and 
    temp = imageint((Asub(:,:,l)-Asub(:,:,1)).*Apolcor,orig,mask);
    ints(1:length(temp),counter) = temp;
    title(sprintf('FSN %d',getfield(header(l),'FSN')))
    pause  
    [temp, NI] = imageint((errAsub(:,:,l).*Apolcor).^2+(errAsub(:,:,1).*Apolcor).^2,orig, mask); 
    title(sprintf('Error matrix of FSN %d',getfield(header(l),'FSN')))
    errs(1:length(temp),counter) = temp;
    % Error propagation
    j = find(NI>0); % Don't divide by zero
    % The next statement is actually
    % the same as sqrt(errorinpixel1^2 + errorinpixel2^2 + ...)/(number of pixels summed)
    % because in imageint the vector given out is always divided by NI once
    errs(j,counter) = sqrt(errs(j,counter)./NI(j));
    % Q-scale
    [qs(:,counter),tth(:,counter)] = qfrompixelsizeB1(distance(l)-distminus,pixelsize,energyreal(l),[0:(length(ints)-1)]);
    % Correct for geometrical distortion and angle dependent absorption (for a flat sample)
    spatialcorr = geomcorrection(qs(:,counter),energyreal(l),distance(l)-distminus);
    % Gas absorption correction
    gas = gasabsorptioncorrection(energyreal(l),qs(:,counter));
    if(transm(l)<1)
      % Angle dependent transmission correction, only the angle dependent part.
      transmcorr = absorptionangledependent(tth(:,counter),transm(l));
    else % For example for the reference after the transmission is not measured..
        transmcorr = 1;
    end;
    ints(:,counter) = ints(:,counter).*spatialcorr.*transmcorr.*gas;
    errs(:,counter) = errs(:,counter).*spatialcorr.*transmcorr.*gas;
    % Writing data to files.
    writelogfile(header(l),orig,0,fsndc,energyreal(l),distance(l)-distminus,1,0,0,0,'-','-',pixelsize);
    writeintfile(qs(:,counter),ints(:,counter),errs(:,counter),header(l));
    counter = counter + 1;
end;
