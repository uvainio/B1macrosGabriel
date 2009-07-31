function f = fitpixelsize(pixelsizestart,ints1,errs1,header1,ints2,errs2,header2,energyreal1,energyreal2,ll1,ll2)

% function f = fitpixelsize(pixelsizestart,ints1,errs1,header1,ints2,errs2,header2,energyreal1,energyreal2)
%
%
% Created 4.10.2007 UV

q1 = qfrompixelsizeB1(getfield(header1,'Dist'),pixelsizestart,energyreal1,[1:length(ints1)]);
q2 = qfrompixelsizeB1(getfield(header2,'Dist'),pixelsizestart,energyreal2,[1:length(ints2)]);

% Normalise the data so that they are easier to fit
ints1 = ints1/max(ints1(30:160))*1000;
ints2 = ints2/max(ints2(30:160))*1000;

% Fitting a gaussian to the 1st reflections
lam1 = [1000 2*pi/58.4 0.01 -1.1 200]; % Intensity, position, width, a*x + b
lam2 = [1000 2*pi/58.4 0.01 -2.1 50]; % Intensity, position, width, a*x + b
options = optimset;
options = optimset(options,'MaxFunEvals',100000000);
lam1 = fminsearch('lorentzfit',lam1,options,ints1(ll1),errs1(ll1),q1(ll1));
lam2 = fminsearch('gaussianfit1',lam2,options,ints2(ll2),errs2(ll2),q2(ll2));

f = abs(lam1(2)-lam2(2))

plot(q1,ints1,'.',q1,lorentzian(lam1,q1)); hold on
plot(q2,ints2,'.r',q2,gaussianline(lam2,q2),'c'); hold off
text(lam1(2),1000,sprintf('q_{%d} = %f',getfield(header1,'Dist'),lam1(2)))
text(lam2(2),1000,sprintf('q_{%d} = %f',getfield(header2,'Dist'),lam2(2)))
