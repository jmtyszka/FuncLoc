function [quit_flag] = WaitForScannerTrigger(w,debugging_mode,keys,intKeyboard,extKeyboard,text1,font_size)



if ~exist('font_size','var'), 
    font_size = 30;
end
if nargin < 6, 
    text1 = 'Scanning will begin shortly...';
    font_size = 30;
end
if ~exist('debugging_mode'),
    debugging_mode = 0;
end
if ~exist('keys'),
    keys.trigger = '5%';
    keys.stopkey = 'q';
end
if ~exist('intKeyboard') || ~exist('extKeyboard')
   [extKeyboard,intKeyboard] = find_keyboard;
end


quit_flag = 0;

draw_text_centered(w, text1, w.white, font_size);
Screen('Flip', w.window);

while 1,
    
    if debugging_mode == 1,
        [ keyIsDown, seconds, keyCode ] = KbCheck(intKeyboard);
    else
        [ keyIsDown, seconds, keyCode ] = KbCheck(extKeyboard);
    end
    WaitSecs(.001);

    if strcmpi(KbName(keyCode),keys.trigger),
        break
    end

    [ keyIsDown, seconds, keyCode ] = KbCheck(intKeyboard);
    WaitSecs(.001);
    if strcmpi(KbName(keyCode),keys.stopkey),
        quit_flag = 1;
        break
    end

end