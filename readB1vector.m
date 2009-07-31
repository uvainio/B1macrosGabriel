function [qs,ints,errs,samples,energy,transm,mtime] = readB1vector(filename,files,fileend)

% function [qs,ints,errs,samples,energy,transm,mtime] = readB1vector(filename,files,fileend)
%
% filename  = beginning of the file
% files     = the files , e.g. [800:1:804]; reads files with FSN 800,
%                       801, 802, 803, and 804
% fileend   = the ending of the file, e.g. '.AD0' or '.010'
%
% qs = q scales in columns
% ints = intensities in columns
% errs = errors of intensities in columns
% samples = names of the samples in a vector
% energy = measurement energies in a vector
% transm = transmissions T in a vector
% mtime = measurement times in a vector
%
% Reads the vector format of B1 beamline (e.g. RAD01083.AD0)
%
% Created: 3.5.2004 by U. Vainio

nr = size(files);
transm = zeros(nr(1)*nr(2),1); monitorc = transm; mtime = transm; lambda = transm;
distance = transm; pixelsize = transm;

counter = 1;
for(l = 1:nr(1))
for(k = 1:nr(2))
    name = sprintf('%s%g%s',filename,files(l,k),fileend);
    fid = fopen(name,'r');
    name1 = name;
    if(fid == -1) % Tries out also all filenames with zeros in between
        name = sprintf('%s0%g%s',filename,files(l,k),fileend);
        fid = fopen(name,'r');
     end;
     if(fid == -1)
        name = sprintf('%s00%g%s',filename,files(l,k),fileend);
        fid = fopen(name,'r');
     end;
     if(fid == -1)
        name = sprintf('%s000%g%s',filename,files(l,k),fileend);
        fid = fopen(name,'r');
     end;
     if(fid == -1)
        name = sprintf('%s0000%g%s',filename,files(l,k),fileend);
        fid = fopen(name,'r');
     end;
     if(fid ~= -1)
        disp(name) % shows name that opened
     end;

     if(fid == -1)
         sprintf('Cannot find file with FSN %d. End of reading.\nTried to read files named %s\nand %s and all variants in between.\n', ...
         files(l,k),name,name1)
         return;
     end;

    temp = fscanf(fid,'%s',31);

    monitorc(counter) = fscanf(fid,'%g',1);        % Total monitor counts.
    temp = fscanf(fid,'%g',1);
    
    mtime(counter) = fscanf(fid,'%g',1); % Measurement time.
    temp = fscanf(fid,'%g',(42-35));
    
    transm(counter) = fscanf(fid,'%g',1); % Transmission.
    temp = fscanf(fid,'%g',1);

    lambda(counter) = fscanf(fid,'%g',1); % Wavelength (non-calibrated!)
    temp = fscanf(fid,'%g',2);    

    distance(counter) = fscanf(fid,'%g',1); % distance from sample to detector   
    temp = fscanf(fid,'%g',2);

    temp = fscanf(fid,'%g',1);
    pixelsize(counter) = 1/temp;          % Pixel length in mm
    temp = fscanf(fid,'%g',3);    

    sample = fscanf(fid,'%s',1); % Sample name.
    if(k == 1 && l == 1)
        samples = sample;
    else
        samples = strvcat(samples,sample);
    end;
    temp = fgets(fid);
temp = fscanf(fid,'%s',(133-54));
    mtemp = fscanf(fid,'%e');
    if(counter == 1)
       qs = zeros(length(mtemp)/3,length(files));
       ints = qs; errs = qs;
    end;
    counter2 = 1;
    for(j = 1:3:(length(mtemp)-3)) % Due to the inverse ordering
    % of the vectors we put them in right order.
      qs(counter2,counter) = mtemp(j);
      ints(counter2,counter) = mtemp(j+1);
      errs(counter2,counter) = mtemp(j+2);
      counter2 = counter2 + 1;
    end;
    counter = counter + 1;
    fclose(fid);
end;
end;

%samples
%mtime
%transm
%monitorc
%distance

% Transforming the wavelength to energy
hc = 2*pi*1973.269601;
energy = hc./lambda;
