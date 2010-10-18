classdef CylCoorSys < CoordinateSystems
    %class that takes on CoordinateSystems but is used for only
    %cylindrincal systems.  this is done becuase all 
    %coordinate systems are plotted differently
    properties
        org = []; %holds origin of cylindrical coordinates
        axs = []; %holds axis of cylindrical coordinates
    end
    methods
       function obj = CylCoorSys(coordinates, result, err, fName, nElem, ...
                                pType, nps, MCNP5TallyNum, numTal,...
                                comment, el1, el2, el3, el4, origin, axis,...
                                eb1, eb2, eb3, eb4) 
            
            if nargin == 0
                args{1} = 0;
                args{2} = 0;
                args{3} = 0;
                args{4} = '';
                args{5} = 0;
                args{6} = 0;
                args{7} = 0;
                args{8} = 0;
                args{9} = 0;
                args{10} = 0;
                args{11} = '';
                args{12} = 0;
                args{13} = 0;
                args{14} = 0;
                args{15} = 0;
                args{16} = 0;
                args{17} = 0;
                args{18} = 0;
                
            else
                args{1} = coordinates;
                args{2} = result;
                args{3} = err;
                args{4} = fName;
                args{5} = nElem;
                args{6} = pType;
                args{7} = nps;
                args{8} = MCNP5TallyNum;
                args{9} = numTal;
                args{10} = comment;
                args{11} = el1;
                args{12} = el2;
                args{13} = el3;
                args{14} = el4;
                args{15} = eb1;
                args{16} = eb2;
                args{17} = eb3;
                args{18} = eb4;
                
                
            end
                 
            %note that coordinates hold r,z, and theta and not x,y,z
            obj = obj@CoordinateSystems(args{:});
            obj.org = origin;
            obj.axs = axis;
       end
       
       function part = write2file(obj, fileN)
            
            
            fid = fopen(fileN, 'a');
            if ftell(fid) == 0
            
                fprintf(fid,'mcnp version 5 \n');
                fprintf(fid,['\n Number of histories used for normalizing'...
                      ' tallies =      ' num2str(obj.nps) '\n']);
            end
            fprintf(fid,'\n');
            fprintf(fid, [' Mesh Tally Number ' num2str(obj.MCNPtallyNum)...
                                '\n']);
          
            fprintf(fid, obj.comment);
          
            if obj.particleType == 1
                part = 'neutron';
            elseif obj.particleType == 2
                part = 'photon';
            else
                part = 'electron';
            end
          
            fprintf(fid, [' This is a ', part, ' mesh tally.\n\n']);
          
            fprintf(fid, ' Tally bin boundaries:\n');
            fprintf(fid, '  Cylinder origin at ');
            fprintf(fid, '  %6.2E',obj.org);
            fprintf(fid, ', axis in  ');
            fprintf(fid, '%6.2E ', obj.axs);
            fprintf(fid, 'direction\n');
            
            fprintf(fid, '    R direction:');
            fprintf(fid, '    %6.2f', obj.coorBoundsA); 
            fprintf(fid, '\n');
            
            fprintf(fid, '    Z direction:');
            fprintf(fid, '    %6.2f', obj.coorBoundsB);
            fprintf(fid, '\n');
          
            fprintf(fid, '    Theta direction (revolutions):');
            fprintf(fid, '    %6.3f',obj.coorBoundsC);
            fprintf(fid, '\n');
            
            fprintf(fid, '    Energy bin boundaries:');
            fprintf(fid, ' %6.2E', obj.engBounds);
            fprintf(fid, '\n\n');
          
            if obj.particleType == 2
                loops = 1;
                % if only one energy bin there is no total
                if length(obj.data)/obj.nElements == 1
                    loops = 0;
                end
                endIndex = 0;
                
                for i = 0: (length(obj.data)/obj.nElements-2)*loops
                    startIndex = i*obj.nElements+1;
                    endIndex = (i+1)*obj.nElements;
                    temp(startIndex:endIndex,1) = obj.energyBins(i+1);
                    
                end               
                temp(:,2:4) = obj.coordinates(1:endIndex,:);
                temp(:,5) = obj.data(1:endIndex);
                temp(:,6) = obj.err(1:endIndex);disp(temp(16000,2:6));
                fprintf(fid, ['   Energy' blanks(9) 'R' blanks(9) 'Z' blanks(9) 'Th'...
                    blanks(4) 'Result' blanks(5) 'Rel Error\n']);
                for  i = 1 : length(temp)
                    fprintf(fid, '  %6.3E     %6.3f    %6.3f    %6.3f%12.5E%12.5E\n', temp(i,:));
                end
                if loops
                    last = length(obj.data);               
                    temp2(:,1:3) = obj.coordinates((endIndex+1):last,:);
                    temp2(:,4) = obj.data((endIndex+1):last);
                    temp2(:,5) = obj.err((endIndex+1):last);
                    for i = 1 : length(temp2)
                        fprintf(fid,'   %s       %6.3f    %6.3f    %6.3f%12.5E%12.5E\n', 'Total', temp2(i,:));
                    end
                end
                
            elseif length(obj.data)/obj.nElements ~= 1 %addes total to energy binned n tally
                lastbin = length(obj.data) - obj.nElements;
                temp(:,1:3) = obj.coordinates(1:lastbin,:);
                temp(:,4) = obj.data(1:lastbin,:);
                temp(:,5) = obj.err(1:lastbin,:);
                fprintf(fid, [blanks(8) 'R' blanks(9) 'Z' blanks(9) 'Th    '...
                         'Result     Rel Error\n']);
                fprintf(fid, '     %6.3f    %6.3f    %6.3f%12.5E%12.5E\n', temp');
                
                %now print total results
                last = length(obj.data);
                temp2(:,1:3) = obj.coordinates((lastbin+1):last,:);
                temp2(:,4) = obj.data((lastbin+1):last);
                temp2(:,5) = obj.err((lastbin+1):last);
                for i = 1 : length(temp2)
                    fprintf(fid,'   %s       %6.3f    %6.3f    %6.3f%12.5E%12.5E\n', 'Total', temp2(i,:));
                end
                
            else
                temp(:,1:3)= obj.coordinates;
                temp(:,4) = obj.data;
                temp(:,5) = obj.err;
                fprintf(fid, [blanks(8) 'R' blanks(9) 'Z' blanks(9) 'Th    '...
                         'Result     Rel Error\n']);
                fprintf(fid, '     %6.3f    %6.3f    %6.3f%12.5E%12.5E\n', temp');
                
            end
               
            fclose(fid);
      
       end
        
       
       % plots r vs phi for constant theta and z
       % height is a where to slice in z coord and theta is  between  0 and .5
       % Note theta will be revoled 180 degrees to get
       % -r to r.  Theta should be revolutions
       % enter zero for total energy bin and if energy is omitted then it
       % is assumed that there are no energy bins and the first on is used.
       % use this option if there are no energy bins
       function printed = plotThZSlice(obj, theta, height, energy)
           
           %find indies of height and theta in the coorBins to know where
           %to search in results and which coors to use
           thet = find(obj.coorBinsC == theta);
           thet2 = thet + floor(length(obj.coorBinsC)/2);
           high = find(obj.coorBinsB == height);
           
           if isempty(thet)
               disp('***** Cannot plot becuase of bad theta value');
               disp('Theta should be one of ');
               disp(num2str(obj.coorBinsC));
               disp(['but was ', num2str(theta)]);
               printed = 0;
               return;
           elseif isempty(high)
               disp('***** Cannot plot becuase of bad z value');
               disp('Z should be one of ');
               disp(num2str(obj.coorBinsB));
               disp(['but was ', num2str(height)]);
               printed = 0;
               return;
           end
           
           if (length(obj.energyBins) == 1)
                eng = 1;
           elseif (energy == 0)
                eng = length(obj.energyBins) + 1;
           else             
                eng = find(obj.energyBins == energy);
                if isempty(eng)
                    disp('***** Cannot plot becuase of bad energy value');
                    disp('Energy should be one of ');
                    disp(num2str(obj.energyBins));
                    disp(['but was ', num2str(eng)]);
                    printed = 0;
                    return;
                end
           end
           offset = (eng - 1) * obj.nElements;
           r = zeros(1, (length(obj.coorBinsA)*2));
           phi = zeros(1, (length(r)));
           
           for i = 1 : length(obj.coorBinsA)
                    % + theta bins
                    row1 = (i - 1) * length(obj.coorBinsB) * ...
                           length(obj.coorBinsC) + high * thet + offset;
                    r(length(obj.coorBinsA) + 1 - i) = obj.coordinates(row1,1);
                    phi(length(obj.coorBinsA) + 1 - i) = obj.data(row1);
                    
                    % - theta bins
                    row2 = (i - 1) * length(obj.coorBinsB) * ...
                            length(obj.coorBinsC) + high * thet2 + offset;
                    r(i+length(obj.coorBinsA)) = -(obj.coordinates(row2,1));
                    phi(i+length(obj.coorBinsA)) = obj.data(row2);
                
           end
           figure;
           plot(r,phi,'-');
           xlabel('radius');
           ylabel('Tally Data');
           printed = 1;
           
       end


      % height is where Z is sliced.  this will plot a mesh plot of the R, Theta
      % plane at height with the data being on the Z axis of the plot
      % enter zero for total energy bin and omit it if there are no energy
      % bins
      function printed = plotZSlice(obj, height, energy)
          high = find(obj.coorBinsB == height);
          
          if isempty(high)
               disp('***** Cannot plot becuase of bad z value');
               disp('Z should be one of ');
               disp(num2str(obj.coorBinsB));
               disp(['but was ', num2str(height)]);
               printed = 0;
               return;
          end
          
          if (length(obj.energyBins) == 1)
                eng = 1;
          elseif (energy == 0)
                eng = length(obj.energyBins) + 1;
          else             
                eng = find(obj.energyBins == energy);
                if isempty(eng)
                    disp('***** Cannot plot becuase of bad energy value');
                    disp('Energy should be one of ');
                    disp(num2str(obj.energyBins));
                    disp(['but was ', num2str(eng)]);
                    printed = 0;
                    return;
                end
          end
          
          R = zeros(length(obj.coorBinsA), length(obj.coorBinsC)+1);
          Th = zeros(length(obj.coorBinsA), length(obj.coorBinsC)+1);
          offset = (eng -1) * obj.nElements;
          
          for j = 1 : length(obj.coorBinsA)
              R(j,:) = obj.coorBinsA(j); % vector for R pos 
               
          end
          
          for k = 1 : length(obj.coorBinsC)
               Th(:,k) = obj.coorBinsC(k) .* 2 .* pi; % vecotr for theta pos 
          end
          Th(:,length(obj.coorBinsC)+1) = obj.coorBinsC(1).* 2 .* pi;
          
          [X,Y] = pol2cart(Th, R);
          % set up Z data now
          dat = zeros(size(Y));
          for i = 1 : length(obj.coorBinsA)
              row = (i - 1) * length(obj.coorBinsB) * length(obj.coorBinsC) ...
                    + (high -1) * length(obj.coorBinsC) + offset;
              
                
              for j = 1 : length(obj.coorBinsC)
                  dat(i,j) = obj.data(row + j);
              end
              dat(i,j+1) = obj.data(row+1);
              
          end
          
          
          
          figure;
          mesh(X,Y,dat);
          xlabel('x pos relative to meshtally');
          ylabel('Y pos relative to meshtally');
          zlabel('Tally Data');
          
          printed = 1;
      end

      % plots an r,z mesh at a given theta
      % if energy = 0 then the total energy bin is plotted and if energy is
      % omitted then it is assumed that there are no energy bins so the
      % first one is plotted
      function printed = plotThSlice(obj, theta, energy)
          thet = find(obj.coorBinsC == theta);
          thet2 = thet + floor(length(obj.coorBinsC)/2);
          
          if isempty(thet)
               disp('***** Cannot plot becuase of bad theta value');
               disp('Theta should be one of ');
               disp(num2str(obj.coorBinsC)) 
               disp(['but was ', num2str(theta)]);
               printed = 0;
               return;
          end
          
          if (length(obj.energyBins) == 1)
                eng = 1;
          elseif (energy == 0)
                eng = length(obj.energyBins) + 1;
          else             
                eng = find(obj.energyBins == energy);
                if isempty(eng)
                    disp('***** Cannot plot becuase of bad energy value');
                    disp('Energy should be one of ');
                    disp(num2str(obj.energyBins));
                    disp(['but was ', num2str(eng)]);
                    printed = 0;
                    return;
                end
          end
          
          a = length(obj.coorBinsA)*2;
          R = zeros(a, length(obj.coorBinsB));
          Z = zeros(a, length(obj.coorBinsB));
          offset = (eng - 1) * obj.nElements;
          
          for i = 1 : length(obj.coorBinsA)
               R(length(obj.coorBinsA) + 1 - i,:) = obj.coorBinsA(i);
%               R(i,:) = obj.coorBinsA(i);
               R(i + length(obj.coorBinsA),:) = -(obj.coorBinsA(i));
%               R(a - i + 1,:) = -(obj.coorBinsA(i));
          end
          for j = 1 : length(obj.coorBinsB)
              Z(:,j) = obj.coorBinsB(j);
          end
          dat = zeros(size(R));
          for k = 1 : length(obj.coorBinsA)
              for high = 1 : length(obj.coorBinsB)
                   % + theta bins
                   row1 = (k - 1) * length(obj.coorBinsB) * ...
                          length(obj.coorBinsC) + thet + ...
                          length(obj.coorBinsC) * (high - 1) + offset;
                      
                   dat(length(obj.coorBinsA) + 1 - k,high) = obj.data(row1);   
%                   dat(k,high) = obj.data(row1);
                   
                   % - theta bins
                   row2 = (k - 1) * length(obj.coorBinsB) * ...
                        length(obj.coorBinsC) + thet2 + ...
                        length(obj.coorBinsC) * (high - 1) + offset;                  
                   dat(k + length(obj.coorBinsA),high) = obj.data(row2);
%                   dat(a + 1 - k,high) = obj.data(row2);
              end
          end
          [r,c] = size(dat);
          if (r == 1 || c == 1)
              R(:,2) = R(:,1);
              Z(:,2) = Z(:,1);
              dat(:,2) = dat(:,1);
          end
          figure;
          mesh(R,Z,dat);
          xlabel('radius');
          ylabel('hieght');
          zlabel('Tally Data');
          
          printed = 1;

      end
    end


end






































