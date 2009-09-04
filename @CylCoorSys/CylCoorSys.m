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
                                comment, el1, el2, el3, el4, origin, axis) 
            
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
                args{8} = MCNP5TallyNum;
                args{9} = numTal;
                args{10} = comment;
                args{11} = el1;
                args{12} = el2;
                args{13} = el3;
                args{14} = el4;
                
                
            end
                 
            %note that coordinates hold r,z, and theta and not x,y,z
            obj = obj@CoordinateSystems(args{:});
            obj.org = origin;
            obj.axs = axis;
       end
       
       function part = write2file(obj, fileN)
            
            
            fid = fopen(fileN, 'a');
            if ftell(fid) == 0
            
                fprintf(fid,'\n\n');
                fprintf(fid,[' Number of histories used for normalizing'...
                      ' tallies =      ' num2str(obj.nps) '\n']);
            end
            fprintf(fid,'\n');
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
            fprintf(fid, ['  Cylinder origin at    ', num2str(obj.org),...
                            ', axis in  ', num2str(obj.axs),' direction\n']);
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
        
       
       % plots r vs phi for constant theta and z
       % height is a where to slice in z coord and theta is  between  0 and .5
       % Note theta will be revoled 180 degrees to get
       % -r to r.  Theta should be revolutions
       % enter zero for total energy bin and if energy is omitted then it
       % is assumed that there are no energy bins and the first on is used.
       % use this option if there are no energy bins
       function plotThZSlice(obj, theta, height, energy)
           figure;
           %find indies of height and theta in the coorBins to know where
           %to search in results and which coors to use
           thet = find(obj.coorBinsC == theta);
           thet2 = find(obj.coorBinsC == (theta + .5));
           high = find(obj.coorBinsB == height);
           if (length(obj.energyBins) == 1)
                eng = 1;
          elseif (energy == 0)
                eng = length(obj.energyBins) + 1;
          else             
                eng = find(obj.energyBins == energy);
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
           plot(r,phi,'-');
           title(['% difference at Z =', num2str(height), ' and theta = ',...
                    num2str(theta)]);
           xlabel('radius');
           ylabel('% diff');
           
       end


      % height is where Z is sliced.  this will plot a mesh plot of the R, Theta
      % plane at height with the data being on the Z axis of the plot
      % enter zero for total energy bin and omit it if there are no energy
      % bins
      function plotZSlice(obj, height, energy)
          figure; 
          high = find(obj.coorBinsB == height);
          if (length(obj.energyBins) == 1)
                eng = 1;
          elseif (energy == 0)
                eng = length(obj.energyBins) + 1;
          else             
                eng = find(obj.energyBins == energy);
          end
          R = zeros(length(obj.coorBinsA), length(obj.coorBinsC));
          Th = zeros(length(obj.coorBinsA), length(obj.coorBinsC));
          offset = (eng -1) * obj.nElements;
          
          for j = 1 : length(obj.coorBinsA)
              R(j,:) = obj.coorBinsA(j); % vector for R pos 
               
          end
          for k = 1 : length(obj.coorBinsC)
               Th(:,k) = obj.coorBinsC(k) .* 2 .* pi; % vecotr for theta pos 
          end
          
          [X,Y] = pol2cart(Th, R);
          % set up Z data now
          dat = zeros(size(Y));
          for i = 1 : length(obj.coorBinsA)
              row = (i - 1) * length(obj.coorBinsB) * length(obj.coorBinsC) ...
                    + (high -1) * length(obj.coorBinsC) + offset;
                
              for j = 1 : length(obj.coorBinsC)
                  dat(i,j) = obj.data(row + j);
              end

              
          end
          mesh(X,Y,dat);
          title(['% difference at Z =', num2str(height)]);
          xlabel('x pos relative to meshtally');
          ylabel('Y pos relative to meshtally');
          zlabel('% diff');
      end

      % plots an r,z mesh at a given theta
      % if energy = 0 then the total energy bin is plotted and if energy is
      % omitted then it is assumed that there are no energy bins so the
      % first one is plotted
      function plotThSlice(obj, theta, energy)
          figure;
          thet = find(obj.coorBinsC == theta);
          thet2 = find(obj.coorBinsC == (theta + 0.5));
          if (length(obj.energyBins) == 1)
                eng = 1;
          elseif (energy == 0)
                eng = length(obj.energyBins) + 1;
          else             
                eng = find(obj.energyBins == energy);
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
          mesh(R,Z,dat);
          title(['% difference at theta =', num2str(theta)]);
          xlabel('radius');
          ylabel('hieght');
          zlabel('% diff');

      end
    end


end






































