function ints = getintnormfiles(fsns)

% function ints = getintnormfiles(fsns)
%
% Usage: ints = getintnormfiles([23:150]);
%
% ints is a structre which containes elements 'q', 'Intensity' and 'Error'
% 
%
% Created: 17.9.2007 UV

counter = 1;
for(k = 1:length(fsns))
   name = sprintf('intnorm%d.dat',fsns(k));
   int1 = readintfile(name);
   if(isstruct(int1))
       int1 = setfield(int1,'FSN',fsns(k));
       ints(counter) = int1;
       counter = counter +1;
   end;
end;
