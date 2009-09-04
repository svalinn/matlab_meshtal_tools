classdef SphCoorSys < CoordinateSystems
    %class that takes on CoordinateSystems but is used for only
    %spherical systems.  this is done becuase all 
    %coordinate systems are plotted differently
    properties
        org = []; %holds origin of cylindrical coordinates
        
    end
    methods
       function obj = CylCoorSys(coordinates, result, err, fName, nElem, ...
                                pType, nps, MCNP5TallyNum, numTal,talTyp,...
                                comment, el1,el2,el3,el4 origin) 
            
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
                args{10} = talTyp;
                args{11} = comment;
                args{12} = el1;
                args{13} = el2;
                args{14} = el3;
                args{15} = el4;
                
                
            end
            
            %note that coordinates hold r,phi, and theta and not x,y,z
            obj = obj@CoordinateSystems(args{:});
            obj.org = origin;
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
            fprintf(fid, ['  Cylinder origin at    ', num2str(obj.org),'\n']);
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
    end


end