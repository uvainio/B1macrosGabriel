function f = agbeori(orig,B,mask,x)
%
% function f = agbeori(orig,B,mask,[x1:x2])
%
% B = Agbe matrix
% orig = guessed origo
% [x1:x2] = the region at which we compare the peaks on pixel scale
%
% Use with fminsearh:
%
% ori = fminsearch(@agbeori,orig,[],B,x);
%
% UV 28.4.2004 Hamburg
B = B*1000;

fi = [35 55];
c1 = sectint(B,fi,orig);
c2 = sectint(B,fi+90,orig);
c3 = sectint(B,fi+180,orig);
c4 = sectint(B,fi+270,orig);

%plot(c1);hold on; plot(c2,'-r');
%plot(c3,'.g');hold on; plot(c4,'--k');hold off
%lam1 = guespeak(c1,[min(c1(x)) max(c1(x))],x);    % Gues the parameters.
%lam1 = fminsearch(@gaussianfit,lam1,[],c1(x),x);
%lam2 = guespeak(c1,[min(c2(x)) max(c2(x))],x);    % Gues the parameters.
%lam2 = fminsearch(@gaussianfit,lam2,[],c2(x),x);
%lam3 = guespeak(c1,[min(c3(x)) max(c3(x))],x);    % Gues the parameters.
%lam3 = fminsearch(@gaussianfit,lam3,[],c3(x),x);
%lam4 = guespeak(c1,[min(c4(x)) max(c4(x))],x);    % Gues the parameters.
%lam4 = fminsearch(@gaussianfit,lam4,[],c4(x),x);

%f = sum((gaussianline(lam1,x)-gaussianline(lam3,x)).^2 + (gaussianline(lam2,x)-gaussianline(lam4,x)).^2);

f = sum((c1(x)-c3(x)).^2 + (c2(x) - c4(x)).^2);
