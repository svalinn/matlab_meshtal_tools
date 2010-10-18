function numTal = read_tallies (inFile, fStart, numFiles, saveByFile )
% read ins meshtal files and saves them as a coordinate object.  if
% saveByFile == 1 then the tallies in the same file will be saved as an
% array of CoordinateSystems object.  If saveByFile ~= 1 then the each 
%tally will be saved in it own file as a CoordinateSystem object 



numTal = zeros(1,numFiles);     


for fIndex = fStart: (numFiles + fStart - 1);
        talNum = 0;
        nps = 0;
        Tot = 1; % boolean for knowing whether to skip a line after this tally
        index = num2str(fIndex);
        fName = strcat(inFile, index);
        fid = fopen(fName);
        while (~feof(fid))  
            com = 1;
            talNum = talNum + 1;
            
            if(talNum ==1)
                ScanData=textscan(fid,'%*s %*s %*s %*s %*s %*s %*s %*s %f',1,...      
                    'headerlines',2);
                nps=ScanData{1};
                
                
                sd12 = textscan(fid,'%*d' , 'headerlines', 1); %skip 2 lines
            end

            if (Tot)
                sd2 = textscan(fid, '%*s %*s %*s %f', 1);
            else
                sd2 = textscan(fid, '%*s %*s %f',1);
            end
            Tot = 0;
%             disp('sd2');
%             disp(sd2);
            MCNP5TallyNum = sd2{1};
                        
            %first fgetl gets rid of newline char, this assumes only one
            %comment line
            fgetl(fid);
            comment = '';
            temp=1;
            while com==1
               
               line = fgets(fid);
               space = isspace(line);
               if temp == 1
%                    disp('line');
%                    disp(line)
                   
                  
%                    disp('length'); disp(length(space));
                   
               end
               if(length(space)>1 && space(2)==1)
                   comment = [comment,line];
                   if temp <= 4
                   
%                    disp(['Comment: ', comment]);
                   temp= temp+1;
                   end
                   
               else
%                    disp('in else for com');
                   com = 0;
                   
               end
            end
            
            %determine the particle type
%             disp(['second line ', line]);
            n = findstr(line,'neutron');
            p = findstr(line, 'photon');
            if(isempty(n)==0)
                pType = 1; %particle is a neutron
            elseif (isempty(p)==0)
                pType = 2; %particle is an photon
            else
                pType = 3; %particle is a electon
            end
            
            %determine the coordinate system of the mesh
            sd4 = textscan(fid, '%s %*s',1, 'headerlines', 2);
            coorSys = sd4{1};
             
            if strcmpi(coorSys, 'X')==1
                coorSys = 1; %the coordinate system is cartesian
                
            elseif strcmpi(coorSys, 'cylinder') == 1
                coorSys = 2; %the coordinate system is cylindrical
                org = textscan(fid,...
                    '%*s %f %f %f %*s %*s %*s %f %f %f %*s'...
                    ,1);
                origin = [org{1},org{2},org{3}];
                axis = [org{4}, org{5}, org{6}];
                %eats up first two words of the next line so coor bounds
                %can be read in
                sd12 = textscan(fid, '%s %*s',1);
            else
                coorSys = 3; %the coordinate system is spherical
        %need to check to make sure previous textscan doesnt move it a line ahead    
                org = textscan(fid, '%*s %f %f %f ',1,...
                               'delimiter', ', ');
                origin = [org{1},org{2},org{3}];
                %eats up first two words of the nest line so coor bounds
                %can be read in
                sd12 = textscan(fid, '%s %*s',1);
            end

            
                        
            %read in number of elements for each variable
            %should be set up so 
            fline1=fgetl(fid);
            
            %sets up array for actaul coordinate positions
            el1 = strread(fline1);
            elem1 = zeros(1,length(el1)-1);
            for i = 1 : length(elem1)
                 elem1(i) = roundn(el1(i) + (el1(i+1) - el1(i))/2,-2);
            end
            numElem1 = length(elem1);
                
                
            sd12 = textscan(fid, '%*s %*s',1);
            fline2 = fgetl(fid);
            el2 = strread(fline2);
            elem2 = zeros(1,length(el2)-1);
            for i = 1 : length(elem2)
                 elem2(i) = roundn(el2(i) + (el2(i+1) - el2(i))/2,-2);
            end
     %might need to put in if statement like for num3 if both
     %angles have extra word after diretion in input file
            numElem2 = length(elem2);
                

            if(coorSys == 2)
                sd12 = textscan(fid, '%*s %*s %*s',1);
            else
                sd12 = textscan(fid, '%*s %*s',1);
            end
            fline3 = fgetl(fid);
            el3 = strread(fline3);
            elem3 = zeros(1,length(el3)-1);
            for i = 1 : length(elem3)
                if (coorSys == 2)
                    elem3(i) = roundn(el3(i) + (el3(i+1) - el3(i))/2,-3);
                else
                    elem3(i) = roundn(el3(i) + (el3(i+1) - el3(i))/2,-2);
                end
            end
            numElem3 = length(elem3);
            numElem = numElem1 * numElem2 * numElem3;
            %added code to see how many energy bins there are
            sd12 = textscan(fid, '%*s %*s %*s',1);
            fline4 = fgetl(fid);
            el4 = strread(fline4);
            elem4 = zeros(1,length(el4)-1);
            for i = 1 : length(elem4)
                 elem4(i) = el4(i+1);
            end
            numElem4 = length(elem4);
            
            %numElem = numElem1 * numElem2 * numElem3 * numElem4;
                        
            sd12 = textscan(fid, '%s %*[^\n]',1 , 'headerlines', 1);
            eng = sd12{1};
            
            %sets up coor, data, and err for coorsys objects
            if strcmpi(eng, 'Energy') == 1 
               
                %need to account for extra energy column if particle is a
                %photon or if it is a neutron with an energy mesh
                numElemEng = numElem1 * numElem2 * numElem3 * numElem4;
                sd5 = textscan(fid, '%f %f %f %f %f %f %*[^\n]', numElemEng,  ...
                                'CollectOutput', 1);
                sd = sd5{1};
%                 disp(size(sd));
                %coordinates with A being the first varible, B the second, C
                %the third
                A = sd(:,2);
                B = sd(:,3);
                C = sd(:,4);

                result = sd(:,5);
                err = sd(:,6);     
                sd5 = textscan(fid, '%s %f %f %f %f %f %*[^\n]', numElem, ...
                                'CollectOutput', 1);
                % check to see if the energy bins are totaled
                if ~feof(fid)
                    
                    sd = sd5{2};
                    sd6 = sd5{1};
%                     disp(size(sd));
%                     disp('sd6');disp(sd6);
%                     disp('sd5');disp(sd5);
                    if strcmpi(sd6(1,1), 'Total') == 1
                        Tot = 1;
%                       disp(['tot = ', num2str(Tot)]);
                        totEnd = length(A) + numElem;
                    
                        A(length(A)+1:totEnd) = sd(:,1);
                        B(length(B)+1:totEnd) = sd(:,2);
                        C(length(C)+1:totEnd) = sd(:,3);
                    
                        result(length(result)+1:totEnd) = sd(:,4);
                        err(length(err)+1:totEnd) = sd(:,5);
                    
%                        disp(size(A));
                    end
                end
            elseif numElem4 > 2
                % for some reason no energy column but energy bins for
                % neutron mesh tallies
                numElemEng = numElem1 * numElem2 * numElem3 * numElem4;
                sd5 = textscan(fid, '%f %f %f %f %f %*[^\n]', numElemEng,  ...
                                'CollectOutput', 1);
                sd = sd5{1};
                A = sd(:,1);
                B = sd(:,2);
                C = sd(:,3);
                
                result = sd(:,4);
                err = sd(:,5);
                
                % check to see if the energy bins are totaled
                
                sd5 = textscan(fid, '%s %f %f %f %f %f %*[^\n]', numElem, ...
                                'CollectOutput', 1);
                sd = sd5{2};
                sd6 = sd5{1};
%                 disp(size(sd));disp(sd6(1,1));
%                 disp('sd5');disp(sd5);
                if strcmpi(sd6(1,1), 'Total') == 1
                    Tot = 1;%disp(['tot = ', num2str(Tot)]);
                    totEnd = length(A) + numElem;
                    
                    A(length(A)+1:totEnd) = sd(:,1);
                    B(length(B)+1:totEnd) = sd(:,2);
                    C(length(C)+1:totEnd) = sd(:,3);
                    
                    result(length(result)+1:totEnd) = sd(:,4);
                    err(length(err)+1:totEnd) = sd(:,5);
                    
%                     disp(size(A));
                end
            else
                Tot = 1;%disp('Tot = 1');
                sd5 = textscan(fid, '%f %f %f %f %f %*[^\n]', numElem,  ...
                                'CollectOutput', 1);
                sd = sd5{1};
%                 disp(size(sd));
                %coordinates with A being the first varible, B the second, C
                %the third
                A = sd(:,1);
                B = sd(:,2);
                C = sd(:,3);

                result = sd(:,4);
                err = sd(:,5);
            end
%             sd = sd5{1};
%             disp(size(sd));
%             %coordinates with A being the first varible, B the second, C
%             %the third
%             A = sd(:,1);
%             B = sd(:,2);
%             C = sd(:,3);
% 
%             result = sd(:,4);
%             err = sd(:,5);


            
            coordinates = zeros(length(A), 3 );
            coordinates(:,1) = A;
            coordinates(:,2) = B;
            coordinates(:,3) = C;
            
            if(coorSys == 1)
                meshes(talNum) = XYZCoorSys(coordinates, result, err,...
                   fName, numElem, pType, nps, MCNP5TallyNum, talNum,...
                    comment, elem1, elem2, elem3, elem4, el1, el2, el3 ,el4);
            elseif(coorSys == 2)
                meshes(talNum) = CylCoorSys(coordinates, result, err,...
                    fName, numElem, pType, nps, MCNP5TallyNum, talNum,...
                    comment, elem1, elem2, elem3, elem4, origin, axis,...
                    el1, el2, el3, el4);
            else
                meshes(talNum) = SphCoorSys(coordinates, result, err,...
                    fName, numElem, pType, nps, MCNP5TallyNum, talNum,...
                    comment, elem1, elem2, elem3, elem4, origin,...
                    el1, el2, el3, el4);
            end

            sd12 = textscan(fid,'%*d',1); %skip extra line after each tally

            
            if(saveByFile ~= 1)
               MeshTalliesFileName = [fName, 'tally', num2str(talNum),'.mat'];
               tally = meshes(talNum);
               save(MeshTalliesFileName, 'tally');
               disp(['Read in tally ', num2str(talNum), ' and saved as ',...
                     MeshTalliesFileName]);
            end
            
        end %while loop for tallies in each file
        if (saveByFile == 1)
            tally = meshes;
            MeshTalliesFileName = [fName,'tally.mat'];
            save(MeshTalliesFileName, 'tally');
           
            disp(['Read in ',num2str(talNum), ' tallies for file ',fName]);
            disp(['Saved as ', MeshTalliesFileName]);
        end
        
        fclose(fid);
        numTal(fIndex) = talNum;
        clear meshes tally;
        disp(' ')
        
end %for loop to go through each file


end