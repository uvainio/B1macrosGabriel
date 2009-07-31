function [data,param] = readbinned(fsns,theor)

% function [data,param] = readbinned(fsns,theor)
%
% theor is optional. Use theor = 1 if you read data processed with
% theoretical transmission for glassy carbon
%
% Created 31.10.2007

counter = 1;
for(k = 1:length(fsns))
   temp = readintfile(sprintf('intbinned%d.dat',fsns(k)));
   if(isstruct(temp))
       if(nargin ==1)
          temp2 = readlogfile(sprintf('intnorm%d.log',fsns(k)));
       else
          temp2 = readlogfile(sprintf('intnormtheor%d.log',fsns(k)));
       end;
      if(isstruct(temp2))
        data(counter) = temp;
        param(counter) = temp2;
        counter = counter + 1;
      end;
   end;
end;