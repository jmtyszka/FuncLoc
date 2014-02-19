% MSIT
clear all;
clc
HideCursor
rand('twister',sum(100*clock));

subid = input('Please enter subject ID: ', 's'); % date + number in the day + Geneder (M or F) + ...
                                                 % Presence or Absence first (P or A) ex. 10061801FP
session = input('enter session :  '); % presence = 1, absence = 0

debugging_mode = 1;

% image_dir = ('C:\Script\ObserverEffect\Images');
output_dir = ['C:\Script\Balance\fMRI1\data_out' filesep subid];
eval(['mkdir ' output_dir]);

out_file = [subid '_MSIT' num2str(session) '.mat']; %defining output file name (subject ID + session #) Note input has to be string

if(exist([output_dir filesep out_file],'file'))
    ButtonName = questdlg('WARNING: File Exists. Continuing will overwrite old data. Continue anyway?',...
        'Log File Exists',...
        'Yes','No','No');
    switch ButtonName   
        case 'No'
            ShowCursor;
            return;
    end
end

%% if using list of values:
MSIT_StimList_051;

easy_num_trials = 96;
hard_num_trials = 96;

%% timing

Stim_time = 0.5;
ISI = 1.25;
Fixation = 30;
TR=2.5;

%% keys

KbName('UnifyKeyNames');
stopkey = 'escape';
%non-fMRI
% startkey = 'space';
% one = 'b';
% two = 'n';
% three = 'm';

%fMRI
startkey = '5%';
one = '2@';
two = '3#';
three = '4$';
% DisableKeysForKbCheck([242, 243]); %Laptop's keys (242, 243) are always down, so ignore them

tic;
while toc < 1; end;
DisableKeysForKbCheck([]);
 [ keyIsDown, timeSecs, keyCode ] = KbCheck;
if keyIsDown 
    DisableKeysForKbCheck(find(keyCode));
    fprintf('some keys were disabled\n'); 
end

%% drawing options:
pen_width = 15;

%%
screen_num = 0;
background_color = [128 128 128];
% background_color = [70 70 70];
% [w.window,w.wRect] = Screen('OpenWindow',screen_num, background_color, [50 50 1000 700]);
[w.window,w.wRect] = Screen('OpenWindow',screen_num, background_color);

[w.ScreenWidth, w.ScreenHeight]=Screen('WindowSize', w.window);
w.ScreenCenterX = w.ScreenWidth/2;
w.ScreenCenterY = w.ScreenHeight/2;
w.ScreenCenter = [w.ScreenCenterX, w.ScreenCenterY];

w.white = WhiteIndex(w.window);
w.black = BlackIndex(w.window);
%w.gray = round(((w.white-w.black)/2));
w.gray = 128;

% Screen(w.window,'TextSize',30);
Screen(w.window,'TextFont','Arial'); %'Times New Roman','Arial', 'Geneva', 'Helvetica', 'sans-serif'

%% images

% CPT1_image =imread('CPT1.jpg','JPG');
% CPT1 = Screen('MakeTexture',w.window,CPT1_image);

%%

if ~debugging_mode,
    if ~isequal([w.ScreenWidth w.ScreenHeight],[800 600])
        disp('Screen resolution is not set to 800x600');
        clear screen;
        keyboard
        return;
    end
end

%% show centered text
%text_color = [w.black w.black w.black];
text_color = [w.white w.white w.white];
fix_color = [w.white w.white w.white];

end_message = ('Press the spacebar to go on to a next task when you are ready');
[end_message_size] = Screen('TextBounds', w.window, end_message);
end_message_x = end_message_size(1,3);
end_message_y = end_message_size(1,4);
end_message_x_offset = w.ScreenCenterX - (end_message_size(1,3)/2);

Screen('FillRect',w.window, [w.gray w.gray w.gray]);

%% calculate x,y positions of rectangles, ovals, etc.

Screen(w.window,'TextSize',50);
[word_size] = Screen('TextBounds', w.window, '000');
letter_x = word_size(1,3);
letter_y = word_size(1,4);
w.letterX = w.ScreenCenterX - (letter_x/2);
w.letterY = w.ScreenCenterY - (letter_y/2);

%% wait to start experiment
Screen('TextSize',w.window, 25);
start_message = ['Get ready\n\n\n\nDo not press buttons until you see the first stimuli'];
DrawFormattedText(w.window, start_message, 'center', 'center', text_color);
Screen('Flip',w.window);
WaitSecs(0.5);

while 1
    
    [ keyIsDown, timeSecs, keyCode ] = KbCheck;
    WaitSecs(.001);
    if (strcmpi(KbName(keyCode),stopkey))
        clear screen;
        return;
    end
    
    if (strcmpi(KbName(keyCode),startkey))
        Screen('FillRect',w.window, [w.gray w.gray w.gray]);
        Screen('Flip', w.window);
        break;
    end
    
end

% DisableKeysForKbCheck(KbName('space'));
%%
% WaitSecs(ITI);
Screen(w.window,'TextSize',30);
DrawFormattedText(w.window, '4', 'center', 'center', fix_color);
Screen('Flip', w.window);
WaitSecs(TR);
DrawFormattedText(w.window, '3', 'center', 'center', fix_color);
Screen('Flip', w.window);
WaitSecs(TR);
DrawFormattedText(w.window, '2', 'center', 'center', fix_color);
Screen('Flip', w.window);
WaitSecs(TR);
DrawFormattedText(w.window, '1', 'center', 'center', fix_color);
Screen('Flip', w.window);
WaitSecs(TR);

DrawFormattedText(w.window, '+', 'center', 'center', fix_color);
% Screen('FillRect',w.window, [w.gray w.gray w.gray]);
session_on_time = Screen('Flip', w.window);

while GetSecs-session_on_time <= Fixation,
    
    [ keyIsDown, timeSecs, keyCode ] = KbCheck;
    WaitSecs(.001);
    if (strcmpi(KbName(keyCode),stopkey))
        clear screen;
        return;
    end
end
Screen(w.window,'TextSize',50);

%% Easy 1
for trial_num = 1:24,
    
    Screen('FillRect',w.window, [w.gray w.gray w.gray]);
    Screen('DrawText', w.window, char(easy(:, trial_num)), w.letterX, w.letterY, text_color);
    trial_on_time = Screen('Flip', w.window);  
    
    onset = trial_on_time - session_on_time;

    response_flag = 0;
    RTime = NaN;
    response_key = NaN;
    response = 0;
    
    while GetSecs-trial_on_time <= Stim_time,
        
        if response_flag == 0
            [ keyIsDown, timeSecs, keyCode ] = KbCheck;
            WaitSecs(.001);
            if (strcmpi(KbName(keyCode),stopkey))
                clear screen;
                return;
            end
            
            if (strcmpi(KbName(keyCode),one))
                trial_off_time = GetSecs;
                RTime = trial_off_time - trial_on_time;
                response_key = KbName(keyCode);
                response = 1;
                response_flag = 1;
            elseif (strcmpi(KbName(keyCode),two))
                trial_off_time = GetSecs;
                RTime = trial_off_time - trial_on_time;
                response_key = KbName(keyCode);
                response = 2;
                response_flag = 1;
            elseif (strcmpi(KbName(keyCode),three))
                trial_off_time = GetSecs;
                RTime = trial_off_time - trial_on_time;
                response_key = KbName(keyCode);
                response = 3;
                response_flag = 1;
            end
        end 
    end
    
    Screen('FillRect',w.window, [w.gray w.gray w.gray]);
    Screen('Flip', w.window);
    
    while GetSecs-trial_on_time <= Stim_time + ISI,
        
        if response_flag == 0
            
            [ keyIsDown, timeSecs, keyCode ] = KbCheck;
            WaitSecs(.001);
            if (strcmpi(KbName(keyCode),stopkey))
                clear screen;
                return;
            end
            
            if (strcmpi(KbName(keyCode),one))
                trial_off_time = GetSecs;
                RTime = trial_off_time - trial_on_time;
                response_key = KbName(keyCode);
                response = 1;
                response_flag = 1;
            elseif (strcmpi(KbName(keyCode),two))
                trial_off_time = GetSecs;
                RTime = trial_off_time - trial_on_time;
                response_key = KbName(keyCode);
                response = 2;
                response_flag = 1;
            elseif (strcmpi(KbName(keyCode),three))
                trial_off_time = GetSecs;
                RTime = trial_off_time - trial_on_time;
                response_key = KbName(keyCode);
                response = 3;
                response_flag = 1;
            end
        end 
    end
    
    if easy_ans(1, trial_num)==1 && response==1 || easy_ans(1, trial_num)==2 && response==2 || easy_ans(1, trial_num)==3 && response==3
        performance = 1;
    else
        performance = 0;
    end
    
    % write output structure
    MSIT.data(trial_num).easy_RTime = RTime;
    MSIT.data(trial_num).easy_response_key = response_key;
    MSIT.data(trial_num).easy_response = response;
    MSIT.data(trial_num).easy_stim = easy(:, trial_num);
    MSIT.data(trial_num).easy_ans = easy_ans(:, trial_num);
    MSIT.data(trial_num).easy_performance = performance;
    MSIT.data(trial_num).easy_onset = onset;
    save([output_dir filesep out_file], 'MSIT')
end

%% Hard 1
for trial_num = 1:24,
    
    Screen('FillRect',w.window, [w.gray w.gray w.gray]);
    Screen('DrawText', w.window, char(hard(:, trial_num)), w.letterX, w.letterY, text_color);
    trial_on_time = Screen('Flip', w.window);  
    onset = trial_on_time - session_on_time;
    response_flag = 0;
    RTime = NaN;
    response_key = NaN;
    response = 0;
    
    while GetSecs-trial_on_time <= Stim_time,
        
        if response_flag == 0
            
            [ keyIsDown, timeSecs, keyCode ] = KbCheck;
            WaitSecs(.001);
            if (strcmpi(KbName(keyCode),stopkey))
                clear screen;
                return;
            end
            
            if (strcmpi(KbName(keyCode),one))
                trial_off_time = GetSecs;
                RTime = trial_off_time - trial_on_time;
                response_key = KbName(keyCode);
                response = 1;
                response_flag = 1;
            elseif (strcmpi(KbName(keyCode),two))
                trial_off_time = GetSecs;
                RTime = trial_off_time - trial_on_time;
                response_key = KbName(keyCode);
                response = 2;
                response_flag = 1;
            elseif (strcmpi(KbName(keyCode),three))
                trial_off_time = GetSecs;
                RTime = trial_off_time - trial_on_time;
                response_key = KbName(keyCode);
                response = 3;
                response_flag = 1;
            end
        end 
    end
    
    Screen('FillRect',w.window, [w.gray w.gray w.gray]);
    Screen('Flip', w.window);
    
    while GetSecs-trial_on_time <= Stim_time + ISI,
        
        if response_flag == 0
            
            [ keyIsDown, timeSecs, keyCode ] = KbCheck;
            WaitSecs(.001);
            if (strcmpi(KbName(keyCode),stopkey))
                clear screen;
                return;
            end
            
            if (strcmpi(KbName(keyCode),one))
                trial_off_time = GetSecs;
                RTime = trial_off_time - trial_on_time;
                response_key = KbName(keyCode);
                response = 1;
                response_flag = 1;
            elseif (strcmpi(KbName(keyCode),two))
                trial_off_time = GetSecs;
                RTime = trial_off_time - trial_on_time;
                response_key = KbName(keyCode);
                response = 2;
                response_flag = 1;
            elseif (strcmpi(KbName(keyCode),three))
                trial_off_time = GetSecs;
                RTime = trial_off_time - trial_on_time;
                response_key = KbName(keyCode);
                response = 3;
                response_flag = 1;
            end
        end 
    end
    
    if hard_ans(1, trial_num)==1 && response==1 || hard_ans(1, trial_num)==2 && response==2 || hard_ans(1, trial_num)==3 && response==3
        performance = 1;
    else
        performance = 0;
    end
    
    % write output structure
    MSIT.data(trial_num).hard_RTime = RTime;
    MSIT.data(trial_num).hard_response_key = response_key;
    MSIT.data(trial_num).hard_response = response;
    MSIT.data(trial_num).hard_stim = hard(:, trial_num);
    MSIT.data(trial_num).hard_ans = hard_ans(:, trial_num);
    MSIT.data(trial_num).hard_performance = performance;
    MSIT.data(trial_num).hard_onset = onset;
    save([output_dir filesep out_file], 'MSIT')
end

%% Easy 2
for trial_num = 25:48,

    Screen('FillRect',w.window, [w.gray w.gray w.gray]);
    Screen('DrawText', w.window, char(easy(:, trial_num)), w.letterX, w.letterY, text_color);
    trial_on_time = Screen('Flip', w.window);  
    onset = trial_on_time - session_on_time;
    response_flag = 0;
    RTime = NaN;
    response_key = NaN;
    response = 0;

    while GetSecs-trial_on_time <= Stim_time,
        
        if response_flag == 0
            
            [ keyIsDown, timeSecs, keyCode ] = KbCheck;
            WaitSecs(.001);
            if (strcmpi(KbName(keyCode),stopkey))
                clear screen;
                return;
            end
            
            if (strcmpi(KbName(keyCode),one))
                trial_off_time = GetSecs;
                RTime = trial_off_time - trial_on_time;
                response_key = KbName(keyCode);
                response = 1;
                response_flag = 1;
            elseif (strcmpi(KbName(keyCode),two))
                trial_off_time = GetSecs;
                RTime = trial_off_time - trial_on_time;
                response_key = KbName(keyCode);
                response = 2;
                response_flag = 1;
            elseif (strcmpi(KbName(keyCode),three))
                trial_off_time = GetSecs;
                RTime = trial_off_time - trial_on_time;
                response_key = KbName(keyCode);
                response = 3;
                response_flag = 1;
            end
        end 
    end
    
    Screen('FillRect',w.window, [w.gray w.gray w.gray]);
    Screen('Flip', w.window);
    
    while GetSecs-trial_on_time <= Stim_time + ISI,
        
        if response_flag == 0
            
            [ keyIsDown, timeSecs, keyCode ] = KbCheck;
            WaitSecs(.001);
            if (strcmpi(KbName(keyCode),stopkey))
                clear screen;
                return;
            end
            
            if (strcmpi(KbName(keyCode),one))
                trial_off_time = GetSecs;
                RTime = trial_off_time - trial_on_time;
                response_key = KbName(keyCode);
                response = 1;
                response_flag = 1;
            elseif (strcmpi(KbName(keyCode),two))
                trial_off_time = GetSecs;
                RTime = trial_off_time - trial_on_time;
                response_key = KbName(keyCode);
                response = 2;
                response_flag = 1;
            elseif (strcmpi(KbName(keyCode),three))
                trial_off_time = GetSecs;
                RTime = trial_off_time - trial_on_time;
                response_key = KbName(keyCode);
                response = 3;
                response_flag = 1;
            end
        end 
    end
    
    if easy_ans(1, trial_num)==1 && response==1 || easy_ans(1, trial_num)==2 && response==2 || easy_ans(1, trial_num)==3 && response==3
        performance = 1;
    else
        performance = 0;
    end
    
    % write output structure
    MSIT.data(trial_num).easy_RTime = RTime;
    MSIT.data(trial_num).easy_response_key = response_key;
    MSIT.data(trial_num).easy_response = response;
    MSIT.data(trial_num).easy_stim = easy(:, trial_num);
    MSIT.data(trial_num).easy_ans = easy_ans(:, trial_num);
    MSIT.data(trial_num).easy_performance = performance;
    MSIT.data(trial_num).easy_onset = onset;
    save([output_dir filesep out_file], 'MSIT')
end

%% Hard 2
for trial_num = 25:48,
    
    Screen('FillRect',w.window, [w.gray w.gray w.gray]);
    Screen('DrawText', w.window, char(hard(:, trial_num)), w.letterX, w.letterY, text_color);
    trial_on_time = Screen('Flip', w.window);  
    onset = trial_on_time - session_on_time;
    response_flag = 0;
    RTime = NaN;
    response_key = NaN;
    response = 0;

    while GetSecs-trial_on_time <= Stim_time,
        
        if response_flag == 0
            
            [ keyIsDown, timeSecs, keyCode ] = KbCheck;
            WaitSecs(.001);
            if (strcmpi(KbName(keyCode),stopkey))
                clear screen;
                return;
            end
            
            if (strcmpi(KbName(keyCode),one))
                trial_off_time = GetSecs;
                RTime = trial_off_time - trial_on_time;
                response_key = KbName(keyCode);
                response = 1;
                response_flag = 1;
            elseif (strcmpi(KbName(keyCode),two))
                trial_off_time = GetSecs;
                RTime = trial_off_time - trial_on_time;
                response_key = KbName(keyCode);
                response = 2;
                response_flag = 1;
            elseif (strcmpi(KbName(keyCode),three))
                trial_off_time = GetSecs;
                RTime = trial_off_time - trial_on_time;
                response_key = KbName(keyCode);
                response = 3;
                response_flag = 1;
            end
        end 
    end
    
    Screen('FillRect',w.window, [w.gray w.gray w.gray]);
    Screen('Flip', w.window);
    
    while GetSecs-trial_on_time <= Stim_time + ISI,
        
        if response_flag == 0
            
            [ keyIsDown, timeSecs, keyCode ] = KbCheck;
            WaitSecs(.001);
            if (strcmpi(KbName(keyCode),stopkey))
                clear screen;
                return;
            end
            
            if (strcmpi(KbName(keyCode),one))
                trial_off_time = GetSecs;
                RTime = trial_off_time - trial_on_time;
                response_key = KbName(keyCode);
                response = 1;
                response_flag = 1;
            elseif (strcmpi(KbName(keyCode),two))
                trial_off_time = GetSecs;
                RTime = trial_off_time - trial_on_time;
                response_key = KbName(keyCode);
                response = 2;
                response_flag = 1;
            elseif (strcmpi(KbName(keyCode),three))
                trial_off_time = GetSecs;
                RTime = trial_off_time - trial_on_time;
                response_key = KbName(keyCode);
                response = 3;
                response_flag = 1;
            end
        end 
    end
    
    if hard_ans(1, trial_num)==1 && response==1 || hard_ans(1, trial_num)==2 && response==2 || hard_ans(1, trial_num)==3 && response==3
        performance = 1;
    else
        performance = 0;
    end
    
    % write output structure
    MSIT.data(trial_num).hard_RTime = RTime;
    MSIT.data(trial_num).hard_response_key = response_key;
    MSIT.data(trial_num).hard_response = response;
    MSIT.data(trial_num).hard_stim = hard(:, trial_num);
    MSIT.data(trial_num).hard_ans = hard_ans(:, trial_num);
    MSIT.data(trial_num).hard_performance = performance;
    MSIT.data(trial_num).hard_onset = onset;
    save([output_dir filesep out_file], 'MSIT')
end

%% Easy 3
for trial_num = 49:72,
    
    Screen('FillRect',w.window, [w.gray w.gray w.gray]);
    Screen('DrawText', w.window, char(easy(:, trial_num)), w.letterX, w.letterY, text_color);
    trial_on_time = Screen('Flip', w.window);  
    onset = trial_on_time - session_on_time;
    response_flag = 0;
    RTime = NaN;
    response_key = NaN;
    response = 0;

    while GetSecs-trial_on_time <= Stim_time,
        
        if response_flag == 0
            
            [ keyIsDown, timeSecs, keyCode ] = KbCheck;
            WaitSecs(.001);
            if (strcmpi(KbName(keyCode),stopkey))
                clear screen;
                return;
            end
            
            if (strcmpi(KbName(keyCode),one))
                trial_off_time = GetSecs;
                RTime = trial_off_time - trial_on_time;
                response_key = KbName(keyCode);
                response = 1;
                response_flag = 1;
            elseif (strcmpi(KbName(keyCode),two))
                trial_off_time = GetSecs;
                RTime = trial_off_time - trial_on_time;
                response_key = KbName(keyCode);
                response = 2;
                response_flag = 1;
            elseif (strcmpi(KbName(keyCode),three))
                trial_off_time = GetSecs;
                RTime = trial_off_time - trial_on_time;
                response_key = KbName(keyCode);
                response = 3;
                response_flag = 1;
            end
        end 
    end
    
    Screen('FillRect',w.window, [w.gray w.gray w.gray]);
    Screen('Flip', w.window);
    
    while GetSecs-trial_on_time <= Stim_time + ISI,
        
        if response_flag == 0
            
            [ keyIsDown, timeSecs, keyCode ] = KbCheck;
            WaitSecs(.001);
            if (strcmpi(KbName(keyCode),stopkey))
                clear screen;
                return;
            end
            
            if (strcmpi(KbName(keyCode),one))
                trial_off_time = GetSecs;
                RTime = trial_off_time - trial_on_time;
                response_key = KbName(keyCode);
                response = 1;
                response_flag = 1;
            elseif (strcmpi(KbName(keyCode),two))
                trial_off_time = GetSecs;
                RTime = trial_off_time - trial_on_time;
                response_key = KbName(keyCode);
                response = 2;
                response_flag = 1;
            elseif (strcmpi(KbName(keyCode),three))
                trial_off_time = GetSecs;
                RTime = trial_off_time - trial_on_time;
                response_key = KbName(keyCode);
                response = 3;
                response_flag = 1;
            end
        end 
    end
    
    if easy_ans(1, trial_num)==1 && response==1 || easy_ans(1, trial_num)==2 && response==2 || easy_ans(1, trial_num)==3 && response==3
        performance = 1;
    else
        performance = 0;
    end
    
    % write output structure
    MSIT.data(trial_num).easy_RTime = RTime;
    MSIT.data(trial_num).easy_response_key = response_key;
    MSIT.data(trial_num).easy_response = response;
    MSIT.data(trial_num).easy_stim = easy(:, trial_num);
    MSIT.data(trial_num).easy_ans = easy_ans(:, trial_num);
    MSIT.data(trial_num).easy_performance = performance;
    MSIT.data(trial_num).easy_onset = onset;
    save([output_dir filesep out_file], 'MSIT')
end

%% Hard 3
for trial_num = 49:72,
    
    Screen('FillRect',w.window, [w.gray w.gray w.gray]);
    Screen('DrawText', w.window, char(hard(:, trial_num)), w.letterX, w.letterY, text_color);
    trial_on_time = Screen('Flip', w.window);  
    onset = trial_on_time - session_on_time;
    response_flag = 0;
    RTime = NaN;
    response_key = NaN;
    response = 0;

    while GetSecs-trial_on_time <= Stim_time,
        
        if response_flag == 0
            
            [ keyIsDown, timeSecs, keyCode ] = KbCheck;
            WaitSecs(.001);
            if (strcmpi(KbName(keyCode),stopkey))
                clear screen;
                return;
            end
            
            if (strcmpi(KbName(keyCode),one))
                trial_off_time = GetSecs;
                RTime = trial_off_time - trial_on_time;
                response_key = KbName(keyCode);
                response = 1;
                response_flag = 1;
            elseif (strcmpi(KbName(keyCode),two))
                trial_off_time = GetSecs;
                RTime = trial_off_time - trial_on_time;
                response_key = KbName(keyCode);
                response = 2;
                response_flag = 1;
            elseif (strcmpi(KbName(keyCode),three))
                trial_off_time = GetSecs;
                RTime = trial_off_time - trial_on_time;
                response_key = KbName(keyCode);
                response = 3;
                response_flag = 1;
            end
        end 
    end
    
    Screen('FillRect',w.window, [w.gray w.gray w.gray]);
    Screen('Flip', w.window);
    
    while GetSecs-trial_on_time <= Stim_time + ISI,
        
        if response_flag == 0
            
            [ keyIsDown, timeSecs, keyCode ] = KbCheck;
            WaitSecs(.001);
            if (strcmpi(KbName(keyCode),stopkey))
                clear screen;
                return;
            end
            
            if (strcmpi(KbName(keyCode),one))
                trial_off_time = GetSecs;
                RTime = trial_off_time - trial_on_time;
                response_key = KbName(keyCode);
                response = 1;
                response_flag = 1;
            elseif (strcmpi(KbName(keyCode),two))
                trial_off_time = GetSecs;
                RTime = trial_off_time - trial_on_time;
                response_key = KbName(keyCode);
                response = 2;
                response_flag = 1;
            elseif (strcmpi(KbName(keyCode),three))
                trial_off_time = GetSecs;
                RTime = trial_off_time - trial_on_time;
                response_key = KbName(keyCode);
                response = 3;
                response_flag = 1;
            end
        end 
    end
    
    if hard_ans(1, trial_num)==1 && response==1 || hard_ans(1, trial_num)==2 && response==2 || hard_ans(1, trial_num)==3 && response==3
        performance = 1;
    else
        performance = 0;
    end
    
    % write output structure
    MSIT.data(trial_num).hard_RTime = RTime;
    MSIT.data(trial_num).hard_response_key = response_key;
    MSIT.data(trial_num).hard_response = response;
    MSIT.data(trial_num).hard_stim = hard(:, trial_num);
    MSIT.data(trial_num).hard_ans = hard_ans(:, trial_num);
    MSIT.data(trial_num).hard_performance = performance;
    MSIT.data(trial_num).hard_onset = onset;
    save([output_dir filesep out_file], 'MSIT')
end

%% Easy 4
for trial_num = 73:96,
    
    Screen('FillRect',w.window, [w.gray w.gray w.gray]);
    Screen('DrawText', w.window, char(easy(:, trial_num)), w.letterX, w.letterY, text_color);
    trial_on_time = Screen('Flip', w.window);  
    onset = trial_on_time - session_on_time;
    response_flag = 0;
    RTime = NaN;
    response_key = NaN;
    response = 0;

    while GetSecs-trial_on_time <= Stim_time,
        
        if response_flag == 0
            
            [ keyIsDown, timeSecs, keyCode ] = KbCheck;
            WaitSecs(.001);
            if (strcmpi(KbName(keyCode),stopkey))
                clear screen;
                return;
            end
            
            if (strcmpi(KbName(keyCode),one))
                trial_off_time = GetSecs;
                RTime = trial_off_time - trial_on_time;
                response_key = KbName(keyCode);
                response = 1;
                response_flag = 1;
            elseif (strcmpi(KbName(keyCode),two))
                trial_off_time = GetSecs;
                RTime = trial_off_time - trial_on_time;
                response_key = KbName(keyCode);
                response = 2;
                response_flag = 1;
            elseif (strcmpi(KbName(keyCode),three))
                trial_off_time = GetSecs;
                RTime = trial_off_time - trial_on_time;
                response_key = KbName(keyCode);
                response = 3;
                response_flag = 1;
            end
        end 
    end
    
    Screen('FillRect',w.window, [w.gray w.gray w.gray]);
    Screen('Flip', w.window);
    
    while GetSecs-trial_on_time <= Stim_time + ISI,
        
        if response_flag == 0
            
            [ keyIsDown, timeSecs, keyCode ] = KbCheck;
            WaitSecs(.001);
            if (strcmpi(KbName(keyCode),stopkey))
                clear screen;
                return;
            end
            
            if (strcmpi(KbName(keyCode),one))
                trial_off_time = GetSecs;
                RTime = trial_off_time - trial_on_time;
                response_key = KbName(keyCode);
                response = 1;
                response_flag = 1;
            elseif (strcmpi(KbName(keyCode),two))
                trial_off_time = GetSecs;
                RTime = trial_off_time - trial_on_time;
                response_key = KbName(keyCode);
                response = 2;
                response_flag = 1;
            elseif (strcmpi(KbName(keyCode),three))
                trial_off_time = GetSecs;
                RTime = trial_off_time - trial_on_time;
                response_key = KbName(keyCode);
                response = 3;
                response_flag = 1;
            end
        end 
    end
    
    if easy_ans(1, trial_num)==1 && response==1 || easy_ans(1, trial_num)==2 && response==2 || easy_ans(1, trial_num)==3 && response==3
        performance = 1;
    else
        performance = 0;
    end
    
    % write output structure
    MSIT.data(trial_num).easy_RTime = RTime;
    MSIT.data(trial_num).easy_response_key = response_key;
    MSIT.data(trial_num).easy_response = response;
    MSIT.data(trial_num).easy_stim = easy(:, trial_num);
    MSIT.data(trial_num).easy_ans = easy_ans(:, trial_num);
    MSIT.data(trial_num).easy_performance = performance;
    MSIT.data(trial_num).easy_onset = onset;
    save([output_dir filesep out_file], 'MSIT')
end

%% Hard 4
for trial_num = 73:96,
    
    Screen('FillRect',w.window, [w.gray w.gray w.gray]);
    Screen('DrawText', w.window, char(hard(:, trial_num)), w.letterX, w.letterY, text_color);
    trial_on_time = Screen('Flip', w.window);  
    onset = trial_on_time - session_on_time;
    response_flag = 0;
    RTime = NaN;
    response_key = NaN;
    response = 0;

    while GetSecs-trial_on_time <= Stim_time,
        
        if response_flag == 0
            
            [ keyIsDown, timeSecs, keyCode ] = KbCheck;
            WaitSecs(.001);
            if (strcmpi(KbName(keyCode),stopkey))
                clear screen;
                return;
            end
            
            if (strcmpi(KbName(keyCode),one))
                trial_off_time = GetSecs;
                RTime = trial_off_time - trial_on_time;
                response_key = KbName(keyCode);
                response = 1;
                response_flag = 1;
            elseif (strcmpi(KbName(keyCode),two))
                trial_off_time = GetSecs;
                RTime = trial_off_time - trial_on_time;
                response_key = KbName(keyCode);
                response = 2;
                response_flag = 1;
            elseif (strcmpi(KbName(keyCode),three))
                trial_off_time = GetSecs;
                RTime = trial_off_time - trial_on_time;
                response_key = KbName(keyCode);
                response = 3;
                response_flag = 1;
            end
        end 
    end
    
    Screen('FillRect',w.window, [w.gray w.gray w.gray]);
    Screen('Flip', w.window);
    
    while GetSecs-trial_on_time <= Stim_time + ISI,
        
        if response_flag == 0
            
            [ keyIsDown, timeSecs, keyCode ] = KbCheck;
            WaitSecs(.001);
            if (strcmpi(KbName(keyCode),stopkey))
                clear screen;
                return;
            end
            
            if (strcmpi(KbName(keyCode),one))
                trial_off_time = GetSecs;
                RTime = trial_off_time - trial_on_time;
                response_key = KbName(keyCode);
                response = 1;
                response_flag = 1;
            elseif (strcmpi(KbName(keyCode),two))
                trial_off_time = GetSecs;
                RTime = trial_off_time - trial_on_time;
                response_key = KbName(keyCode);
                response = 2;
                response_flag = 1;
            elseif (strcmpi(KbName(keyCode),three))
                trial_off_time = GetSecs;
                RTime = trial_off_time - trial_on_time;
                response_key = KbName(keyCode);
                response = 3;
                response_flag = 1;
            end
        end 
    end
    
    if hard_ans(1, trial_num)==1 && response==1 || hard_ans(1, trial_num)==2 && response==2 || hard_ans(1, trial_num)==3 && response==3
        performance = 1;
    else
        performance = 0;
    end
    
    % write output structure
    MSIT.data(trial_num).hard_RTime = RTime;
    MSIT.data(trial_num).hard_response_key = response_key;
    MSIT.data(trial_num).hard_response = response;
    MSIT.data(trial_num).hard_stim = hard(:, trial_num);
    MSIT.data(trial_num).hard_ans = hard_ans(:, trial_num);
    MSIT.data(trial_num).hard_performance = performance;
    MSIT.data(trial_num).hard_onset = onset;
    save([output_dir filesep out_file], 'MSIT')
end

% Screen('DrawTexture', w.window, fix, [], [Fixx1 Fixy1 Fixx2 Fixy2]);
DrawFormattedText(w.window, '+', 'center', 'center', fix_color);
% Screen('FillRect',w.window, [w.gray w.gray w.gray]);
session_off_time=Screen('Flip', w.window);
% WaitSecs(Fixation);
    MSIT.last_fix_onset = (session_off_time - session_on_time);
    save([output_dir filesep out_file], 'MSIT')
while GetSecs-session_off_time <= Fixation,
    
    [ keyIsDown, timeSecs, keyCode ] = KbCheck;
    WaitSecs(.001);
    if (strcmpi(KbName(keyCode),stopkey))
        clear screen;
        return;
    end
end
clear screen;

%% simple analysis
% end_message = ['Thank you!'];
%     Screen('TextSize',w.window, 25);
%     DrawFormattedText(w.window, end_message, 'center', 'center', text_color);
%     Screen('Flip',w.window);

cd(output_dir);
load([subid '_MSIT' num2str(session) '.mat']);

format bank;
RT_easy =[MSIT.data(1,:).easy_RTime];
RT_hard =[MSIT.data(1,:).hard_RTime];
performance_easy =[MSIT.data(1,:).easy_performance];
performance_hard =[MSIT.data(1,:).hard_performance];
display('RT_easy')
nanmean(RT_easy)*1000
display('RT_hard')
nanmean(RT_hard)*1000
display('performance_easy')
mean(performance_easy)*100
display('performance_hard')
mean(performance_hard)*100

%     while 1
%         [ keyIsDown, timeSecs, keyCode ] = KbCheck;
%         WaitSecs(.001);
%         if (strcmpi(KbName(keyCode),stopkey))
%             WaitSecs(0.7)
%             clear screen;
%             return;
%         end
%     end

