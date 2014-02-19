function cleaned_keys = clean_output(keys)
%cleaned_keys = clean_output(keys); takes in a cell array of keys and outputs the same cell array, but with numbers specified as keypad numbers (so '1!' -->'1', '2@'-->'2', etc.)

%map QWERTY numerical keys to keypad (e.g., 3# = 3)
QWERTY_shifts = ')!@#$%^&*(';
    

if iscell(keys) %this will handle the cell array that comes out of run_info.responses
    for i = 1:length(keys)
        for j = 0:9  
            if strcmp(keys{i},[int2str(j) QWERTY_shifts(j+1)])
                keys{i} = int2str(j);
                break;
            end;
        end;
    end;
    
elseif isstruct(keys) %this will handle the array of structs that holds the keys pressed in key presses
   for i = 1:length(keys)
        for j = 0:9  
            if strcmp(keys(i).key,[int2str(j) QWERTY_shifts(j+1)])
                keys(i).key = int2str(j);
                break;
            end;
        end;
    end;
end;

cleaned_keys = keys;