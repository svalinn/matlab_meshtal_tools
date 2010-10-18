function MCNP5_man
% Created by Patrick Snouffer Spring 2008
% Uses the classes CoordinateSystems, XYZCoorSys, CylCoorSys, and SphCoorSys
% It also uses the function read_tallies.  This script reads in MCNP5 mesh
% files and then allows the user to add, average, and/or write out the
% final tallies in the same text format as the original files.  As the
% program reads in, adds, or averages the tallies, it saves each of the  
% tallies as a .mat file so the program does not over load.  
% A few things to note: 
%   ~ all user entered files should be without the extension
%   ~ there is no check to make sure that the tallies being added or
%       averaged are of the same size, coordinate system, or tally type
%   ~ when reading in files their names must be indexed without an
%       extension
%   ~ other functions can only be done to files that have been read in

% ReadIn=input('Do you want to read in new data (y or n)?: ','s'); disp(' ');
% 
% while (ReadIn =='y' || ReadIn == 'y')
%     
%     disp('Mesh files must be indexed, for example amesh1, amesh2 amesh3, etc...');
%     Name = input('Enter name of mesh files without index           : ','s');
%     nFiles= input('Enter number of files                            : ');
%     style = input('Enter 1 if you want tallies saved after each file: ');
%     disp(' ');
%     %add code so user can define starting index
%     read_tallies(Name, nFiles, style, );
%     ReadIn=input('Do you want to read in another file (y or n)?: ','s'); 
%     disp(' ');
% 
% end


option = 4;
while (option ~= 0)
    disp('Tally Menu');
    disp('1) read in mesh files');
    disp('2) add tallies');
    disp('3) average tallies');
    disp('4) multply tallies by a constant');
    disp('5) find the percent difference');
    disp('6) write tally to another file');
    disp('7) plot tally');
   
    disp('0) to exit');
    option = input('What do you want to do?: '); disp(' ');
    
    if option == 1
        
        disp('File format: ''root''''index'''); disp(' ');
        Name = input('Enter name of mesh files without index            : ','s');
        beg = input('Enter the starting file index                     : ');
        nFiles= input('Enter number of mesh files                        : ');
        style = input('Enter 1 if you want tallies saved after each file : ');
        
        
        disp(' ');
        
        read_tallies(Name, beg, nFiles, style);
        
        disp(' ');

    elseif option == 2
        %adds together all the specified tallies from each file.  Note this
        %is different than average.  Also notice that if it is desired to
        %have the final tally written to the same file as the rootfile then
        %include the appropiate index at the end of the output file name
        disp('File format: ''root''''fileIndex''"tally"''tallyIndex''.mat');
        disp(' ');
        
                 
        fileInfo = cell(3, 1);
        
              
        fileInfo{1,1} = input(['Enter the root file and fileIndex', ...
                               ' in above format  : '],'s');

        disp(' ');
        disp(['Tallies are numbered by the order they appear in the',...
               ' mesh file'])
        temp = input(['Enter the tallies to be added separated by a ',...
                        'space : '],'s');



        fileInfo{2,1} = strread(temp);
        disp(' ');
        fileInfo{3,1} = input(['Enter 1 if there is no tallyIndex '...
                           '                 : ']); 
        outF = input('Enter root output file name                        : '...
                        ,'s');
        disp(' ');
  
        
%         ex = 1;
%         while (ex ~=0 )
%             outFile = input(['Enter the root file output name', ...
%                              '             : '],'s'); 
%             
%             disp(' ');
%             ex = exist([outFile,'.mat'],'file');
%             if ex ~=0
%                 cho = input(['File ',outFile,'.mat already exist do you', ...
%                              ' want to over write it (y/n) : '],'s');
%                 if (cho == 'n')
%                     disp('Please choose another file name');
%                 else
%                     ex = 0;
%                 end
%             end
%                 
%         end
            
        fn = fileInfo(1,:);
        tallies = fileInfo(2,:);
        sty = fileInfo(3,:);
        total = CoordinateSystems();

        

        talIndex = tallies{1};
        if sty{1} ~= 1
            %need to add index to filenames b/c saved by tally
            for j = 1 : length(talIndex)
                if talIndex(j) ~= 0   
                    fName = strcat(fn{1},'tally', num2str(j), '.mat');
                    load(fName);   
                    total = total.AddResults(tally);
                end
            end
        else
            load([fn{1},'tally.mat']);
                
            for j = 1 : length(talIndex)

                mesh = tally(talIndex(j));
                    
                total = total.AddResults(mesh);
                    
            end
        end
        clear mesh tally 
            

        tally = total;
        save([outF,'tally.mat'], 'tally');
        clear total tally;
        disp(['Final tally saved as ', outF, 'tally.mat']); 
        disp(' ');
        
        %end of adding option
        
    elseif option == 3
        %this takes each tally index and averages it across indexed files
        %for ALL tallies in the files.  Note that the indexed files have to
        %have the same number of tallies in them.
        disp('File format: ''root''''fileIndex''"tally"''tallyIndex''.mat');
        disp(' ');
        name = input('Enter the name of the root tally files           : '...
                     ,'s');
        startF = input('Enter the starting file index                    : ');
        numFil = input('Enter the number of indexed files to be averaged : ');
        
        
%         tNum = input('Enter the number of tallies in each file         : ');
        style = input('Enter 1 if there is no tallyIndex                : ');        
        outF = input('Enter the root output file name                  : '...
                     ,'s');
        disp(' ');
        
        if style ~=1
            h = 1;
            ex = exist([name,num2str(startF),'tally1.mat'],'file');
            while(ex == 1)
%             for h = 1 : tNum
                average = CoordinateSystems();
                
                for g = startF : (numFil + startF - 1)

                    load([name,num2str(g),'tally',num2str(h),'.mat']);
                    average = average.AverageResults(tally);
                    clear tally;
                end
                h = h + 1;
                tally = average;
                ex = exist([name,num2str(startF),'tally',num2str(h), ...
                            '.mat'],'file');
                save([outF, 'tally', num2str(h),'.mat'],'tally');
                
                clear tally average;
            end
        else
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% test these loops
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
            load([name,num2str(startF),'tally.mat']);
            for h = 1 : length(tally)
                average = CoordinateSystems();
                
                for j = startF : (numFil + startF-1)
                    
                    load([name,num2str(j),'tally.mat']);
                    average = average.AverageResults(tally);
                    disp(average);
                    clear tally;
                end
                ave(h) = average;
                disp(ave);
                clear tally average;
            end
            tally = ave;
            save([outF,'tally.mat'],'tally');
            clear tally ave;
        end
        
        disp(['Tallies ',num2str(1),' through ',num2str(h),...
                ' were averaged over ']);
        disp([num2str(numFil),' files and saved with root file name ',outF]);
        disp(' ');
        
        %end of averaging option
        
        % not implemented for save by tally option yet
    elseif option == 4
        % this option takes in a constant from the user and multiplies
        % all the tallies in the file by it
        disp('Each file is multiplied by a different constant');
        disp('File format: ''root''''fileIndex''"tally"''tallyIndex''.mat');
        disp(' ');

        file = input('Enter root tally file to multply                : ','s');
        fIndex = input('Enter file index                                : ');
        numFile = input('Enter the number for files to multply           : ');
        mult = input('Enter multiplication factors delimed by a space : ','s');
        outF = input('Enter root output file name                     : ','s');
        disp(' ');
        
        
        mults = strread(mult);
        for j = 0 : numFile - 1
            load([file,num2str(fIndex + j),'tally.mat'])
            for i = 1 : length(tally)
                mal(i) = tally(i).Multiplier(mults(j+1));
            end
            tally = mal;
            save([outF,num2str(fIndex + j),'tally.mat'], 'tally');

            clear tally mal;
            disp(['Multiplied tallies of ', file, num2str(fIndex + j), ...
                  'tally.mat saved as ', outF, num2str(fIndex + j), ... 
                  'tally.mat']);
        end
        disp(' ');

    elseif option == 5 %only use with save after file option for benchmark
        % this takes the percent difference of a bench CoordinateSystem
        % object with all the other CoordinateSystem objects for all tallies
       % in the files
        disp('File format: ''root''''fileIndex''"tally"''tallyIndex''.mat');
        disp(' ');
        bName = input('Enter the root & fileIndex of the benchmark tally : '...
                        , 's');
        name = input('Enter the root of the tally files                 : '...
                        , 's');
        startF = input('Enter the starting file index                     : ');
        numFil = input('Enter the number of indexed files to be averaged  : ');
        
        
%        tNum = input('Enter the number of tallies in each file          : ');
        style = input('Enter 1 if there is no tallyIndex                 : ');        
        outF = input('Enter the root output file name                   : '...
                        ,'s');
        disp(' ');
  
        % load the benchmark meshes
        load([bName,'tally.mat']);
        %need to change back to tally when done with this
        bench = tally;
        clear tally;
        if style ~=1
            for g = startF : (numFil + startF - 1)
                 h = 1;
%                for h = 1 : tNum
                 ex = exist([name,num2str(g),'tally',num2str(h), ...
                            '.mat'],'file');
                 while( ex == 1)
                    load([name,num2str(g),'tally',num2str(h),'.mat']);
                    tally = tally.PercentDiff(bench(g));

                    save([outF,num2str(g),'tally',num2str(h),'.mat'],'tally');
                    clear tally diff;
                    disp(['% diff for ', name, num2str(g),'tally', ...
                        num2str(h),'.mat saved as', ' ', outF, ...
                        num2str(h), 'tally',num2str(h),'.mat']);
                    
                    h = h + 1;
                    ex = exist([name,num2str(g),'tally',num2str(h), ...
                            '.mat'],'file');
                end
            end
            disp(' ');
        else
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%% double check these
%%%%%%%%%%% test this 
            for h = startF : (numFil + startF-1)
                load([name,num2str(h),'tally.mat']);
                
                for j = 1 : length(tally)
                    diff(j) = tally(j).PercentDiff(bench(j));
                end
                tally = diff;
                save([outF,num2str(h),'tally.mat'],'tally');
                clear tally diff;
                disp(['% diff for ', name, num2str(h),'tally.mat saved as', ...
                      ' ', outF, num2str(h), 'tally.mat']);
                disp(' ');
                
            end
            disp(' ');
        end
    elseif option == 6
        
        fOut = input('What is the name of the file to be writen to?: ', 's');
        root = input('What is the file name of the tallies?   : ', 's');
        start = input('What is the starting tally index             : ');
        nT = input('How many tallies are to be written?          : ');
        sty = input('Are the tallies saves by file, 1 for yes     : ');
        disp(' ');
        
        %did not include save by file option becuase only writen again
        %after added or averaged so tallies are in files not in arrays
        
        
        cho = 'y';
        if exist(fOut, 'file') ~= 0
            cho = input(['Do you want to write to the end of file ',fOut,'?'...
                        '(y/n): '],'s'); 
        end
            
        if cho == 'y'
            if sty ~= 1
                for i = 1 : nT
                    load([root,num2str(start+i-1),'.mat']);
                    write2file(tally,fOut);
                end
                
                disp(['Tallies ',num2str(start), ' to ', num2str(start+nT-1), ...
                        ' were writen to ', fOut ]);
            else
                load([root,'.mat']);

                for i = start : (start + nT - 1)
                    write2file(tally(i),fOut);
               
                end
                disp(['Tallies ',num2str(start), ' to ', num2str(start+nT-1), ...
                        ' were writen to ', fOut ]);

            end
        else
            disp('No tallies were writen');            
        end
        disp(' ');
     %end of writing option
    
    elseif option == 7
       
       disp('this option is not implemented into this script yet');
       disp('');
        
    end
end
end



















