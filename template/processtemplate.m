% Processed 

%% Load these first
addpath D:\matlabmacros\2008\macros
addpath D:\matlabmacros\2008\macros\calibrationfiles\
addpath D:\matlabmacros\2008\macros\dataqualitytools\
cd D:\Projekte\2009\project\
% Thicknesses of samples in cm
thicknessasaxs = struct('Sample1',??); % in cm
% Dark current measurement FSN
fsndc = 68;
% Energy scale calibration
energycalib = [11919.7 17995.88]; % 
energymeas = [11894 17973]; % The measured positions of 1st inflection points
% Mask for the integration 12keV
load D:\Projekte\2009\project\processing\masklong1.mat
masklong1 = mask;
% Load sensitivity 12keV
load D:\Projekte\2009\project\processing\sensitivity12keV.dat
load D:\Projekte\2009\project\processing\sensitivityerror12keV.dat
sens = sensitivity12keV;
errorsens = sensitivityerror12keV;

%%%%%%%% Processing of SAXS data %%%%%%%%%%%%%%%%%%%%%%%%%%
distminus = 0; % in mm the thickness of the sample holder divided by two (in case the sample holder is very thick)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Short distance measurements 12 keV
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% With this you can see what measurements were
getsamplenames('ORG',[??:??],'.DAT');

% Integrate and normalise data
B1normintall([??:??],thickness,1,fsndc,sens,errorsens,maskshort1,energymeas,energycalib,distminus,[135 122]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Long distance measurements 12keV
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Integrate and normalise data
B1normintall([??:??],thickness,?,fsndc,sens,errorsens,masklong1,energymeas,energycalib,[135 122]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% Summing and uniting the different distances 12 keV %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Read in integrated and normalised files
[data,param] = readintnorm([??:??]);
plotints(data,param,'Sample1',[12000 13000],'-');
set(gca,'XScale','Lin'); set(gca,'YScale','Lin');

% Bin data (using only interpolation!)
lastfsn = ??;
savebinned(1:lastfsn,3635,140,0.01,0.205);
savebinned(1:lastfsn,935,140,0.045,0.88);

% Read in integrated and normalised, binned files
[data,param] = readbinned([1:lastfsn]);

%unite files from different distances, puts together same sample names
uniteatq = 0.2;
sumanduniteB1(data,param,'Sample1',uniteatq,[3635 935],0.18,0.2);

% read to Matlab the unified measurements
[datauni1,paramuni1] = readunited([1:lastfsn]);

%plots unified measurements
plotints(datauni1,paramuni1,'Sample1',[12000],'-'); hold on
plotints(datauni1,paramuni1,'Sample2',[12000],'o'); hold on
hold off
xlabel(sprintf('q (1/%c)',197))
ylabel('Intensity (1/cm)')   


%%%%%%%%%%%%% XANES %%%%%%%%%%%%%%%%%%

%%% Loading absorption scans

[E,mu] = readenergyfio('abt_',??,'.fio');

plot(E,mu/max(mu)

% Corrects the energy scale and saves *.cor files with corrected energy scale
muds = readxanes('abt_',[??:??],'.fio',energymeas,energycalib);
plot(muds(1).Energy,(muds(1).mud-min(muds(1).mud))/max(muds(1).mud-min(muds(1).mud)),...
    muds(2).Energy,(muds(2).mud-min(muds(2).mud))/max(muds(2).mud-min(muds(2).mud)))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%% Stuff that had to be made before analysis could begin %%%%%%%%
%%%%%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%% Do not run these again!

%%%%%%%%%%% 7 keV

% Fluorescence of Se at around 11224 eV
energyfluor = 11224; FSNE2 = ??; FSNE1 = ??; lastFSN = ??;
[sens,errorsens] = makesensitivity(FSNE2,FSNE1,lastFSN,fsndc,energymeas,energycalib,energyfluor,135,122);
imagesc(sens); colorbar
title(sprintf('Sensitivity of 2D detector at B1 ?? 2009 E = %.1f keV',energyfluor/1000))
axis square
% print -depsc D:\Projekte\2009\project\processing\sensitivity12keV
% save D:\Projekte\2009\project\processing\sensitivity12keV.dat sens -ascii
% save D:\Projekte\2009\project\processing\sensitivityerror12keV.dat errorsens -ascii
imagesc(errorsens./sens); colorbar

% This is how the mask was made
% mask = makemask(ones(256,256),sens);
% save D:\Projekte\2009\project\processing\masklong1.mat mask

