function cleaned = cleaner(direc)
%function cleaned = cleaner(direc)
%This script will cycle through the directories containing my existing data
%and will clean up number output to transform from keyboard to keypad (e.g.
%1! --> 1)

%get directory info
d = dir(direc);
for i = 1:length(d)
    if d(i).isdir && (~strcmp(d(i).name,'.') && ~strcmp(d(i).name,'..'))
        cleaner([direc d(i).name])
    elseif regexp(d(i).name,'\.mat$','ONCE')
        fprintf('\n*********** cleaning %s\n ***********',d(i).name)
        clear run_info
        clear key_presses
        load([direc filesep d(i).name])
        old_resp = run_info.responses;
        old_key = cell(1,length(key_presses));
        for j = 1:length(key_presses)
            old_key{j} = key_presses(j).key;
        end;
        run_info.responses = clean_output(run_info.responses);
        key_presses = clean_output(key_presses);
        
        fprintf('run_info.responses\n')
        fprintf('OLD\tNEW\n')
        for j = 1:length(old_resp)
            if ~strcmp(old_resp{j},run_info.responses{j})
            fprintf('%s\t%s\n',old_resp{j},run_info.responses{j})
            end;
        end;
        
        fprintf('key_presses.key\n')
        fprintf('OLD\tNEW\n')
        for k = 1:length(old_key)
            if ~strcmp(old_key{k},key_presses(k).key)
            fprintf('%s\t%s\n',old_key{k},key_presses(k).key)
            end;
        end;
       
 
        save([direc filesep d(i).name],'run_info','key_presses')
    end;
end;
    
