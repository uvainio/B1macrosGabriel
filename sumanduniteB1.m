function sumanduniteB1(data,param,samplename,uniq,dist,q1,q2,shortfactor,bglong,bgshort)

% function sumanduniteB1(data,param,samplename,uniq,dist,q1,q2,shortfactor,bglong,bgshort)
%
% dist = e.g. [3635 935]
% 
% Shortfactor = factor for multiplying the q-range of the short distance
% measurement to the theoretical q-range (calibrated with Silver Behenate)
%
% Created 7.11.2007
% Added saving of only summed files, if one distance is missing.
% 20.2.2009 UV: Added shortfactor

datasum = sumintegratedB1(data,param,samplename);
dist = sort(dist);
disp('Uniting data, please check that curves match before pressing enter.');
energies = [];
temperatures = [];
sd = size(datasum);
for(p = 1:sd(2)) % Search for all different energies
   if(isempty(find(energies==datasum(p).EnergyCalibrated)))
     energies = [energies datasum(p).EnergyCalibrated];
   end;
   if(isempty(find(temperatures==round(datasum(p).Temperature))))
     temperatures = 24; %[temperatures round(datasum(p).Temperature)];
   end;
end;
bothfound = 0;
for(h = 1:length(energies))
  for(l = 1:length(temperatures))
  for(k = 1:sd(2)) % Allowing 2 eV mismatch in the short and long distance energies
    if(strcmp(datasum(k).Title,samplename) & dist(1)/datasum(k).Dist > 0.95 & dist(1)/datasum(k).Dist < 1.05 & datasum(k).EnergyCalibrated./energies(h) > 0.9997 & datasum(k).EnergyCalibrated./energies(h) < 1.0003 & temperatures(l)/datasum(k).Temperature > 0.9 & temperatures(l)/datasum(k).Temperature < 1.1)
        bothfound = bothfound + 1; % Short distance
        short = struct('q',datasum(k).q*shortfactor,'Intensity',datasum(k).Intensity,'Error',datasum(k).Error,'Temperature',datasum(k).Temperature);
    elseif(strcmp(datasum(k).Title,samplename) & dist(2)/datasum(k).Dist > 0.95 & dist(2)/datasum(k).Dist < 1.05 & round(datasum(k).EnergyCalibrated) == round(energies(h)) & temperatures(l)/datasum(k).Temperature > 0.9 & temperatures(l)/datasum(k).Temperature < 1.1)
        bothfound = bothfound + 1; % long distance
        long = struct('q',datasum(k).q,'Intensity',datasum(k).Intensity,'Error',datasum(k).Error,'Temperature',datasum(k).Temperature);
    end;
    if(bothfound == 2) % Short and long distance found so unite them
      if(long.Temperature./short.Temperature <1.1 | long.Temperature./short.Temperature <0.9)
         disp(sprintf('Uniting at energy %f.',datasum(k).EnergyCalibrated))
         [f,multipl] = consaxs([short.q short.Intensity short.Error],[long.q long.Intensity long.Error],uniq, q1,q2,samplename,bglong,bgshort);
         name = sprintf('united%d.dat',min(datasum(k).FSN));
         title(name);
         fid = fopen(name,'w');
         if(fid > -1)
            for(pp = 1:length(f))
              fprintf(fid,'%e %e %e\n',f(pp,1),f(pp,2),f(pp,3));
            end;
            fclose(fid);
            disp(sprintf('Saved summed and united data to file %s',name));
         else
            disp(sprintf('Unable to save data to file %s',name));
         end;
         % Write log-file
         name = sprintf('united%d.log',min(datasum(k).FSN));
         fid = fopen(name,'w');
         if(fid > -1)
            fprintf(fid,'FSNs:');
            temp = datasum(k).FSN;
            for(pp = 1:length(temp))
                fprintf(fid,' %d',temp(pp));
            end;
            fprintf(fid,'\n');
            fprintf(fid,'Sample name: %s\n',datasum(k).Title);
            fprintf(fid,'Calibrated energy: %e\n',datasum(k).EnergyCalibrated);
            fprintf(fid,'Multiplied short distance data by: %f\n',multipl);
            fprintf(fid,'Temperature: %.f (long) %.f (short)\n',long.Temperature,short.Temperature);
            fclose(fid);
            disp(sprintf('Saved %s',name));
         else
            disp(sprintf('Unable to save data to file %s\n',name));
         end;
        break; % Break only the inner loop
      else
             disp(sprintf('Both distances found, but temperatures are different: %.f (long) %.f (short)\n',long.Temperature,short.Temperature));
      end;
    elseif(k == sd(2) && bothfound == 1)
        disp(sprintf('NOTE: At energy %f (calibrated) a measurement at one distance is missing.',energies(h)));
%         name = sprintf('united%d.dat',min(datasum(h).FSN));
%         f = [datasum(h).q datasum(h).Intensity datasum(h).Error];
%         fid = fopen(name,'w');
%         if(fid > -1)
%            for(pp = 1:length(f))
%              fprintf(fid,'%e %e %e\n',f(pp,1),f(pp,2),f(pp,3));
%            end;
%            fclose(fid);
%            disp(sprintf('Saved summed data to file %s',name));
%         else
%            disp(sprintf('Unable to save data to file %s',name));
%         end;
%         % Write log-file
%         name = sprintf('united%d.log',min(datasum(h).FSN));
%         fid = fopen(name,'w');
%         if(fid > -1)
%            fprintf(fid,'FSNs:');
%            temp = datasum(k).FSN;
%            for(pp = 1:length(temp))
%                fprintf(fid,' %d',temp(pp));
%            end;
%            fprintf(fid,'\n');
%            fprintf(fid,'Sample name: %s\n',datasum(k).Title);
%            fprintf(fid,'Calibrated energy: %e\n',datasum(k).EnergyCalibrated);
%            fclose(fid);
%            disp(sprintf('Saved %s',name));
%         else
%            disp(sprintf('Unable to save data to file %s\n',name));
%         end;
    end;
  end;
    bothfound = 0; % Reset after each energy
end;
  bothfound = 0; % Reset after each energy
end;