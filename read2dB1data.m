function [A,header,notfound,name] = read2dB1data(filename,files,fileend)

% function [A,header,notfound] = read2dB1data(filename,files,fileend)
%
% filename  = beginning of the file, e.g. 'ORG'
% files     = the files , e.g. [714:1:804] will open files from with FSN
%             from 714 to 804
% fileend   = e.g. '.DAT'
%
% A = data matrix (total number of counts measured for each pixel)
% header = header data of the data in the file, see readheader.m
%           for more detail on units etc.
% notfound = FSNs that were not opened because files were not found
%
% Created: 27.4.2004 in Hamburg - U. Vainio, e-mail: ulla.vainio@gmail.com
% Edited:
% 18.7.2007 Fine adjustments, comments. -UV
% 9.8.2007 Header data is read separately into structure with macro READHEADER.m -UV

% NOTE! This macro neads macros:
% READHEADER.M

nr = size(files);
A = zeros(256,256,max(nr)); % Initialised to speed up reading.

counter = 1; counternf = 1; notfound = 0;
for(l = 1:max(nr))
    name = sprintf('%s%g%s',filename,files(l),fileend);
    fid = fopen(name,'r');
    name1 = name;
    if(fid == -1) % Tries out also all filenames with zeros in between
        name = sprintf('%s0%g%s',filename,files(l),fileend);
        fid = fopen(name,'r');
        nameout = sprintf('%s0%g',filename,files(l));
     end;
     if(fid == -1)
        name = sprintf('%s00%g%s',filename,files(l),fileend);
        fid = fopen(name,'r');
        nameout = sprintf('%s0%g',filename,files(l));
     end;
     if(fid == -1)
        name = sprintf('%s000%g%s',filename,files(l),fileend);
        fid = fopen(name,'r');
        nameout = sprintf('%s0%g',filename,files(l));
     end;
     if(fid == -1)
        name = sprintf('%s0000%g%s',filename,files(l),fileend);
        fid = fopen(name,'r');
        nameout = sprintf('%s0%g',filename,files(l));
     end;
     if(fid ~= -1)
         % disp(name) % shows name that opened
         % If file was found, start reading:
         for(kk = 1:133) % disregard header, it is read afterwards with a separate macro
            temp = fgets(fid);
         end;

         mtemp = fscanf(fid,'%e',[8,8192]); % Read 2d matrix
         A(:,:,counter) = reshape(mtemp,256,256);  % Reading the matrix.
         fclose(fid);

         if(nargout>=2) % Read header only if it is requested.
           header(counter) = readheader(name); % Read header data
         end;
         counter = counter + 1;
     end;

     if(fid == -1) % File could not be opened:
         notfound(counternf) = files(l);
         counternf = counternf + 1;
         disp(sprintf('Skipping FSN %d. Check filename and path.\n',files(l)))
     end;

end;

if((counter-1) < max(nr)) % Removing the zero matrices left out from initialization
    B = A(:,:,1:(counter-1));
    clear A;
    A = B;
end;