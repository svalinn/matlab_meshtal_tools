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
        particleType = []; %1=neutron 2=proton 3=photon
        nps = []; %number of histories ran
        MCNPtallyNum = []; 
        nTallies = []; 
        tallyType = []; 
        comment = ''; %comment that was at the beginning of the file
        coorBinsA = [];
        coorBinsB = [];
        coorBinsC = [];
        energyBins = [];
    end
    
    methods
        function obj = CoordinateSystems(coor, datas, errs, fileName, nElem,...
            pType,nPS,MCNPtallNum, numTalls, com, el1, el2, el3, el4)
            
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
                
            end

        end
        
        function total = AverageResults(coor1, coor2)
            %calculates the weighted averages the data and err of two CoordinateSystem
            %objects and returns the average (a corrdinateSystems oject)
             
            if(isempty(coor1.data)==1) 
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
        
       function lPercDiff = LargePercentDiffs(obj)
           r = find(obj.data >= .1);
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