function assessintensity(fsns,titleofsample)

% function assessintensity(fsns,titleofsample)
%
% Gives average of transmissions measured at different times for the sample
% with sample name 'titleofsample' within the wanted file sequence numbers
% (fsns) e.g. [1:400].
%
% Created: 6.5.2008 UV (ulla.vainio@gmail.com)
%
% Uses: READHEADER.M and READLOGFILE.M

% Converting - and space to _ to ease analysis, because structure cell names cannot
% have the sign - or space, this is used also by READHEADER.M so they
% should work together well..
for(k = 1:length(titleofsample))
    if(strcmp(titleofsample(k),'-') | strcmp(titleofsample(k),' '))
        titleofsample(k) = '_';
    end;
end;

% First find the files related only to this sample
% Assuming that only this sample is named this way
% Finding different energies
energies = [];
counter = 1;
for(k = 1:length(fsns))
  temp = readheader('ORG',fsns(k),'.DAT');
  if(isstruct(temp))
      if(strcmp(temp.Title,titleofsample))
         fsnsample(counter) = fsns(k);
         param(counter) = temp;
         temp2 = readlogfile(sprintf('intnorm%d.log',fsns(k))); % Read intnorm.log files
         if(isstruct(temp2))
           intensity(counter) = temp2.Monitor;
           primaryintensity(counter) = temp2.PrimaryIntensity;
           doris(counter) = temp.Current1;
           if(length(energies)==1) minindex = fsnsample(counter); end; %first fsn
           if(isempty(find(round(energies)==round(temp2.Energy))))
             energies = [energies temp2.Energy];
           end;
           counter = counter + 1;
         end;
      end;
  end;
end;
if(counter == 1)
    disp('Could not find any files with this sample name. Stopping.');
    return;
end;
maxindex = fsnsample(counter-1);
energies = sort(energies)

legend1 = {};
legend2 = {};
legend3 = {};
legend4 = {};
% Finding the transmissions at different measurement energies.
for(l = 1:length(energies))
  transm1 = [];
  timefsn = [];
  fsn1 = [];
  beamx1 = [];  beamy = [];
  beamx = [];  beamy1 = [];
  intensity1 = [];
  primaryintensity1 = [];
  doris1 = [];
  dist1 = [];
  energy1 = energies(l);
  for(k = 1:(counter-1))
    if(round(param(k).Energy) == round(energy1))
       transm1 = [transm1 param(k).Transm];
       fsn1 = [fsn1 param(k).FSN];
       dist1 = [dist1 param(k).Dist];
       beamx1 = [beamx1 param(k).BeamsizeX]; beamx = [beamx param(k).BeamsizeX];
       beamy1 = [beamy1 param(k).BeamsizeY]; beamy = [beamy param(k).BeamsizeY];
       intensity1 = [intensity1 intensity(k)];
       primaryintensity1 = [primaryintensity1 primaryintensity(k)];
       doris1 = [doris1 doris(k)];
    end;
  end;
% transmission
  subplot(6,1,1);
  handl = plot(fsn1,transm1,'-o'); hold on
  set(handl,'MarkerFaceColor',[1/l (length(energies)-l)/length(energies) 0.6]);
  set(handl,'LineWidth',1); 
  ylabel('Transmission');
  xlabel('FSN');
% Intensity
  subplot(6,1,2);
  handl = plot(fsn1,intensity1,'o'); hold on
  set(handl,'MarkerFaceColor',[1/l (length(energies)-l)/length(energies) 0.6]);
  set(handl,'LineWidth',1); 
  ylabel('Intensity (counts/sec)');
  xlabel('FSN');
% Primary Intensity calculated from glassy carbon
  subplot(6,1,3);
  handl = plot(fsn1,primaryintensity1,'o'); hold on
  set(handl,'MarkerFaceColor',[1/l (length(energies)-l)/length(energies) 0.6]);
  set(handl,'LineWidth',1); 
  ylabel('Intensity (photons/sec/mm^2)');
  xlabel('FSN');
% DORIS current
  subplot(6,1,4);
  handl = plot(fsn1,doris1,'o'); hold on
  set(handl,'MarkerFaceColor',[1/l (length(energies)-l)/length(energies) 0.6]);
  set(handl,'LineWidth',1); 
  ylabel('Doris current (mA)');
  xlabel('FSN');
% Beamsize
  subplot(6,1,5);
  handl = plot(fsn1,beamx1,'s',fsn1,beamy1,'o'); hold on
  set(handl(1),'MarkerFaceColor',[1/l (length(energies)-l)/length(energies) 0.6]);
  set(handl(2),'MarkerFaceColor',[1/l (length(energies)-l)/length(energies) 0.6]);
  set(handl,'LineWidth',1); 
  ylabel('x (square), y (circle) in mm');
  xlabel('FSN');
% Sample-to-detector distance
  subplot(6,1,6);
  handl = plot(fsn1,dist1,'o'); hold on
  set(handl,'MarkerFaceColor',[1/l (length(energies)-l)/length(energies) 0.6]);
  set(handl,'LineWidth',1); 
  ylabel('SD-Distance');
  xlabel('FSN');
end;

subplot(6,1,1);
axis auto
hold off
%ax = axis; axis([minindex-10 maxindex+10 ax(3) ax(4)]);
title(sprintf('Sample: %s, period: %d.%d. %d:%d - %d.%d. %d:%d',titleofsample,param(1).Day,param(1).Month,param(1).Hour,param(1).Minutes,param(end).Day,param(end).Month,param(end).Hour,param(end).Minutes)); 
subplot(6,1,2);
axis auto
hold off
%ax = axis; axis([minindex-10 maxindex+10 ax(3) ax(4)]);
subplot(6,1,3);
axis auto
%text(0.2,0.2,sprintf('Beamsize x %.2f y %.2f',beamz,beamy))
%ax = axis; axis([minindex-10 maxindex+10 ax(3) ax(4)]);
hold off
subplot(6,1,4);
axis auto
%ax = axis; axis([minindex-10 maxindex+10 ax(3) ax(4)]);
hold off
subplot(6,1,5);
axis auto
ax = axis; axis([ax(1) ax(2) (min([beamy beamx])-0.1) (max([beamy beamx]+0.1))]);
hold off
subplot(6,1,6);
axis auto
hold off
