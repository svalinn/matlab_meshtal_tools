function MCNP5_script(s, type)
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

    disp(nargin);
    if nargin == 1
        usage();
    elseif strcmpi(type,'file')==1
        fid = fopen(s);


        while(~feof(fid))
            line = fgetl(fid);
            [word, last] = strtok(line);
            sc(word, last);
        end
    elseif strcmp(type,'command')
        [word, last] = strtok(s);
        sc(word, last);
    else
        usage();
    end
end
function usage()
    disp('ERROR: bad function call');
    disp('Usage: MCNP5_script(''input_script_name'',''file'') or');
    disp('       MCNP5_script(''single_command'',''command'')');
end
function sc(first, last)
    switch lower(first)
        case {'#',''}

        case 'read'
            disp('Reading meshtal files');
            sd = textscan(last, '%s %f %f %f');
            rootFile = char(sd{1});
            startF = sd{2};
            nFiles = sd{3};
            saveByFile = sd{4};

            if numel(saveByFile) == 0
                saveByFile = 1;
            end

            read_tallies(rootFile, startF, nFiles, saveByFile );
            clear sd rootFile startF nFiles saveByFile

        case 'add'
            disp('Adding tallies');
            [sd, last] =strtok(last);
            numFiles = str2double(sd);

            [sd, pos] = textscan(last, '%s', numFiles);
            fileNames = sd{1};

            sd = textscan(last(pos+1:end), '%f', 1);
            numTallies = sd{1,1};

            [sd, pos2] = textscan(last(pos+3:end), '%f', numTallies);
            tallyNums = sd{1};

            sd = textscan(last(pos+3+pos2:end), '%s %f');
            outFile = sd{1};
            style = sd{2};

            total = CoordinateSystems();
            % if files saved by index set up names 
            if (style ~= 1)
                for i = 1 : numFiles
                    for j = 1 : numTallies;

                        fName = strcat(fileNames{i}, 'tally', num2str(tallyNums{j}), '.mat');
                        load(fName);
                        total = total.AddResults(tally);
                        clear tally

                    end
                end
            else
                for i = 1 : numFiles;
                    fName = strcat(fileNames{i}, 'tally.mat');
                    load(fName);
                    for j = 1 : numTallies;
                        talNum = tallyNums(j);
                        mesh = tally(talNum);
                        total = total.AddResults(mesh);
                        clear mesh
                    end
                    clear tally
                end
            end


            if exist(strcat(outFile{1},'tally.mat'), 'file')
               load(strcat(outFile{1},'tally.mat'));
               tally(length(tally)+1) = total;
               save(strcat(outFile{1}, 'tally.mat'), 'tally');
               disp(['Fianl tally saved to file ', outFile{1},'tally.mat',...
                   ' in position ', num2str(length(tally))]);
            else
                tally = total;
                save(strcat(outFile{1}, 'tally.mat'), 'tally');
                disp(['Final tally saved as ', outFile{1}, 'tally.mat']);
            end
            disp(' ');

            clear tally total fName talNum style outFile numTallies fileNames numFiles sd

%             use modify this  code if want to be able to add different tally
%             positions from different files
%             [sd, pos] = textscan(last, '%f %f %f');
%             nF = sd{1};
%             style = sd{3};
%             formStr = '%s';
%             for i=1: sd{2};
%                 formStr = [formStr, ' %f'];
%             end
%             disp(formStr);
%             [sd, pos2] = textscan(last(pos+1:end), formStr, nF, 'CollectOutput', 1);
%             sd1 = textscan(last(pos+pos2+1:end), '%s');
%             files = sd{1};
%             talNums = sd{2};

        case 'average'
            disp('Averaging tallies');
            sd = textscan(last, '%s %f %f %s %f');
            rootF  = sd{1};
            startF = sd{2};
            numF = sd{3};
            outF = sd{4};
            style = sd{5};

            if style ~=1
                h = 1;
                ex = exist([rootF{1},num2str(startF),'tally1.mat'],'file');
                while(ex == 1)

                    average = CoordinateSystems();

                    for g = startF : (numF + startF - 1)

                        load([rootF{1},num2str(g),'tally',num2str(h),'.mat']);
                        average = average.AverageResults(tally);
                        clear tally;
                    end
                    h = h + 1;
                    tally = average;
                    ex = exist([rootF{1},num2str(startF),'tally',num2str(h), ...
                                '.mat'],'file');
                    save([outF{1}, 'tally', num2str(h),'.mat'],'tally');

                    clear tally average;
                end
            else

                load([rootF{1},num2str(startF),'tally.mat']);

                for h = 1 : length(tally)
                    average = CoordinateSystems();

                    for j = startF : (numF + startF-1)

                        load([rootF{1},num2str(j),'tally.mat']);
                        average = average.AverageResults(tally(h));
                        clear tally;
                    end
                    ave(h) = average;
                    clear tally average;
                end
                tally = ave;
                save([outF{1},'tally.mat'],'tally');
                clear tally ave;
            end

            disp(['Tallies ',num2str(1),' through ',num2str(h),...
                ' were averaged over ']);
            disp([num2str(numF),' files and saved with root file name ',outF{1}]);
            disp(' ');

            clear numF rootF ex h outF style startF sd

        %end of averaging case

        case 'mult'
            disp('Multipling tallies by constant');
            [sd, pos] = textscan(last, '%f %f');
            mult = sd{1};
            numFiles = sd{2};

            [sd, pos2] = textscan(last(pos+1:end), '%s', numFiles);
            fileNames = sd{1};

            sd = textscan(last(pos+pos2:end), '%f', 1);
            numTallies = sd{1};

            [sd, pos3] = textscan(last(pos+pos2+2:end), '%f', numTallies);
            tallyNums = sd{1};

            sd = textscan(last(pos+pos2+pos3+2:end), '%f');
            style = sd{1};

            if style ~=1
                for j = 0 : numFiles - 1
                    for i = 1 : numTallies
                        load([fileNames{j+1},'tally', num2str(tallyNums(i)), '.mat']);
                        tally = tally.Multiplier(mult);
                    end
                    k = strfind(fileNames{j+1},'mult');
                    if(isempty(k) || k(1) ~= 1)
                        save(['mult',fileNames{j+1},'tally', num2str(tallyNums(i)), '.mat'], 'tally');

                        disp(['Multiplied tally', fileNames{j+1},'tally', num2str(tallyNums(i)), '.mat'...
                            'by ', num2str(mult), ' and saved as mult',fileNames{j+1}, 'tally',...
                            num2str(tallyNums(i)), '.mat']);
                    else
                        save([fileNames{j+1},'tally.mat'], 'tally');

                        disp(['Multiplied tallies', str, 'of ', fileNames{j+1}, ...
                          'tally.mat saved as ',fileNames{j+1}, 'tally.mat']);
                    end
                    clear tally;
                end 
            else

                for j = 0 : numFiles - 1
                    load([fileNames{j+1},'tally.mat']);
                    str = ' ';
                    for i = 1 : numTallies
                        tally(tallyNums(i)) = tally(tallyNums(i)).Multiplier(mult);
                        str = [str, num2str(tallyNums(i)), ' '];
                    end
                    k = strfind(fileNames{j+1},'mult');
                    if(isempty(k) || k(1) ~= 1)
                        save(['mult',fileNames{j+1},'tally.mat'], 'tally');

                        disp(['Multiplied tallies', str, 'of ', fileNames{j+1}, ...
                          'tally.mat saved as mult',fileNames{j+1}, 'tally.mat']);
                    else
                        save([fileNames{j+1},'tally.mat'], 'tally');

                        disp(['Multiplied tallies', str, 'of ', fileNames{j+1}, ...
                          'tally.mat saved as ',fileNames{j+1}, 'tally.mat']);
                    end
                    clear tally;
                end                
            end
            disp(' ');
            clear fileNames tallyNums mult str k style sd numTallies numFiles pos pos2 pos3

        case 'percent' 
            disp('Finding percent differences of tallies');
            [sd, pos] = textscan(last, '%s %f', 1);
            bName = sd{1};
            numFiles = sd{2};

            [sd, pos2] = textscan(last(pos+1:end), '%s', numFiles);
            fileNames = sd{1};

            sd = textscan(last(pos+pos2:end), '%f', 1);
            numTallies = sd{1};

            [sd, pos3] = textscan(last(pos+pos2+2:end), '%f', numTallies);
            tallyNums = sd{1};

            sd = textscan(last(pos+pos2+pos3+2:end), '%f');
            style = sd{1};
            str1 = '';
            str2 = '';

            if style ~= 1

                for i = 1 : numTallies

                    load([bName{1}, 'tally',num2str(tallyNums(i)),'.mat']);
                    bench = tally;

                    for j = 1 : numFiles
                        load([fileNames{j},'tally',num2str(tallyNums(i)),'.mat']);
                        tally = tally.PercentDiff(bench);
                        save(['percent',fileNames{j},'tally',num2str(tallyNums(i)),'mat']);

                        if i == 1
                            str2 = [str2, ' ',fileNames{j}];
                        end
                        clear tally
                    end
                    clear bench
                    str1 = [str1, ' ', num2str(tallyNums(i))];
                end

                disp(['% difference taken for tallies ',str1, ' from files ', ...
                        str2]);

            else
                load([bName{1},'tally.mat']);
                bench = tally;

                for j = 1 : numFiles
                    load([fileNames{j},'tally.mat']);

                    for i = 1 : numTallies
                        tally(i)=tally(i).PercentDiff(bench(i));
                        if j == 1 
                            str1 = [str1, ' ', num2str(tallyNums(i))];
                        end
                    end
                    str2 = [str2, ' ',fileNames{j}];
                    save(['percent',fileNames{j},'tally.mat']);
                    clear tally
                end
                disp(['% difference taken for tallies ',str1, ' from files ', ...
                        str2]);
                clear bench
            end
            disp(' ');
            clear str1 str2 numTallies numFiles bName fileNames tallyNums sd pos pos2 pos3

        case 'write'
            disp('Writing tally');
            sd = textscan(last, '%s %s %f %f %f %f');
            outF = sd{1};
            fName = sd{2};
            start = sd{3};
            numTal = sd{4};
            writeOp = sd{5};
            style = sd{6};

            if exist(outF{1}, 'file') ~= 0
                if writeOp == 2
                    delete(outF{1})
                    disp(['File ', outF{1} ' will be overwritten']);
                elseif writeOp == 1
                    disp(['Tallies will be added to the end of file ', outF{1}]);
                else
                    disp(['***** ',outF{1},' exists and no overwrite or apend option was given', ...
                          ' so no tallies were written']);
                end
            end

            if style ~= 1 
                for i = start : (start + numTal - 1)
                    load([fName{1},'tally',num2str(i),'.mat']);
                    write2file(tally, outF{1});
                end
            else
                load([fName{1},'tally.mat']);
                for i = start : (start + numTal - 1)
                    write2file(tally(i), outF{1});
                end 
            end
            fin = start+numTal-1;
            disp(['Tallies ',num2str(start),' to ', num2str(fin), ...
                ' from ', char(fName) ,'tally.mat were written to ', outF{1}]);
            disp(' ');
            clear fName fin start outF numTal writeOp style sd

        case 'thzslice'
            sd = textscan(last, '%s  %f%f %f %f %f');
            fName = sd{1};
            talNum = sd{2};
            th = sd{3};
            z = sd{4};
            energy = sd{5};
            style = sd{6};

            if (th < 0 || th > 1)
                disp('***** Theta is not between 0 and 1. ');
                res = 0;

            elseif style ~=1
                load([fName{1},'tally',num2str(talNum),'.mat']);
                res = tally.plotThZSlice(th,z,energy);
            else
                load([fName{1},'tally.mat']);
                res = tally(talNum).plotThZSlice(th,z,energy);
            end
            if res == 0
                disp(['Tally ', num2str(talNum), ' from file ', fName{1}, ' was not plotted']);
                disp(' ');
            end            
            clear sd fName talNum th z energy style res            

        case 'thslice'
            sd = textscan(last, '%s %f %f %f %f');
            fName = sd{1};
            talNum = sd{2};
            th = sd{3};
            energy = sd{4};
            style = sd{5};

            if (th < 0 || th > 1)
                disp('Theta is not between 0 and 1. ');
                res = 0;
            elseif style ~=1
                load([fName{1},'tally',num2str(talNum),'.mat']);
                res = tally.plotThSlice(th,energy);
            else
                load([fName{1},'tally.mat']);
                res = tally(talNum).plotThSlice(th,energy);
            end
            if res == 0
                disp(['Tally ', num2str(talNum), ' from file ', fName{1}, ' was not plotted']);
                disp(' ');
            end            
            clear sd fName talNum th energy style res 

        case 'zslice'
            sd = textscan(last, '%s %f %f %f %f');
            fName = sd{1};
            talNum = sd{2};
            z = sd{3};
            energy = sd{4};
            style = sd{5};

            if style ~=1
                load([fName{1},'tally',num2str(talNum),'.mat']);
                res = tally.plotZSlice(z,energy);
            else
                load([fName{1},'tally.mat']);
                res = tally(talNum).plotZSlice(z,energy);
            end
            if res == 0
                disp(['Tally ', num2str(talNum), ' from file ', fName{1}, ' was not plotted']);
                disp(' ');
            end            
            clear sd fName talNum z energy style res

        case 'xslice'
            sd = textscan(last, '%s %f %f %f %f');
            fName = sd{1};
            talNum = sd{2};
            x = sd{3};
            energy = sd{4};
            style = sd{5};

            if style ~=1
                load([fName{1},'tally',num2str(talNum),'.mat']);
                res = tally.plotXSlice(x,energy);
            else
                load([fName{1},'tally.mat']);
                res = tally(talNum).plotXSlice(x,energy);
            end
            if res == 0
                disp(['Tally ', num2str(talNum), ' from file ', fName{1}, ' was not plotted']);
                disp(' ');
            end            
            clear sd fName talNum x energy style res

        case 'yslice'
            sd = textscan(last, '%s %f %f %f %f');
            fName = sd{1};
            talNum = sd{2};
            y = sd{3};
            energy = sd{4};
            style = sd{5};

            if style ~=1
                load([fName{1},'tally',num2str(talNum),'.mat']);
                res = tally.plotYSlice(y,energy);
            else
                load([fName{1},'tally.mat']);
                res = tally(talNum).plotYSlice(y,energy);
            end

            if res == 0
                disp(['Tally ', num2str(talNum), ' from file ', fName{1}, ' was not plotted']);
                disp(' ');
            end
            clear sd fName talNum y energy style res

        otherwise
            disp('Bad keyword! Acceptible keywords are:');
            disp('     read');
            disp('     add');
            disp('     average');
            disp('     mult');
            disp('     percent');
            disp('     write');
            disp('     thslice');
            disp('     zslice');
            disp('     thzslice');
            disp('     xslice');
            disp('     yslice');
    end
end
    
    



















