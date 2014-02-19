clear all;
clc
HideCursor
rand('twister',sum(100*clock));

debugging_mode = 1;
subid = input('Please enter subject ID: ', 's');
session = input('enter session :  ');
output_dir = ['C:\Script\Balance\fMRI1\data_out' filesep subid];
eval(['mkdir ' output_dir]);
out_file = [subid '_MID' num2str(session) '.mat']; %defining output file name (subject ID + session#)
% 
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

%% load images

% image_dir = ['C:\Script\Balance\fMRI1\image'];
% stim_list = dir([image_dir filesep '*.jpg']); % you can use dir also

high_reward_trial = 15; % $2
low_reward_trial = 15; % $0.2
neutral_trial = 15; % $0
num_trials = high_reward_trial + low_reward_trial + neutral_trial;

% order = randperm(num_trials); % randamly deciding the order of trials
order =[];
for a = 1:high_reward_trial;
    order = [order, randperm(3)];
end 
%% keys
KbName('UnifyKeyNames');
stopkey = 'escape';

%non-fMRI
% decide_key = 'space';

%fMRI
decide_key = '2@';
pulse = '5%';

TR = 2.5;

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
% pen_width = 15;

%%
screen_num = 0;
background_color = [128 128 128];
% % % [w.window,w.wRect] = Screen('OpenWindow',screen_num, background_color, [0 0 100 70]);
% [w.window,w.wRect] = Screen('OpenWindow',screen_num, background_color, [50 50 1000 700]);
[w.window,w.wRect] = Screen('OpenWindow',screen_num, background_color);

[w.ScreenWidth, w.ScreenHeight]=Screen('WindowSize', w.window);
w.ScreenCenterX = w.ScreenWidth/2;
w.ScreenCenterY = w.ScreenHeight/2;
w.ScreenCenter = [w.ScreenCenterX, w.ScreenCenterY];

w.white = WhiteIndex(w.window);
w.black = BlackIndex(w.window);
w.gray = round(((w.white-w.black)/2));

Screen(w.window,'TextFont','Arial'); %'Times New Roman','Arial', 'Geneva', 'Helvetica', 'sans-serif'

%%

if ~debugging_mode,
    if ~isequal([w.ScreenWidth w.ScreenHeight],[800 600])
        disp('Screen resolution is not set to 800x600');
        clear screen;
        keyboard
        return;
    end
end

%% color
text_color = [w.white w.white w.white];
win_color = [255,255,0];
lose_color =[0,255,255];
fix_color = [w.white w.white w.white];

% num_trials = length(pairs);

%% Instruction

read_image_MID; % see read_image.m file

Screen(w.window,'TextSize',30);
start_message = ['Get ready'];
DrawFormattedText(w.window, start_message, 'center', 'center', text_color);
Screen('Flip',w.window);
Waitsecs(0.5);

while 1    
    [ keyIsDown, timeSecs, keyCode ] = KbCheck;
    WaitSecs(.001);
    if (strcmpi(KbName(keyCode),stopkey))
        clear screen;
        return;
    end
    
    if (strcmpi(KbName(keyCode),pulse))
        Screen('FillRect',w.window, [w.gray w.gray w.gray]);
        Screen('Flip', w.window);
        break;
    end    
end

%% Stimuli position,
[Cy1, Cx1, Cd1] = size(cue0_file);
[Ty1, Tx1, Td1] = size(target_file);
[Fy1, Fx1, Fd1] = size(fix_file);

pic = 1;
Fixx1 = w.ScreenCenterX-(Fx1/2)*pic;
Fixy1 = w.ScreenCenterY-(Fy1/2)*pic;
Fixx2 = w.ScreenCenterX+(Fx1/2)*pic;
Fixy2 = w.ScreenCenterY+(Fy1/2)*pic;

Targetx1 = w.ScreenCenterX-(Tx1/2)*pic;
Targety1 = w.ScreenCenterY-(Ty1/2)*pic;
Targetx2 = w.ScreenCenterX+(Tx1/2)*pic;
Targety2 = w.ScreenCenterY+(Ty1/2)*pic;

Cuex1 = w.ScreenCenterX-(Cx1/2)*pic;
Cuey1 = w.ScreenCenterY-(Cy1/2)*pic;
Cuex2 = w.ScreenCenterX+(Cx1/2)*pic;
Cuey2 = w.ScreenCenterY+(Cy1/2)*pic;

%% start
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
start_time = Screen('Flip', w.window);
    WaitSecs(TR);
    
Screen(w.window,'TextSize',40);

target_time = 0.25; % 160ms-300ms (duration for target presentation)
max_target_time = 0.3;
min_target_time = 0.16;
sum = 0; % the number of hits
% money_earned = zeros(num_trials,1);

High = ['$2.00'];
Low = ['$0.20'];
Zero = ['$0.00'];

for trial_num = 1:num_trials,
    
    % timing
    cue_time = 0.5; % duration for cur presentation
    delay1 = 2+rand()/2; % 2-2.5 sec
    delay2 = 2 - target_time;
    outcome_time = 0.8;
    ITI = 1.5;
    
    target_accuracy = 0.667;
    
    condition = NaN;
    early_response = 0;
    response_flag = 0;
    RTime = NaN;
    response_key = NaN;
    response = 0;
    
    % Cue presentation
    if order(trial_num) == 1
        DrawFormattedText(w.window, Zero, 'center', 'center', text_color);
%         Screen('DrawTexture', w.window, cue0, [], [Cuex1 Cuey1 Cuex2 Cuey2]);
        cue_on = Screen('Flip', w.window);
        Waitsecs(cue_time);
        condition = 0;
        cue_onset = cue_on - start_time;
    elseif order(trial_num) == 2
        DrawFormattedText(w.window, Low, 'center', 'center', text_color);
%         Screen('DrawTexture', w.window, cue1, [], [Cuex1 Cuey1 Cuex2 Cuey2]);
        cue_on = Screen('Flip', w.window);
        Waitsecs(cue_time);
        condition = 1;
        cue_onset = cue_on - start_time;
    elseif order(trial_num) == 3
        DrawFormattedText(w.window, High, 'center', 'center', text_color);
%         Screen('DrawTexture', w.window, cue2, [], [Cuex1 Cuey1 Cuex2 Cuey2]);
        cue_on = Screen('Flip', w.window);
        Waitsecs(cue_time);
        condition = 2;
        cue_onset = cue_on - start_time;
    end
    
    
    % Delay Period 1
%     Screen('DrawTexture', w.window, fix, [], [Fixx1 Fixy1 Fixx2 Fixy2]);
    DrawFormattedText(w.window, '+', 'center', 'center', fix_color);
    delay1_on = Screen('Flip', w.window);
%     WaitSecs(delay1);
    
while GetSecs-delay1_on < delay1,
    [ keyIsDown, timeSecs, keyCode ] = KbCheck;
    % too early response
    if strcmpi(KbName(keyCode),decide_key)
%         Screen('TextSize',w.window, 25);
        early_response =1;
        response_flag = 1;
        response = 1;
        trial_time = NaN;
        DrawFormattedText(w.window, 'Too early', 'center', 'center', [255,0,0]);
        Screen('Flip',w.window);
        Waitsecs(0.5);
    end       
end
    
     % appropriate response regardless of hit or miss
     % Target Presentation   
    if early_response ==0
        Screen('DrawTexture', w.window, target, [], [Targetx1 Targety1 Targetx2 Targety2]);
        trial_on_time = Screen('Flip', w.window);
        trial_time = trial_on_time - start_time;

        while GetSecs-trial_on_time < target_time,

            if response_flag == 0

                [ keyIsDown, timeSecs, keyCode ] = KbCheck;
                WaitSecs(.001);
                if keyCode(KbName(stopkey))
                    clear screen;
                    return;
                end

                if strcmpi(KbName(keyCode),decide_key)
                   trial_off_time = GetSecs;
                   RTime = trial_off_time - trial_on_time;
                   response_key = KbName(keyCode);
                   response_flag = 1;
                   response = 1;
                   while KbCheck; end;
                end
            end
        end
    end
        Screen('FillRect',w.window, [w.gray w.gray w.gray]);
        Screen('Flip', w.window);
        
   if early_response ==0
        while GetSecs - trial_on_time < 2,

            if response_flag == 0
                [ keyIsDown, timeSecs, keyCode ] = KbCheck;
                WaitSecs(.001);
                if (strcmpi(KbName(keyCode),stopkey))
                    clear screen;
                    return;
                end

                if (strcmpi(KbName(keyCode),decide_key)),
                    trial_off_time = GetSecs;
                    RTime = trial_off_time - trial_on_time;
                    response_key = KbName(keyCode);
                    response = 1;
                    response_flag = 1;
                end
            end
        end
   end
    
    % Outcome Presentation
    if early_response ==0
        if RTime <= target_time
            if order(trial_num) == 3
                DrawFormattedText(w.window, 'You won $2.00', 'center', 'center', win_color);
%                 money_earned(trial_num,:) = 2;
            elseif order(trial_num) == 2
                DrawFormattedText(w.window, 'You won $0.20', 'center', 'center', win_color);
%                 money_earned(trial_num,:) = 0.2;
            elseif order(trial_num) == 1
                DrawFormattedText(w.window, 'You won $0.00', 'center', 'center', win_color);
            end
            outcome_on = Screen('Flip', w.window);
            outcome_onset = outcome_on - start_time;
            performance = 1;
            type = 1;
            sum = sum +1;
            WaitSecs(outcome_time);
        elseif RTime >= target_time
            DrawFormattedText(w.window, 'Miss!', 'center', 'center', lose_color);
            outcome_on = Screen('Flip', w.window);
            outcome_onset = outcome_on - start_time;
            performance = 0;
            type = 2;
            WaitSecs(outcome_time);
        elseif response_flag == 0
            DrawFormattedText(w.window, 'Miss!\n\n\n\n Press the button.', 'center', 'center', [255,0,0]);
            outcome_on = Screen('Flip', w.window);
            outcome_onset = outcome_on - start_time;
            performance = 0;
            type = 3;
            WaitSecs(outcome_time);
        end
    elseif early_response ==1
        DrawFormattedText(w.window, 'Wait for a target!', 'center', 'center', text_color);
        outcome_on = Screen('Flip', w.window);
        outcome_onset = outcome_on - start_time;
        performance = 0;
        type = 4;
        WaitSecs(outcome_time);
    end
    
    
    Screen('FillRect',w.window, [w.gray w.gray w.gray]);
    Screen('Flip', w.window);   
    WaitSecs(ITI);
   
   MID.data(trial_num).cue_onset = cue_onset;
   MID.data(trial_num).outcome_onset = outcome_onset;
   MID.data(trial_num).delay1_duration = delay1;
   MID.data(trial_num).RTime = RTime;
%    MID.data(trial_num).response_key = response_key;
   MID.data(trial_num).response = response;
   MID.data(trial_num).target_onset = trial_time;
   MID.data(trial_num).condition = condition;
   MID.data(trial_num).performance = performance;
   MID.data(trial_num).type = type;
   MID.data(trial_num).target_duration = target_time;
   save([output_dir filesep out_file], 'MID');
   response_flag = 1;
    [ keyIsDown, timeSecs, keyCode ] = KbCheck;
    WaitSecs(.001);
    if strcmpi(KbName(keyCode),stopkey)
        clear screen;
        return;
    end
    
    % Dynamically adjust target time

        if sum/trial_num > target_accuracy
            if (performance == 1) || (MID.data(trial_num-1).performance == 1)
            target_time = target_time - 0.025;
            end
        elseif sum/trial_num <= target_accuracy
            if (performance == 0) || (MID.data(trial_num-1).performance == 0)
            target_time = target_time + 0.025;
            end
        end
        
        if target_time > max_target_time
        target_time = max_target_time;
        elseif target_time < min_target_time
        target_time = min_target_time;
        end
        
end

MID.expt_details.date = date;
save([output_dir filesep out_file], 'MID');

% clear screen;

%% simple analysis

cd(output_dir);
load([subid '_MID' num2str(session) '.mat']);

format bank;
performance1 =[MID.data(1,:).performance];
condition1 =[MID.data(1,:).condition];
combined1 = [condition1',performance1'];
combined2 = sortrows(combined1);
non_performance =[];
low_performance = [];
high_performance = [];
for i= 1:num_trials,
    if combined2(i,1)==0 && combined2(i,2)==1
        non_performance = [non_performance +1];
    elseif combined2(i,1)==1 && combined2(i,2)==1
        low_performance = [low_performance +1];
    elseif combined2(i,1)==2 && combined2(i,2)==1
        high_performance = [high_performance +1];
    end
end
Non = size(non_performance,2)./neutral_trial
Low = size(low_performance,2)./neutral_trial
High = size(high_performance,2)./neutral_trial
All = sum./num_trials
Money_earned = 0.2*size(low_performance,2) + 2*size(high_performance,2)

DrawFormattedText(w.window, '+', 'center', 'center', fix_color);
Screen('Flip',w.window);
WaitSecs(8)

end_message = ['Thank you!'];
%     Screen('TextSize',w.window, 25);
    DrawFormattedText(w.window, end_message, 'center', 'center', text_color);
    Screen('Flip',w.window);
    
    while 1
        [ keyIsDown, timeSecs, keyCode ] = KbCheck;
        WaitSecs(.001);
        if (strcmpi(KbName(keyCode),stopkey))
            WaitSecs(0.7)
            clear screen;
            return;
        end
    end