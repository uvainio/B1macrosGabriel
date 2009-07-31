function [pos,int,FWHM] = gausfast(q,data,peaks)

% function [pos,int,FWHM] = gausfast(q,data,peaks)
%
% IN:
%
%   q        q-vector for the data
%   data     data in a vector
%   peaks    number of peaks you want to fit
%
% OUT:
%
%   pos      positions of the peaks fitted by zooming on the peak
%   int      normalised integrated intensity of the gaussian peak
%   FWHM     full width at half maximum
%
% USAGE:
%   Zoom on the peak you want to fit and press enter.
%
% NOTE: The peaks are fitted on pixel scale and the position
%       is transformed to q-scale using interp1.
% 
% NEEDS MACROS: guespeak.m, gaussianfit.m and gaussianline.m
%
% Authored by Ulla Vainio 19.5.2003

pix = [1:length(q)];
data = data(:);
q = q(:)';

lam = zeros(peaks,5);
pos = zeros(peaks,1);
int = pos;
FWHM = pos;

n = 0; exitflag = 0;
for(j=1:peaks)           % Minimize the parameters.
  figure(1);plot(data);zoom on
  sprintf('Zoom the figure around the %g. diffraction peak.',j)
  j1 = input('');
  axn = axis;
  ax = round(axis);
  axv = ax(3):ax(4);
  axh = ax(1):ax(2);
  lam(j,:) = guespeak(data,axv,axh);    % Gues the parameters.
  plot([1:length(data)],data,'.',axh,gaussianline(lam(j,:),axh)); %axis(ax);
  title('First guess.'); xlabel('Pixel'); ylabel('Intensity');
  pause
  while(exitflag == 0 & n < 10),
    n
    [lam(j,:),fval,exitflag] = fminsearch('gaussianfit',lam(j,:),[],data(axh),axh);
    n = n + 1;
  end;
  plot([1:length(data)],data,'.',axh,gaussianline(lam(j,:),axh));axis(axn);
  title('Final fit.'); xlabel('Pixel'); ylabel('Intensity');
  pause
  n = 0; exitflag = 0;
  pos(j) = interp1(pix',q,lam(j,2))
  temp = interp1(pix',q,lam(j,3)+lam(j,2))-pos(j); % width transformed
	                                % from pixel scale approximatively
  int(j) = lam(j,1)/(temp*sqrt(2*pi));
  FWHM(j) = temp*2*sqrt(2*log(2));
end;

plot(q,data,pos(1),data(round(lam(1,2))),'*r');
if (peaks > 1)
  hold on
  for(j = 2:peaks)
    plot(pos(j),data(round(lam(j,2))),'*r');
  end;
end;
hold off

