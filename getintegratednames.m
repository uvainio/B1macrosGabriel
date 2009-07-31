function param = getintegratednames(fsns)

% param = getintegratednames(fsns)
%
% Created 16.9.2007 UV

counter = 1;
for(k = 1:length(fsns))
   name = sprintf('intnorm%d.log',fsns(k));
   param1 = readlogfile(name);
   if(isstruct(param1))
       param(counter) = param1;
       counter = counter +1;
   end;
end;