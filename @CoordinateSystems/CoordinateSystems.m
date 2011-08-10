classdef CoordinateSystems 
    %parent class used to read in mcnp5 data files into coordinate[] and
    %performs other simple operations that are the same for all coordinate 
    %systems
    
    %added code to all for energy bins and save the coordinate bins for
    %easy look up
    properties
        coordinates = [];
        data = [];
        err = [];
        fName ='';
        nElements = []; 
        particleType = []; %1=neutron 2=photon 3=electron
        nps = []; %number of histories ran
        MCNPtallyNum = []; 
        nTallies = []; 
        comment = ''; %comment that was at the beginning of the file
        coorBinsA = [];
        coorBinsB = [];
        coorBinsC = [];
        energyBins = [];
        coorBoundsA = [];
        coorBoundsB = [];
        coorBoundsC = [];
        engBounds = [];
    end
    
    methods
        function obj = CoordinateSystems(coor, datas, errs, fileName, nElem,...
            pType,nPS,MCNPtallNum, numTalls, com, el1, el2, el3, el4, eb1, ...
            eb2, eb3, eb4)
            
            if nargin > 0
                obj.coordinates = coor;
                obj.data = datas;
                obj.err = errs;
                obj.fName = fileName;
                obj.nElements = nElem;
                obj.particleType = pType;
                obj.nps = nPS;
                obj.MCNPtallyNum = MCNPtallNum;
                obj.nTallies = numTalls;
                obj.comment = com;
                obj.coorBinsA = el1;
                obj.coorBinsB = el2;
                obj.coorBinsC = el3;
                obj.energyBins = el4;
                obj.coorBoundsA = eb1;
                obj.coorBoundsB = eb2;
                obj.coorBoundsC = eb3;
                obj.engBounds = eb4;
                
            end

        end
        
        function total = AverageResults(coor1, coor2)
            %calculates the weighted averages the data and err of two CoordinateSystem
            %objects and returns the average (a corrdinateSystems oject)
             
            if(isempty(coor2.data)==1) 
                total = coor1;
                
            elseif(isempty(coor1.data)==1)
                total = coor2;
                
            else
                
                total = coor2;
                
                npsAvg = coor1.nps + coor2.nps;
                
                total.data = (coor1.data *coor1.nps + coor2.data...
                                *coor2.nps)/npsAvg;
                
                
                total.err = (((coor1.data .*coor1.err * coor1.nps).^2 + ...
                    (coor2.data .*coor2.err *coor2.nps).^2).^.5)...
                    ./(coor1.data * coor1.nps + coor2.data *coor2.nps);
                
                %remove any non numbers and infinities
                total.err( isnan(total.err) | isinf(total.err) ) = 0;
                
                total.nps = npsAvg;
            end
            
            
        end
        
        %check to see if order matters for parameters
        % add the data and calculated the added errors of two CoordinateSystems
        % objects
        function tot = AddResults(coor1, coor2)
            
            if(isempty(coor2.data)==1)
                              
                tot = coor1;
                
            elseif(isempty(coor1.data)==1)
                
                tot = coor2;
            else
                tot = coor2;
                tot.data = coor1.data + coor2.data;
                tot.err = (( (coor1.data .* coor1.err).^2 + (coor2.data ...
                    .*coor2.err).^2 ).^0.5)./ (coor1.data + coor2.data);
                
                %remove any non numbers and infinities
                tot.err( isnan(tot.err) | isinf(tot.err) ) = 0;
            end
        end

        function diff = PercentDiff(coor, ben)
            diff = coor;
            diff.data = (coor.data - ben.data) ./ ben.data;
            diff.err=((coor.data .*ben.data .* ben.err).^2+(coor.err .*...
                        coor.data .* ben.data).^2).^0.5 ./ ben.data.^2;
            diff.data( isnan(diff.data) | isinf(diff.data) ) = 0;       
            diff.err( isnan(diff.err) | isinf(diff.err) ) = 0;
            
            [mDiff, ind] = max(diff.data);
            mCoors = diff.coordinates(ind,:);
            mErr = diff.err(ind);
            disp(['The max percent difference is ', num2str(mDiff)]);
            disp(['and it is at ', num2str(mCoors), ' with an error of '...
                  , num2str(mErr)]);
              
            [mDiffm, indm] = min(diff.data);
            mCoorsm = diff.coordinates(indm,:);
            mErrm = diff.err(indm);
            disp(['The min percent difference is ', num2str(mDiffm)]);
            disp(['and it is at ', num2str(mCoorsm), ' with an error of '...
                  , num2str(mErrm)]);  
            disp(' ');
       end

       % this takes a constant, mult, and multplies the data of a 
       % CoordinateSystems object by it and returns the restult
       function multplied = Multiplier(coor, mult)
          multplied = coor;
          multplied.data = coor.data .* mult;
       end
       
       % RCG  7/20/11
       % reduces the mesh of a CoordinateSystems object to fit within 
       % the bounding box [dAmin dAmax] [dBmin dBmax] [dCmin dCmax]
       % dA is relative to coorBinsA, etc., meaning center of bin coord.
       % and attempts to carefully trim the tally bin boundaries
       % (might work for all coord. systems, only tested for XYZ)
       function coortm = TrimMesh(coor,dA,dB,dC)
           coortm = coor;
           r = find((coor.coordinates(:,1)>=dA(1))&(coor.coordinates(:,1)<=dA(2))...
                   &(coor.coordinates(:,2)>=dB(1))&(coor.coordinates(:,2)<=dB(2))...
                   &(coor.coordinates(:,3)>=dC(1))&(coor.coordinates(:,3)<=dC(2)));
           coortm.nElements = length(r);
           coortm.coordinates=[];
           coortm.data=[];
           coortm.err=[];
           for i = 1 : coortm.nElements
               coortm.coordinates(i,:) = coor.coordinates(r(i),:);
               coortm.data(i) = coor.data(r(i));
               coortm.err(i) = coor.err(r(i));
           end
           
           r = find(coor.coorBinsA>=dA(1) & coor.coorBinsA<=dA(2));
           numbins = length(r);
           coortm.coorBinsA=[];
           for i = 1 : numbins
               coortm.coorBinsA(i) = coor.coorBinsA(r(i));
           end
           r = find(coor.coorBinsB>=dB(1) & coor.coorBinsB<=dB(2));
           numbins = length(r);
           coortm.coorBinsB=[];
           for i = 1 : numbins
               coortm.coorBinsB(i) = coor.coorBinsB(r(i));
           end
           r = find(coor.coorBinsC>=dC(1) & coor.coorBinsC<=dC(2));
           numbins = length(r);
           coortm.coorBinsC=[];
           for i = 1 : numbins
               coortm.coorBinsC(i) = coor.coorBinsC(r(i));
           end           
           
           coortm.coorBoundsA=[];
           j=1;
           for i = 1 : (length(coor.coorBoundsA)-1)
               x1 = coor.coorBoundsA(i);
               x2 = coor.coorBoundsA(i+1);
               x3 = roundn(x1+(x2-x1)/2,-2);
               if x3>=dA(1)
                   coortm.coorBoundsA(j) = coor.coorBoundsA(i);
                   j=j+1;
               end
               if x3>=dA(2)
                   coortm.coorBoundsA(j) = coor.coorBoundsA(i+1);
                   break;
               end
           end         
           coortm.coorBoundsB=[];
           j=1;
           for i = 1 : (length(coor.coorBoundsB)-1)
               x1 = coor.coorBoundsB(i);
               x2 = coor.coorBoundsB(i+1);
               x3 = roundn(x1+(x2-x1)/2,-2);
               if x3>=dB(1)
                   coortm.coorBoundsB(j) = coor.coorBoundsB(i);
                   j=j+1;
               end
               if x3>=dB(2)
                   coortm.coorBoundsB(j) = coor.coorBoundsB(i+1);
                   break;
               end
           end         
           coortm.coorBoundsC=[];
           j=1;
           for i = 1 : (length(coor.coorBoundsC)-1)
               x1 = coor.coorBoundsC(i);
               x2 = coor.coorBoundsC(i+1);
               x3 = roundn(x1+(x2-x1)/2,-2);
               if x3>=dC(1)
                   coortm.coorBoundsC(j) = coor.coorBoundsC(i);
                   j=j+1;
               end
               if x3>=dC(2)
                   coortm.coorBoundsC(j) = coor.coorBoundsC(i+1);
                   break;
               end
           end         
       end
       
       %finds where the data is greater than some number cutOff
       function lPercDiff = LargePercentDiffs(obj, cutOff)
           r = find(obj.data >= cutOff);
           lPercDiff = zeros(length(r),5);
           for i = 1 : length(r)
               lPercDiff(i,1) = obj.coordinates(r(i),1);
               lPercDiff(i,2) = obj.coordinates(r(i),2);
               lPercDiff(i,3) = obj.coordinates(r(i),3);
               lPercDiff(i,4) = obj.data(r(i));
               lPercDiff(i,5) = obj.err(r(i));
           end
       end
                
    end
    
        
end