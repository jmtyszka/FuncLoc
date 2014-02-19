function cleaned = check_times(direc)
%function cleaned = cleaner_analysis(direc)
%This script will cycle through the directories containing my existing data
%and will pull out key information used in analysis, create a structure,
%and save it as part of the original .mat data file

%get directory info
d = dir(direc);
for i = 1:length(d)
    if d(i).isdir && (~strcmp(d(i).name,'.') && ~strcmp(d(i).name,'..'))
        c(i) = check_times([direc filesep d(i).name]);
    elseif regexp(d(i).name,'\.mat$','ONCE')
        %fprintf('\n*********** cleaning %s\n ***********\n',d(i).name)
        clear run_info
        clear key_presses
        clear analy
        load([direc filesep d(i).name])
           
        if strcmp(run_info.stimulus_input_file,'Run_1.txt')
            fprintf('%s\t%d\t%d\n',run_info.subject_code,run_info.onsets(end),run_info.durations(end))
            last_onset = run_info.onsets(end);
        end;
    end;
end;

if exist('c')
    for i = i:length(c)
        fprintf('%d\n',c(i));
    end
end

cleaned = last_onset;