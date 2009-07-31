function datasum = sumB1pos(data,param,position)

% function datasum = sumB1pos(data,param,position)
%
% Sample position 'position' overrides sample name, so be careful.
%
% Created 28.11.2007

energies = [];
sd = size(data);
for(p = 1:sd(2)) % Search for all different energies
   if(isempty(find(energies==param(p).EnergyCalibrated)))
     energies = [energies param(p).EnergyCalibrated];
   end;
end;

countertotal = 1;
allfsnssummed = [];
for(h = 1:length(energies))
  counter = 1;
  for(k = 1:sd(2)) % first sum
    if(param(k).PosSample == position & round(param(k).EnergyCalibrated) == round(energies(h)))
      if(counter == 1) % Create the first structure.
          sumq = data(k).q;
          sumints = data(k).Intensity;
          sumerrs = data(k).Error;
          sumfsns = param(k).FSN;
          counter = counter + 1;
          calibratedenergy = param(k).EnergyCalibrated;
          loglog(data(k).q,data(k).Intensity,'r'); hold on
      elseif(sum(data(k).q) - sum(sumq) == 0) % Making sure q-range is the same
          sumints = sumints + data(k).Intensity;
          sumerrs = sqrt(sumerrs.^2 + data(k).Error.^2);
          sumfsns = [sumfsns param(k).FSN];
          counter = counter + 1;
          loglog(data(k).q,data(k).Intensity,'r'); hold on
      else
         disp('Are you sure the data is binned to the same q-spacing?')          
      end;
    end;
  end;
  if(counter > 1)
    for(mm = 1:(counter-1))
        ints = sumints/(counter-1);
        errs = sumerrs/(counter-1);
    end;
    summed = struct('q',sumq,'Intensity',ints,'Error',errs,'FSN',sumfsns,'EnergyCalibrated',calibratedenergy,'PosSample',position);
    disp(sprintf('Summed %d measurements:',counter-1));
    getsamplenames('ORG',summed.FSN,'.DAT',1);

    % Plotting the summed intensity with the originals in red and this in blue.
    errorbar(summed.q,summed.Intensity,summed.Error,'.'); hold on
    hold off
    pause
    datasum(countertotal) = summed;
    countertotal = countertotal + 1;
    allfsnssummed = [allfsnssummed sumfsns];
  end;
end;

% Check if some were not summed and add them in the structure
for(k = 1:sd(2))
    if(isempty(find(allfsnssummed==param(k).FSN)) & param(k).PosSample == position)
        temp = struct('q',sumq,'Intensity',ints,'Error',errs,'FSN',sumfsns,'EnergyCalibrated',calibratedenergy,'PosSample',position);
        datasum(countertotal) = temp;
        countertotal = countertotal + 1;
    end;
end;
    
