classdef XYZCoorSys < CoordinateSystems
    %class that takes on CoordinateSystems but is used for only cartesian
    %systems.  this is done becuase all coordinate systems are plotted
    %differently
    methods
       function obj = XYZCoorSys(coordinates, result, err, fName, nElem, ...
                          pType, nps, tallyNum, numTal,talTyp, comment,...
                          el1,el2,el3,el4) 
            
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
                args{10} = talTyp;
                args{11} = comment;
                args{12} = el1;
                args{13} = el2;
                args{14} = el3;
                args{15} = el4;
                                
            end
               obj = obj@CoordinateSystems(args{:});
       end
       
       function part = write2file(obj, fileN)
            
            
            fid = fopen(fileN, 'a');
            if ftell(fid) == 0
            
                fprintf(fid,'\n\n');
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
                part = 'proton';
            else
                part = 'photon1';
            end
          
            fprintf(fid, [' This is a ' part ' mesh tally.\n\n']);
          
            fprintf(fid, ' Tally bin boundaries:\n');
            fprintf(fid, '    X direction:');
            fprintf(fid, ['    ', obj.eBins1]); 
            fprintf(fid, '\n');
          
            fprintf(fid, '    Y direction:');
            fprintf(fid, ['    ', obj.eBins2]);
            fprintf(fid, '\n');
          
            fprintf(fid, '    Z direction:');
            fprintf(fid, ['    ', obj.eBins3]);
            fprintf(fid, '\n');
                  
            fprintf(fid, '    Energy bin boundaries:\n\n');
            fprintf(fid, [blanks(8) 'X' blanks(9) 'Y' blanks(9) 'Z     '...
                         ' Result     Rel Error\n']);
          
            temp(:,1:3)= obj.coordinates;
            temp(:,4) = obj.data;
            temp(:,5) = obj.err;
            
            fprintf(fid, '   %6.3f   %6.3f     %6.3f %12.5E %12.5E\n', temp');
               
            fclose(fid);
      
       end
        
     
       function plotXSlice(obj, Xconst, energy)
           figure; 
          Xcon = find(obj.coorBinsA == Xconst);
          if (length(obj.energyBins) == 1)
                eng = 1;
          elseif (energy == 0)
                eng = length(obj.energyBins) + 1;
          else             
                eng = find(obj.energyBins == energy);
          end
          Y = zeros(length(obj.coorBinsB), length(obj.coorBinsC));
          Z = zeros(length(obj.coorBinsB), length(obj.coorBinsC));
          offset = (eng -1) * obj.nElements;
          
          for j = 1 : length(obj.coorBinsB)
              Y(j,:) = obj.coorBinsA(j); % vector for R pos 
               
          end
          for k = 1 : length(obj.coorBinsC)
               Z(:,k) = obj.coorBinsC(k); % vecotr for theta pos 
          end
          
          
          % set up data now
          dat = zeros(size(Z));
          row = offset + (Xcon - 1) * length(obj.coorBinsB) * length(obj.coorBinsC);
          for i = 1 : (length(obj.coorBinsB) * length(obj.coorBinsC))
                
              dat(i,j) = obj.data(row + j);
              
          end
          [r,c] = size(dat);
          if (r == 1 || c == 1)
              Y(:,2) = Y(:,1);
              Z(:,2) = Z(:,1);
              dat(:,2) = dat(:,1);
          end
          mesh(Y,Z,dat);
           
       end


      % Yconst is where Y is sliced.  this will plot a mesh plot of the X, Z
      % plane at height with the data being on the Z axis of the plot
      % enter zero for total energy bin and omit it if there are no energy
      % bins
      function plotYSlice(obj, Yconst, energy)
          figure; 
          Ycon = find(obj.coorBinsB == Yconst);
          if (length(obj.energyBins) == 1)
                eng = 1;
          elseif (energy == 0)
                eng = length(obj.energyBins) + 1;
          else             
                eng = find(obj.energyBins == energy);
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
          mesh(X,Z,dat);
      end

      % plots an x,y mesh at a given theta
      % if energy = 0 then the total energy bin is plotted and if energy is
      % omitted then it is assumed that there are no energy bins so the
      % first one is plotted
      function plotZSlice(obj, Zconst, energy)
          figure;
          Zcon = find(obj.coorBinsC == Zconst);
          if (length(obj.energyBins) == 1)
                eng = 1;
          elseif (energy == 0)
                eng = length(obj.energyBins) + 1;
          else             
                eng = find(obj.energyBins == energy);
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
          mesh(X,Y,dat);
          title(['% difference at Z =', num2str(Zconst)]);
%           figure;
%           plot(Z(60,:),dat(60,:));

      end
       
       
    end


end