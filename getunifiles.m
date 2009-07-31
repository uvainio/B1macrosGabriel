function unis = getunifiles(fsns)

% function unis = getunifiles(fsns)
%
% Usage: unis = getunifiles([23:150]);
%
% unis is a structre which containes elements 'q', 'Intensity' and 'Error'
% 
% Created: 17.9.2007 UV

counter = 1;
for(k = 1:length(fsns))
   name = sprintf('uni%d.dat',fsns(k));
   int1 = readintfile(name);
   if(isstruct(int1))
       int1 = setfield(int1,'FSN',fsns(k));
       unis(counter) = int1;
       counter = counter +1;
   end;
end;
