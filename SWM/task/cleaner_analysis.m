function cleaned = cleaner_analysis(direc)
%function cleaned = cleaner_analysis(direc)
%This script will cycle through the directories containing my existing data
%and will pull out key information used in analysis, create a structure,
%and save it as part of the original .mat data file

%get directory info
d = dir(direc);
for i = 1:length(d)
    if d(i).isdir && (~strcmp(d(i).name,'.') && ~strcmp(d(i).name,'..'))
        cleaner_analysis([direc d(i).name])
    elseif regexp(d(i).name,'\.mat$','ONCE')
        fprintf('\n*********** cleaning %s\n ***********\n',d(i).name)
        clear run_info
        clear key_presses
        load([direc filesep d(i).name])
               
        analy = struct('onset',[],'dur',[],'resp',[]);
        j = 1;
        for n = 1:length(run_info.onsets)
            if ~isempty(run_info.responses{n}) && n > 1
                analy.onset(j) = run_info.onsets(n-1);
                analy.dur(j) = run_info.durations(n-1);
                analy.resp(j) = str2num(run_info.responses{n})';
                j = j+1;
            end
        end
        
        
        fprintf('onsets\tdurations\tresponses\n')
       
        for j = 1:length(analy.onset)
           
            fprintf('%d\t%d\t%d\n',analy.onset(j),analy.dur(j),analy.resp(j))
       
        end;
 
        save([direc filesep d(i).name],'run_info','key_presses','analy')
    end;
end;
    
