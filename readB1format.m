function [A,transm,mtime,monitorc,energy,samples,distance,pixelsize] = readB1format(filename,files,fileend)

% function [A,transm,mtime,monitorc,energy,samples,distance,pixelsize] = readB1format(filename,files,fileend)
%
% filename  = beginning of the file, e.g. 'ORG'
% files     = the files , e.g. [714:1:804] will open files from with FSN
%             from 714 to 804
% fileend   = e.g. '.DAT'
%
% A = data matrix (total number of counts measured for each pixel)
% transm = transmission T
% mtime = measurement time
% monitorc = total monitor counts
% energy = uncalibrated energy E = hc/lambda, which reads in the file
% distance = sample-to-detector distance in mm
% pixelsize = length of one pixel in mm in x direction
%
% Created: 27.4.2004 in Hamburg - U. Vainio, e-mail: ulla.vainio@gmail.com
% Edited:
% 18.7.2007 Fine adjustments, comments. -UV

nr = size(files);
A = zeros(256,256,nr(1)+nr(2)-1);
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

   % If file was found, start reading:
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
    temp = fscanf(fid,'%s',(133-52));
    mtemp = fscanf(fid,'%e',[8,8192]);
    A(:,:,counter) = reshape(mtemp,256,256);  % Reading the matrix.
    counter = counter + 1;
    fclose(fid);
end;
end;

pixelsize
samples
mtime
transm
monitorc
distance

% Transforming the wavelength to energy
hc = 2*pi*1973.269601;
energy = hc./lambda