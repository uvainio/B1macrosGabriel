function [ints,errs,header,orig,injectionEB] = B1integrate(fsn1,fsndc,sens,errorsens,orifsn,mask,orig,transm)

% [ints,errs,header,injectionEB] = B1integrate(fsn1,fsndc,sens,errorsens,orifsn,mask)
% 
%
% injectionEB is 'y' if injection was between sample measurement and
%           empty beam measurement, otherwise it is 'n'
% injectionGC is 'y' if injection was between sample and glassy carbon
%           measurement, otherwise it is 'n'
%
% Created: 10.9.2007 UV
% Edited: 17.9.2007 UV Bug in error calculations for others than the first
% file.
% Edited: 27.11.2007 Changed naming system in titles, space replaced by "_"

maxpix = 250; % Vectors will be of this length to be sure that they fit
pixelsize = 0.798; % Is not used for q-range calibration, only polarization correction
distancetoreference = 219;

if(nargin < 8)
  [Asub,errAsub,header,injectionEB] = subtractbg(fsn1,fsndc,sens,errorsens);
else % Special case if theoretical transmission is used
  [Asub,errAsub,header,injectionEB] = subtractbg(fsn1,fsndc,sens,errorsens,transm);
end;

sizeA = size(Asub);
if(numel(sizeA)==2) % If only one matrix
   sizeA(3) = 1;
end;

%for(k = 1:sizeA(3)) % Saving 2d data
%   savefile = sprintf('ORG%05d.asc',header(k).FSN);
%   Asubtemp = Asub(:,:,k);
%   map = colormap;
%   save(savefile,'Asubtemp','-ASCII');
%   imwrite(im2uint16(mat2gray(Asubtemp+1)),sprintf('ORG%05d.tif',header(k).FSN),'TIFF');  
%   savefile = ['ERR' num2str(header(k).FSN) '.asc'];
%   errAsubtemp = errAsub(:,:,k);
%   save(savefile,'errAsubtemp','-ASCII');
%end;

if(numel(orifsn)==1)
  disp(sprintf('Determining origin from file FSN %d %s',header(orifsn).FSN,getfield(header(orifsn),'Title')))
  if(nargin < 7) % Initial guess for origin is optional.
    orig = [122 123.5]; % Initial guess.
  end;
  ll = [20:130];
  for(k = 1:3)
    orig = fminsearch(@agbeori,orig,[],Asub(:,:,orifsn),mask,ll);
  end;
  disp(sprintf('Determined origin to be %.2f %.2f.',orig(1),orig(2)))
else
    orig = orifsn; % If you give the origin in advance in format [x y]
    orifsn = 1;
end;
%  ll = [19:130];
  ll = [20:130];
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
ints = zeros(maxpix,sizeA(3));
errs = zeros(maxpix,sizeA(3));

for(l = 1:sizeA(3))
      % Polarization factor
    if(strcmp(getfield(header(l),'Title'),'Reference_on_GC_holder_before_sample_sequence')|strcmp(getfield(header(l),'Title'),'Reference on GC holder after sample sequence'))
      Apolcor = polarizationcorrection(getfield(header(l),'Dist')-distancetoreference,pixelsize,orig(1));
    else
      Apolcor = polarizationcorrection(getfield(header(l),'Dist'),pixelsize,orig(1));
    end;
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
end;
%for(k = 1:sizeA(3))
%    loglog([1:length(ints)],ints(:,k),'-','LineWidth',k*0.5); hold on;
%    errorbar([1:length(ints)],ints(:,k),errs(:,k),'.');
%end;
%hold off;
