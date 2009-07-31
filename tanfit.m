function g = tanfit(lamq,qpix,qh,lambda)

% function g = tanfit(lamq,qpix,qh,lambda)
%
% Submacro for qrange.m and qtanfit.m
%
% Creator: Ulla Vainio, ulla.vainio@helsinki.fi (univ. of Helsinki)
%          spring 2003

g = sum(abs(qh-lamq(2)*4*pi*sin(atan(lamq(1)*qpix)/2)/lambda));
