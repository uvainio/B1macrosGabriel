function [A,header,summed] = addfsnsstrict(filebeg,fsns,fileend,fieldinheader,valueoffield)

% function [A,header,summed] = addfsnsstrict(filebeg,fsns,fileend,fieldinheader,valueoffield)
%
% IN:
%
% Adds fsns together if in the header data the sample names,
% detector distances, and energies are the same
% The data of the first FSN is taken as the comparison for others.
% If some data does not have the same energy and distance as the first FSN,
% it is simply ignored.
% SPECIAL: Ignores data for which empty beam measurement
% was measured before injection and sample after injection (compares
% ring currents)
%
% Example of use: [A,header,summed] = addfsns('ORG',[245 249],'.DAT');
%
% Examples of more sophisticated use:
% [A,header,summed] = addfsns(filebeg,fsns,fileend,1);
% where 1 indicates that the program is allowed
% to add up data with different file names
%
% [A,header,summed] = addfsns(filebeg,fsns,fileend,'PosSample',21.6);
% By giving the sample position the file name
% is ignored and all measurents where sample stage was at position 21.6
% are added.
%
% OUT:
% A = matrix where all the matrices with correct headers were summed
% header = the FSNs of summed files
% summed = FSNs of summed files
% Prints also on the screen the details of the added files.
%
% Note: It is suggested that this macro is used only for sensitivity
% data and that sample measurements are united after integration
% because of possible beam position movements.
%
% Created 10.8.2007 Ulla Vainio
% In case of bugs, contact: ulla.vainio@desy.de or ulla.vainio@gmail.com
%

% Reading in files.
[Aorig,headerorig] = read2dB1data(filebeg,fsns,fileend);

if(length(fsns)==1) % Checking that we are actually adding something.
    A = Aorig; header = headerorig; % Nothing needs to be done..
    summed = fsns;
    disp('No adding necessary. Only one FSN was given.')
    return;
end;

titles = getfield(headerorig(1),'Title');
sizeA = size(Aorig);

for(k = 1:sizeA(3)) % Getting the header fields that we need or
                    % that need to changed if we add up the data
   if(k > 1)
      titles = strvcat(titles,getfield(headerorig(k),'Title'));
   end;
   energies(k) = getfield(headerorig(k),'Energy');
   distances(k) = getfield(headerorig(k),'Dist');
   rot1(k) = getfield(headerorig(k),'Rot1');
   rot2(k) = getfield(headerorig(k),'Rot2');
   possample(k) = getfield(headerorig(k),'PosSample');
   posref(k) = getfield(headerorig(k),'PosRef');
   current1(k) = getfield(headerorig(k),'Current1');
   empty(k) = getfield(headerorig(k),'FSNempty');
% Reading the empty beam data
   if(empty(k)==0)
      current2empty(k) = 0; % Taking care of fsns that are Empty beam measurements
   else
      headerempty = readheader(filebeg,empty(k),fileend);
      current2empty(k) = getfield(headerempty,'Current2');
   end;
end;

% Checking that current of empty beam measurement was larger than
% current during sample measurement. (Thus making sure there is no
% injection in between.)

A = zeros(sizeA(1,1)); % Initialising A.
ll = 1; % Initialising.
counter = 1;
disp('Added following data:')
for(k = 1:sizeA(3))
    % Adding the data if energy and distance are the same. (only if 4 input parameters are given)
    if(energies(k)==energies(1) && distances(k)==distances(1) && nargin == 4 && current2empty(k)>current1(k))
         A = A + Aorig(:,:,k); % Adding the data.
         ll(counter) = k;
         header(counter) = headerorig(k);
         getsamplenames(filebeg,fsns(k),'.DAT');
         counter = counter + 1;
      % Adding the data if sample name, energy, distance are the same (normal case):
    elseif(nargin == 3 && energies(k)==energies(1) && distances(k)==distances(1) && sum(double(titles(k,:)))==sum(double(titles(1,:))) && current2empty(k)>current1(k))
         if(rot1(k)~=rot1(1) || rot2(k)~=rot2(1)) % For safety it is checked.
            disp(sprintf('Warning! Rotation of sample in FSN %d (%s) is different from FSN %d (%s).',fsns(k),title(k),fsns(1),title(1)))
            disp(sprintf('Do you still want to add the data? (y/n)   '))
            scanf(temp);
            if(temp(1)~='y')
               return;
            end;
         end;
         if(posref(k)~=posref(1)) % For safety the position of reference sample is checked.
            disp(sprintf('Warning! Position of reference sample in FSN %d (%s) is different from FSN %d (%s).\n',fsns(k),title(k),fsns(1),title(1)))
            disp(sprintf('Do you still want to add the data? (y/n)   '))
            scanf(temp);
            if(temp(1)~='y')
               return;
            end;
         end;
         A = A + Aorig(:,:,k); 
         ll(counter) = k;
         header(counter) = headerorig(k);
         getsamplenames(filebeg,fsns(k),'.DAT');
         counter = counter + 1;
    % Adding with user specified criteria and energy and distance.
    elseif(nargin==5 && energies(k)==energies(1) && distances(k)==distances(1) && current2empty(k)>current1(k))
         if(sprintf('%d',getfield(headerorig(k),fieldinheader))==sprintf('%d',valueoffield))
            A = A + Aorig(:,:,k); 
            ll(counter) = k;
            header(counter) = headerorig(k);
            getsamplenames(filebeg,fsns(k),'.DAT');
            counter = counter + 1;
         end;
    end;
end;

 % Dealing with special cases:
 % Nothing to add was found. (input 3 or 4 parameters)
 if(length(ll)==1 && nargin<5)
    header = headerorig;
    A=Aorig(:,:,1);
end;
summed = fsns(ll);

% Nothing was found, user specified header field.
if(length(ll)==1 && nargin==5)
   disp(sprintf('No data found with %s as the specified value.',fieldinheader))
   A = 0;
   header = 0;
   summed = 0;
end;