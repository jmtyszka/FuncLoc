DEBUG = 0;
key_presses = struct('key',{},'time',{},'stimulus',{}); %matrix to hold key pressed, time of key press, and current stimulus (will increment up)

experiment_start = GetSecs;

while 1,
    [keyIsDown,secs,keyCode]=KbCheck;
    if keyIsDown, %key is pressed
        key_presses(length(key_presses)+1).key = KbName(keyCode);
        key_presses(length(key_presses)).time = GetSecs - experiment_start;
        if KbName(keyCode) == 'q'
            break;
        end;

        
        if DEBUG
            fprintf('key pressed = %s\n',KbName(keyCode));
        end;
    end
    
    while keyIsDown
        [keyIsDown,secs,keyCode]=KbCheck;
        WaitSecs(0.01);
    end
    WaitSecs(0.001);  % prevents overload and decrement of priority

end;