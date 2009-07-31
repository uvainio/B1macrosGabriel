function f = writelogfilesect(header,ori,thick,fsndc,realenergy,distance,mult,errmult,reffsn,thickGC,injectionGC,injectionEB,pixelsize,fii1,fii2,fii3,fii4)

% function f = writelogfilesect(header,ori,thick,fsndc,realenergy,distance,mult,errmult,reffsn,thickGC,injectionGC,injectionEB,pixelsize,fii1,fii2,fii3,fii4)
%
% IN:
%
% OUT:
%
% Writes input data to file 'intnormFSN.log' in directory 'analysis' (if it does
% not exist already, create one first)
% f = 1 if succesful
%
% Created 13.9.2007 UV
%

% Edited 19.9.2007 UV: Added FSN.
% Edited 2.1.2008 UV, added monitor counts
% Edited 6.5.2008 UV, corrected absolute primary intensity calculation
% Edited: 23.9.2008 UV, added sectors and changed name to writelogfilesect.m

name = sprintf('intnorm%dsect.log',getfield(header,'FSN'));
fid = fopen(name,'w');

fprintf(fid,'FSN:\t%d\n',getfield(header,'FSN'));
fprintf(fid,'Sample title:\t%s\n',getfield(header,'Title'));
fprintf(fid,'Sample-to-detector distance (mm):\t%d\n',distance);
fprintf(fid,'Sample thickness (cm):\t%f\n',thick);
fprintf(fid,'Sample transmission:\t%.4f\n',getfield(header,'Transm'));
fprintf(fid,'Sample position (mm):\t%.2f\n',getfield(header,'PosSample'));
fprintf(fid,'Temperature:\t%.2f\n',getfield(header,'Temperature'));
fprintf(fid,'Measurement time (sec):\t%.2f\n',getfield(header,'MeasTime'));
fprintf(fid,'Scattering on 2D detector (photons/sec):\t%.1f\n',getfield(header,'Anode')/getfield(header,'MeasTime'));
fprintf(fid,'Dark current FSN:\t%d\n',fsndc);
fprintf(fid,'Empty beam FSN:\t%d\n',getfield(header,'FSNempty'));
fprintf(fid,'Injection between Empty beam and sample measurements?:\t%s\n',injectionEB);
fprintf(fid,'Glassy carbon FSN:\t%d\n',reffsn);
fprintf(fid,'Glassy carbon thickness (cm):\t%.4f\n',thickGC);
fprintf(fid,'Injection between Glassy carbon and sample measurements?:\t%s\n',injectionGC);
fprintf(fid,'Energy (eV):\t%.2f\n',getfield(header,'Energy'));
fprintf(fid,'Calibrated energy (eV):\t%.2f\n',realenergy);
fprintf(fid,'Beam x y for integration:\t%.2f %.2f\n',ori(1),ori(2));
fprintf(fid,'Normalisation factor (to absolute units):\t%e\n',mult);
fprintf(fid,'Relative error of normalisation factor (percentage):\t%.2f\n',100*errmult/mult);
fprintf(fid,'Beam size X Y (mm):\t%.2f %.2f\n',getfield(header,'BeamsizeX'),getfield(header,'BeamsizeY'));
fprintf(fid,'Pixel size of 2D detector (mm):\t%.4f\n',pixelsize);
fprintf(fid,'Primary intensity at monitor (counts/sec):\t%.1f\n',getfield(header,'Monitor')/getfield(header,'MeasTime'));
fprintf(fid,'Primary intensity calculated from GC (photons/sec/mm^2):\t%e\n',getfield(header,'Monitor')/getfield(header,'MeasTime')/mult/(getfield(header,'BeamsizeX')*getfield(header,'BeamsizeY')));
fprintf(fid,'Sector integration area 1 from %d to %d',fii1(1),fii1(2));
fprintf(fid,'Sector integration area 2 from %d to %d',fii2(1),fii2(2));
fprintf(fid,'Sector integration area 3 from %d to %d',fii3(1),fii3(2));
fprintf(fid,'Sector integration area 4 from %d to %d',fii4(1),fii4(2));

fclose(fid);


