function [data,param] = readunited(fsns)

% function [data,param] = readunited(fsns)
%
%
% Created 7.11.2007

counter = 1;
for(k = 1:length(fsns))
   temp = readintfile(sprintf('united%d.dat',fsns(k)));
   if(isstruct(temp))
       temp2 = readlogfile(sprintf('intnorm%d.log',fsns(k)));
      if(isstruct(temp2))
        data(counter) = temp;
        param(counter) = temp2;
        counter = counter + 1;
      end;
   end;
end;