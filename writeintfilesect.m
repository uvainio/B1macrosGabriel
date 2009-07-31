function f = writeintfilesect(q,int1,err1,header,sect)

% function f = writeintfile(q,int1,err1,header,sect)
%
% Writes into file intnormFSN.dat the information, excluding points
%   that have int1 == 0.
%
% Created: 15.9.2007 UV

name = sprintf('intnorm%dsect%d.dat',getfield(header,'FSN'),sect);
fid = fopen(name,'w');
if(fid > -1)
   disp(sprintf('Saving data to file %s',name));
   for(k = 1:length(int1))
     fprintf(fid,'%e %e %e\n',q(k),int1(k),err1(k));
   end;
   fclose(fid);
   f = 1;
else
   f = 0;
end;
