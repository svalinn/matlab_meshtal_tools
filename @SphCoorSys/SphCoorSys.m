classdef SphCoorSys < CoordinateSystems
    %class that takes on CoordinateSystems but is used for only
    %spherical systems.  this is done becuase all 
    %coordinate systems are plotted differently
    properties
        org = []; %holds origin of cylindrical coordinates
        
    end
    methods
       function obj = CylCoorSys(coordinates, result, err, fName, nElem, ...
                                pType, nps, MCNP5TallyNum, numTal,...
                                comment, el1,el2,el3,el4, eb1, eb2, eb3, ...
                                eb4, origin) 
            
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
            
            %note that coordinates hold r,phi, and theta and not x,y,z
            obj = obj@CoordinateSystems(args{:});
            obj.org = origin;
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
          
            fprintf(fid, [' This is a ' part ' mesh tally.\n\n']);
          
            fprintf(fid, [' This is a ', part, ' mesh tally.\n\n']);
          
            fprintf(fid, ' Tally bin boundaries:\n');
            fprintf(fid, '  Cylinder origin at ');
            fprintf(fid, '  %6.2E',obj.org);
            fprintf(fid, '\n');
            
            fprintf(fid, '    R direction:');
            fprintf(fid, '    %6.2f', obj.coorBoundsA); 
            fprintf(fid, '\n');
            
            fprintf(fid, '    Phi direction:');
            fprintf(fid, '    %6.2f', obj.coorBoundsB);
            fprintf(fid, '\n');
          
            fprintf(fid, '    Theta direction (revolutions):');
            fprintf(fid, '   %6.3f',obj.coorBoundsC);
            fprintf(fid, '\n');
            
            fprintf(fid, '    Energy bin boundaries:');
            fprintf(fid, '%6.3E', obj.engBounds);
            fprintf(fid, '\n\n');
            
            if obj.particleType == 2
                temp(1:length(obj.data),1) = obj.energyBins;
                temp(:,2:4) = obj.coordinates;
                temp(:,5) = obj.data;
                temp(:,6) = obj.err;
                fprintf(fid, ['   Energy' blanks(9) 'X' blanks(9) 'Y' blanks(9) 'Z'...
                    blanks(4) 'Result' blanks(5) 'Rel Error\n']);
                fprintf(fid, '  %6.3E     %6.3f   %6.3f     %6.3f %12.5E %12.5E\n', temp');
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
    end


end