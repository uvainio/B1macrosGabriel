function f = writelogfiletheor(header,ori,thick,fsndc,realenergy,distance,mult,errmult,reffsn,thickGC,injectionGC,injectionEB,pixelsize,transmtheor)

% function f = writelogfiletheor(header,ori,thick,fsndc,realenergy,distance,mult,errmult,reffsn,thickGC,injectionGC,injectionEB,pixelsize,transmtheor)
%
% IN:
%
% OUT:
%
% Writes input data to file 'intnormtheorFSN.log' in directory 'analysis' (if it does
% not exist already, create one first)
% f = 1 if succesful
%
% Created 11.11.2007 UV
%

% Edited 19.9.2007 UV: Added FSN.
% Edited 2.1.2008 UV, added monitor counts

name = sprintf('intnormtheor%d.log',getfield(header,'FSN'));
fid = fopen(name,'w');

fprintf(fid,'FSN:\t%d\n',getfield(header,'FSN'));
fprintf(fid,'Sample title:\t%s\n',getfield(header,'Title'));
fprintf(fid,'Sample-to-detector distance (mm):\t%d\n',distance);
fprintf(fid,'Sample thickness (cm):\t%f\n',thick);
if(transmtheor==-1) % This is used if the measured value is accurate but glassy carbon has theoretical transmission
  fprintf(fid,'Sample transmission:\t%.4f\n',getfield(header,'Transm'));
else % This for the glassy carbon measurements
  fprintf(fid,'Sample transmission:\t%.4f\n',transmtheor);
end;
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
fprintf(fid,'Primary intensity calculated from GC (photons/sec/mm^2):\t%e\n',1/mult/pixelsize^2);

fclose(fid);


