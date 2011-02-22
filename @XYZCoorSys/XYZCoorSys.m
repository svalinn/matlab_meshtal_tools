classdef XYZCoorSys < CoordinateSystems
    %class that takes on CoordinateSystems but is used for only cartesian
    %systems.  this is done becuase all coordinate systems are plotted
    %differently
    methods
       function obj = XYZCoorSys(coordinates, result, err, fName, nElem, ...
                          pType, nps, tallyNum, numTal, comment,...
                          el1,el2,el3,el4, eb1, eb2, eb3, eb4) 
            
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
                args{10} = '';
                args{11} = 0;
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
                args{8} = tallyNum;
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
               obj = obj@CoordinateSystems(args{:});
       end
       
       function part = write2file(obj, fileN)
            
            
            fid = fopen(fileN, 'a');
            if ftell(fid) == 0
            
                fprintf(fid,'mcnp version 5 \n\n');
                fprintf(fid,[' Number of histories used for normalizing'...
                      ' tallies =      ' num2str(obj.nps) '\n']);
              
            end
            fprintf(fid, ' \n');
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
          
            fprintf(fid, [' This is a ' part ' mesh tally.\n\n']);
          
            fprintf(fid, ' Tally bin boundaries:\n');
            fprintf(fid, '    X direction:');
            fprintf(fid, '    %6.2f', obj.coorBoundsA); 
            fprintf(fid, '\n');
          
            fprintf(fid, '    Y direction:');
            fprintf(fid, '    %6.2f', obj.coorBoundsB);
            fprintf(fid, '\n');
          
            fprintf(fid, '    Z direction:');
            fprintf(fid, '    %6.2f', obj.coorBoundsC);
            fprintf(fid, '\n');
                  
            fprintf(fid, '    Energy bin boundaries:');
            fprintf(fid, '%6.3E', obj.engBounds);
            fprintf(fid, '\n\n');
            
            if obj.particleType == 2
                loops = 1;
                
                if length(obj.data)/obj.nElements == 1
                    loops = 0;
                end
                endIndex = 0;
                
                for i = 0 : (length(obj.data)/obj.nElements-2)*loops
                    startIndex = i*obj.nElements+1;
                    endIndex = (i+1)*obj.nElements;
                    temp(startIndex:endIndex,1) = obj.energyBins(i+1);
                    
                end 
                temp(:,2:4) = obj.coordinates(1:endIndex,:);
                temp(:,5) = obj.data(1:endIndex);
                temp(:,6) = obj.err(1:endIndex);disp(temp(16000,2:6));
                fprintf(fid, ['   Energy' blanks(9) 'X' blanks(9) 'Y' blanks(9) 'Z'...
                    blanks(5) 'Result' blanks(5) 'Rel Error\n']);
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
                fprintf(fid, [blanks(8) 'X' blanks(9) 'Y' blanks(9) 'Z     '...
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
                fprintf(fid, [blanks(8) 'X' blanks(9) 'Y' blanks(9) 'Z    '...
                         ' Result     Rel Error\n']);
                fprintf(fid, '   %6.3f   %6.3f     %6.3f %12.5E %12.5E\n', temp');
            end
               
            fclose(fid);
      
       end
        
     
       function printed = plotXSlice(obj, Xconst, energy)
           
          Xcon = find(obj.coorBinsA == Xconst);
          if isempty(Xcon)
               disp('***** Cannot plot becuase of bad x value');
               disp('X should be one of ');
               disp(num2str(obj.coorBinsA));
               disp(['but was ', num2str(Xconst)]);
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
          
          Y = zeros(length(obj.coorBinsB), length(obj.coorBinsC));
          Z = zeros(length(obj.coorBinsB), length(obj.coorBinsC));
          offset = (eng -1) * obj.nElements;
          
          for j = 1 : length(obj.coorBinsB)
              Y(j,:) = obj.coorBinsB(j); % vector for R pos 
               
          end
          for k = 1 : length(obj.coorBinsC)
               Z(:,k) = obj.coorBinsC(k); % vecotr for theta pos 
          end
          
          
          % set up data now
          dat = zeros(size(Z));
         
          for i = 1 : (length(obj.coorBinsB) )
	      row = offset + (Xcon - 1) *  length(obj.coorBinsB) * length(obj.coorBinsC) ...
                           + (i-1)*length(obj.coorBinsC);
              for j = 1 : length(obj.coorBinsC)
                 dat(i,j) = obj.data(row + j);
              end              

          end
          [r,c] = size(dat);
          if (r == 1 || c == 1)
              Y(:,2) = Y(:,1);
              Z(:,2) = Z(:,1);
              dat(:,2) = dat(:,1);
          end
          figure;
          mesh(Y,Z,dat);
          printed = 1;
           
       end


      % Yconst is where Y is sliced.  this will plot a mesh plot of the X, Z
      % plane at height with the data being on the Z axis of the plot
      % enter zero for total energy bin and omit it if there are no energy
      % bins
      function printed = plotYSlice(obj, Yconst, energy)
          
          Ycon = find(obj.coorBinsB == Yconst);
          if isempty(Ycon)
               disp('***** Cannot plot becuase of bad y value');
               disp('Y should be one of ');
               disp(num2str(obj.coorBinsB));
               disp(['but was ', num2str(Yconst)]);
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
          X = zeros(length(obj.coorBinsA), length(obj.coorBinsC));
          Z = zeros(length(obj.coorBinsA), length(obj.coorBinsC));
          offset = (eng -1) * obj.nElements;
          
          for j = 1 : length(obj.coorBinsA)
              X(j,:) = obj.coorBinsA(j); % vector for R pos 
               
          end
          for k = 1 : length(obj.coorBinsC)
               Z(:,k) = obj.coorBinsC(k); % vecotr for theta pos 
          end
          
          
          % set up data now
          dat = zeros(size(Z));
          for i = 1 : length(obj.coorBinsA)
              row = (i - 1) * length(obj.coorBinsB) * length(obj.coorBinsC) ...
                    + (Ycon -1) * length(obj.coorBinsC) + offset;
                
              for j = 1 : length(obj.coorBinsC)
                  dat(i,j) = obj.data(row + j);
              end

              
          end
          [r,c] = size(dat);
          if (r == 1 || c == 1)
              X(:,2) = X(:,1);
              Z(:,2) = Z(:,1);
              dat(:,2) = dat(:,1);
          end
          figure;
          mesh(X,Z,dat);
          printed = 1;
      end

      % plots an x,y mesh at a given theta
      % if energy = 0 then the total energy bin is plotted and if energy is
      % omitted then it is assumed that there are no energy bins so the
      % first one is plotted
      function printed = plotZSlice(obj, Zconst, energy)
          
          Zcon = find(obj.coorBinsC == Zconst);
          if isempty(Zcon)
               disp('***** Cannot plot becuase of bad z value');
               disp('Z should be one of ');
               disp(num2str(obj.coorBinsC));
               disp(['but was ', num2str(Zconst)]);
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
          X = zeros(length(obj.coorBinsA), length(obj.coorBinsB));
          Y = zeros(length(obj.coorBinsA), length(obj.coorBinsB));
          offset = (eng - 1) * obj.nElements;
          
          for i = 1 : length(obj.coorBinsA)
               X(i,:) = obj.coorBinsA(i);
          end
          for j = 1 : length(obj.coorBinsB)
              Y(:,j) = obj.coorBinsB(j);
          end
          dat = zeros(size(X));
          for k = 1 : length(obj.coorBinsA)
              for j = 1 : length(obj.coorBinsB)
                   % set up data
                   row = (k - 1) * length(obj.coorBinsB) * ...
                          length(obj.coorBinsC) + Zcon + ...
                          length(obj.coorBinsC) * (j - 1) + offset;
                   dat(k,j) = obj.data(row);
                   
              end
          end
          [r,c] = size(dat);
          if (r == 1 || c == 1)
              X(:,2) = X(:,1);
              Y(:,2) = Y(:,1);
              dat(:,2) = dat(:,1);
          end
          figure;
          mesh(X,Y,dat);
          printed = 1;

      end
       
       
    end


end
