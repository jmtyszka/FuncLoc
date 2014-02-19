function cleaned = check_times_nr(direc)
%function cleaned = cleaner_analysis(direc)
%This script will cycle through the directories containing my existing data
%and will pull out key information used in analysis, create a structure,
%and save it as part of the original .mat data file

cd(direc);
k= 1;
%get directory info
for j = 201:220
    d = dir(int2str(j));
    for i=1:length(d) 
        if regexp(d(i).name,'\.mat$','ONCE')
            %fprintf('\n*********** cleaning %s\n ***********\n',d(i).name)
            clear run_info
            clear key_presses
            clear analy
            load([int2str(j) filesep d(i).name]);

            if strcmp(run_info.stimulus_input_file,'issues_sorted2.txt') && run_info.onsets(end) ~= 0
                fprintf('%s\t%d\t%d\n',run_info.subject_code,run_info.onsets(end),run_info.durations(end))
                last_onset(k) = run_info.onsets(end);
                k = k+1;
            end;
        end;
    end;
end;


cleaned = last_onset;