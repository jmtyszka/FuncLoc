function [output, stpEvt] = is_stop_event(key_pressed,key_desired)
%key_pressed should be a valid keycode (see the KbCheck function)
%key_desired should be a string in MacStim format
%output a a boolean variable that indicates whether a stop event has
%occurred, while stpEvt holds the key that caused the event.


%k\ matches any character
if strcmp(key_desired, 'k\')
    output = true;
    stpEvt = find(key_pressed==min(nonzeros(key_pressed))); %KbQueue gives us an array with non-zero values corresponding to times, so the min non-zero value is the first key pressed
    stpEvt = KbName(stpEvt(1)); %in the case where two keys have the same value, just take the first one
    return;
end;

%'n' matches nothing
if isempty(key_desired) || strcmp( key_desired, 'n' ) 
    output = false;
    stpEvt = [];
    return;
end;

%map QWERTY numerical keys to keypad (e.g., 3 = 3#)
QWERTY_shifts = ')!@#$%^&*(';

for i = 0:9  
    if key_pressed(KbName([int2str(i) QWERTY_shifts(i+1)])) > 0
        key_pressed(KbName(int2str(i))) = 1;
    end;
end;


%0 means it was blank, so we match nothing
if isnumeric(key_desired) 
    if key_desired == 0 
        output = false;
        stpEvt = [];
        return;
    end;
end;

if ischar(key_desired)
        
    keylist = key_pressed;
    while sum(keylist)>0, %if a key was pressed 
        j = find(keylist==min(nonzeros(keylist))); %find the earliest key pressed
        
        for k = 1:length(j) %for each of the earliest keys pressed
            for i = 1:length(key_desired) %check if it is a desired key
                if KbName(j(k)) == key_desired(i);
                    output = true;
                    stpEvt = key_desired(i);
                    return; 
                end;
                keylist(j(k)) = 0; %remove undesired key from list of pressed keys
            end;
        end;
    end;

    
    output = false;
    stpEvt = [];
    return;
    
else
    %key_desired should have been a string
    fprintf('\nerror! in is_stop_event key_desired = %d\n',key_desired);
    output = false;
    stpEvt = [];
    return;
end

%Defaults to false
fprintf('is_stop_event was confused.  Returning false\nkey_pressed = %d key_desired = %d\n',key_pressed,key_desired);
output = false;
stpEvt = [];
return;

    
    