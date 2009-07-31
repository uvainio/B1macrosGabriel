function B1integratespecialall(fsn1,fsndc,sens,errorsens,orifsn,mask,distminus,energymeas,energycalib,subfiletitle)

% function B1integratespecialall(fsn1,fsndc,sens,errorsens,orifsn,mask,distminus,energymeas,energycalib,subfiletitle)
%
% Finds automatically empty beam and reference measurements and the samples
% related to those measurements and integrates, subtract dark current,
% divides by detector sensitivity, angle dependent transmission, absorption due
% to air and windows in the beam path and for geometrical distortion,
% subtracts empty beam background
% and normalises the data to the glassy carbon references.
% Finally the matrices are integrated to get 1d patterns.
%
% IN:
%
% fsn1 = all FSNs that you want to analyse (including empty beams
%        and references)
% fsndc = FSN of the dark current measurement
% orifsn = which measurement counting from the empty beam (0) is the
%          measurement from which the center of the beam is to be
%          determined from, use 1 for glassy carbon before measurement
%          sequence or the origin in format [x y]
% sens = sensitivity matrix of the detector
% errorsens = error of the sensitivity matrix
% mask = mask to mask out the center area, detector edges and bad spots
%        caused by for example reflections form beamstop
% energymeas = two or more measured energies in a vector
%             (1st inflection points of foils)
% energycalib = the true energies corresponding to the measured 1st
%               inflection points (for example from Kraft et al. 1996)
% subfiletitle = title of the subtracted measurement, e.g. 'Empty_beam'
%
% OUT:
%
% Saved files:
%
% intnormFSN.dat has three columns in which there are the q-scale,
%                intensity in relative units and the error of the intensity,
%                likewise in the same units as intensity
%
% Created 5.11.2007 UV (ulla.vainio@desy.de)

% Finding the empty beams from fsn1s

counter = 1;
for(l = 1:length(fsn1))
    temp = readheader('ORG',fsn1(l),'.DAT');
   if(isstruct(temp))
    header(counter) = temp;
    fsn1found(counter) = fsn1(l);
    counter = counter + 1;
   end;
end;

emptys(1,:) = [0 0];
counter = 1;
for(k = 1:length(fsn1found))
    if(strcmp(getfield(header(k),'Title'),subfiletitle))
        emptys(counter,:) = [getfield(header(k),'FSN') k];
        counter = counter + 1;
    end;
end;

for(m = 1:(length(emptys)-1))
  if(emptys(m+1,1) > fsn1found(emptys(m+1,2)-1)) % Process only if next file from empty is not empty
      B1integratespecial(fsn1found(emptys(m,2):(emptys(m+1,2)-1)),fsndc,sens,errorsens,orifsn,mask,distminus,energymeas,energycalib);
  end;
end;
% And the last one separately
B1integratespecial(fsn1found(emptys(end,2):end),fsndc,sens,errorsens,orifsn,mask,distminus,energymeas,energycalib);
