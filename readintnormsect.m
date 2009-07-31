function [data1,data2,data3,data4,param1,param2,param3,param4] = readintnormsect(fsns)

% function [data,param] = readintnormsect(fsns)
%
%
% Created 26.10.2007
% Edited 23.9.3008 UV to read in sector integrated files

counter1 = 1;
counter2 = 1;
counter3 = 1;
counter4 = 1;
for(k = 1:length(fsns))
  for(m = 1:4)
    temp = readintfile(sprintf('intnorm%dsect%d.dat',fsns(k),m));
    if(isstruct(temp))
       temp2 = readlogfilesect(sprintf('intnorm%dsect.log',fsns(k)));
       if(isstruct(temp2) && m ==1)
        data1(counter1) = temp;
        param1(counter1) = temp2;
%        param1(counter1).Fii = temp2.Fii1;
        counter1 = counter1 + 1;
      elseif(isstruct(temp2) && m ==2)
        data2(counter2) = temp;
        param2(counter2) = temp2;
%        param1(counter2).Fii = temp2.Fii2;
        counter2 = counter2 + 1;
      elseif(isstruct(temp2) && m ==3)
        data3(counter3) = temp;
        param3(counter3) = temp2;
%        param1(counter3).Fii = temp2.Fii3;
        counter3 = counter3 + 1;
      elseif(isstruct(temp2) && m ==4)
        data4(counter4) = temp;
        param4(counter4) = temp2;
%        param1(counter4).Fii = temp2.Fii4;
        counter4 = counter4 + 1;
      end;
    end;
  end;
end;