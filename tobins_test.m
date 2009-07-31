function [q,ints2,errs2] = tobinsfilter(qs0,ints0,errs0,bins,fq,lq,qs)

% function [q,ints2,errs2] = tobinsfilter(qs0,ints0,errs0,bins,fq,lq,qs)
%
% This TOBINS function combines the data in such a way that
% intensity vectors of different length with different
% q ranges will be on the same scale but with less pixels.
% The number of pixels is defined in the 'bins'. It should
% be equal or more than 1.
%
% qs0       q-values for each intensity curve
% ints0     intensities
% errs0     errors of the intensities
% bins     e.g. 4 bins 4 pixels together, if 1, no binning is made
% fq       first q-value
% lq       last q-value
% qs       the q-range to which the intensity is first interpolated
%               before it is binned
%
% UV 4.1.2008 DESY, Hamburg

% First we linearly interpolate the q-range to what is given


% Now we filter the data with a box function with length 'bins' 

