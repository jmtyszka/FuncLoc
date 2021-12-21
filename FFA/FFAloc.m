% FFAloc.m

%%

% add generic routines to path (added by BS for Tim 32 PC, 12.04.2012)
basedir = pwd;
addpath([basedir filesep 'generic_routines']);

AssertOpenGL; %InitializeMatlabOpenGL(1);
Screen('CloseAll')

%RandStream.setDefaultStream(RandStream('mt19937ar','seed',sum(100*clock)));
rand('twister',sum(100*clock))

% Debugging mode flags
debugging_mode = 0;
eyetracking = 0;

% addpath(genpath('../generic_routines')); 

subj_id = input('Please enter subject ID:  ','s');

subj_responses = [];

% stim_category = input('objects or houses:  ','s');

stim_category = 'houses';
% stim_category = 'objects';

run_num = input('Enter run number:  ');

% addpath(genpath('/Users/catherineh/Desktop/FFA_localizer/generic_routines/'));
% %addpath(genpath('/Users/dkennedy/Desktop/matlab_scripts/Dan_scripts/movie/play_movie_fMRI/'));


%%
outdir = [basedir filesep 'out_data' filesep subj_id];
mkdir(outdir);

outfile = [subj_id '_FFA_' stim_category '_run' num2str(run_num) '_' datestr(now,30) '.mat'];
 
% % %Check to see if output file already exists
if exist([outdir filesep outfile])
    ButtonName = questdlg('WARNING: File Exists. Continuing will overwrite old data. Continue anyway?',...
        'Log File Exists',...
        'Yes','No','No');
    switch ButtonName
        case 'No'
            return;
    end
end


%% keyboard setup:

% for scanner trigger
[extKeyboard,intKeyboard] = find_keyboard;

KbName('UnifyKeyNames');
keys.stopkey = 'q';
keys.trigger = '5%';
keys.pausekey = 'p';

if ~debugging_mode,
    %     ListenChar(2);
    HideCursor;
end


%%

% % % for testing on single screen:
% % [w1.window] = Screen('Openwindow', 0, [128 128 128],[0 0 100 100]);
% % [w2.window] = Screen('Openwindow', 0, [128 128 128],[120 120 220 220]);

Screen('Preference', 'SkipSyncTests', 1)

screens=Screen('Screens');
screenNumber=max(screens);
[w1] = initialize_screen(screenNumber,[128 128 128]);

w1.datetime = clock;

% commented this out for PC which is at 1024 x 1280
% if ~debugging_mode,
%     if ~isequal([w1.ScreenWidth w1.ScreenHeight],[1600 1200])
%         disp('Screen resolution is not set to 1600 x 1200');
%         clear screen;
%         keyboard
%         return;
%     end
% end

% res_scaling_x = w2.res(3)/w1.res(3);
% res_scaling_y = w2.res(4)/w1.res(4);



%% stim:

resize_frac = 0.9375;
w1.resize_frac = resize_frac;

faces_dir = [basedir filesep 'localizer_images/faces'];
houses_dir = [basedir filesep 'localizer_images/houses'];
objects_dir = [basedir filesep 'localizer_images/objects'];
% faces_dir = '/Users/catherineh/Desktop/FFA_localizer/localizer_images/faces';
% houses_dir = '/Users/catherineh/Desktop/FFA_localizer/localizer_images/houses';
% objects_dir = '/Users/catherineh/Desktop/FFA_localizer/localizer_images/objects';

for ii = 1:40,

    faces{ii} = imread( sprintf('%s/%d.jpg', faces_dir, ii) );
    houses{ii} = imread( sprintf('%s/%d.jpg', houses_dir, ii) );
    objects{ii} = imread( sprintf('%s/%d.jpg', objects_dir, ii) );
    
    faces{ii} = imresize( faces{ii} , resize_frac);
    houses{ii} = imresize( houses{ii} , resize_frac);
    objects{ii} = imresize( objects{ii} , resize_frac);
    
end



%%







%% define block and stim order


displayTime = .3;
ISI = .45;


start_delay = 15;
fix_block_dur = 15;
trialsPerBlock = 20;

stim_block_dur = trialsPerBlock*(displayTime+ISI);


dotsize = 5;
dotcolor = [256 256 256];
dottype = 2;

keyIsDown_ext_prev = 0;

if randsample(1:2,1) == 1,
    block_order = repmat( [ 1 2 ] , [ 1 6 ] );
else
    block_order = repmat( [ 2 1 ] , [ 1 6 ] );
end

%create stim_order, with exactly 6 incidental 1-backs
targets = 0;
while targets ~= 6
    for ii = 1:length(block_order), 
        stim_order{ii} = randsample(1:40,20,'true'); 
        targets_temp(ii) = sum(diff(stim_order{ii}) == 0); 
    end
    targets = sum(targets_temp);
%     disp(num2str(targets)); 
%     if max(targets_temp) > 1, 
%         targets = 0;
%     end
end

%%

if eyetracking
    MRI_eyecalibration_int(w1,1,1); %calibrate & validate
end

%%

disp(' ');
disp('Waiting for Scanner Trigger');
disp(' ');

[quit_flag] = WaitForScannerTrigger(w1,debugging_mode,keys,intKeyboard,extKeyboard,'The experiment will begin shortly...',40); %subfunction

trigger_time = GetSecs;

disp(' ');
disp('Trigger Received -- stimuli should be visible to participant');
disp(' ');

if quit_flag,
    disp('Experiment manually aborted.');
    ShowCursor;
    clear screen
    return;
end

%%

start_time = GetSecs;

Screen('DrawDots',w1.window,[w1.ScreenCenterX w1.ScreenCenterY],dotsize,dotcolor,[],dottype)
fixblock_on = Screen('Flip', w1.window);
while GetSecs - start_time <= fix_block_dur,
    %allow manual abort:
    [aaa,bbb, keyCode ] = KbCheck(intKeyboard);
    if (strcmpi(KbName(keyCode),keys.stopkey))
        end_time = GetSecs;
        disp('Experiment manually aborted.');
        clear screen;
        return;
    end
    
end

% stim_order{length_blocks} = randsample(1:40,20,'true');
aaa = [];
bbb = [];
for bb = 1:length(block_order), 
    block_start_time = GetSecs;

    for ii = 1:trialsPerBlock,

        
        
        if block_order(bb) == 1,
            texture = Screen('MakeTexture', w1.window, faces{stim_order{bb}(ii)});
        elseif block_order(bb) == 2,
            if strcmpi(stim_category,'houses'),
                texture = Screen('MakeTexture', w1.window, houses{stim_order{bb}(ii)});
            elseif strcmpi(stim_category,'objects'),
                texture = Screen('MakeTexture', w1.window, objects{stim_order{bb}(ii)});
            end
        end
        
        
        %show stim        
        Screen('DrawTexture',w1.window,texture);
        Screen('DrawDots',w1.window,[w1.ScreenCenterX w1.ScreenCenterY],dotsize,dotcolor,[],dottype)
        flip_time = Screen('Flip', w1.window);
        Screen('Close', texture);
        while GetSecs - flip_time <= displayTime,
            
            %check for subj response:
            [ keyIsDown_ext, timeSecs_ext, keyCode_ext ] = KbCheck(extKeyboard);
            if keyIsDown_ext && keyIsDown_ext_prev ~= 1,
                if (strcmpi(KbName(keyCode_ext),'1!')) ||(strcmpi(KbName(keyCode_ext),'2@')) ||(strcmpi(KbName(keyCode_ext),'3#')) || (strcmpi(KbName(keyCode_ext),'4$'))
                    subj_responses(end+1) = GetSecs - start_time;
                end
            end
            keyIsDown_ext_prev = keyIsDown_ext;
            
        end
        
        
        %ISI fixation time
        Screen('DrawDots',w1.window,[w1.ScreenCenterX w1.ScreenCenterY],dotsize,dotcolor,[],dottype)
        Screen('Flip', w1.window);
        while GetSecs - flip_time <= ISI + displayTime,
            
            
            %check for subj response:
            [ keyIsDown_ext, timeSecs_ext, keyCode_ext ] = KbCheck(extKeyboard);
            if keyIsDown_ext && keyIsDown_ext_prev ~= 1,
                if (strcmpi(KbName(keyCode_ext),'1!')) ||(strcmpi(KbName(keyCode_ext),'2@')) ||(strcmpi(KbName(keyCode_ext),'3#')) || (strcmpi(KbName(keyCode_ext),'4$'))
                    subj_responses(end+1) = GetSecs - start_time;
                end
            end
            keyIsDown_ext_prev = keyIsDown_ext;
            
            
        end

        aaa(end+1) = GetSecs - block_start_time;
        
    end
    
    %fixation_block
    Screen('DrawDots',w1.window,[w1.ScreenCenterX w1.ScreenCenterY],dotsize,dotcolor,[],dottype)
    fixblock_on = Screen('Flip', w1.window);
    while GetSecs - block_start_time <= fix_block_dur + stim_block_dur,
        %allow manual abort:
        [aaa,bbb, keyCode ] = KbCheck(intKeyboard);
        if (strcmpi(KbName(keyCode),keys.stopkey))
            end_time = GetSecs;
            disp('Experiment manually aborted.');
            clear screen
            return;
        end
        
    end
    
    bbb(end+1) = GetSecs - start_time;
end


%end with a fixation block:
Screen('DrawDots',w1.window,[w1.ScreenCenterX w1.ScreenCenterY],dotsize,dotcolor,[],dottype)
fixblock_on = Screen('Flip', w1.window);
while GetSecs - fixblock_on < fix_block_dur,
    %allow manual abort:
    [aaa,bbb, keyCode ] = KbCheck(intKeyboard);
    if (strcmpi(KbName(keyCode),keys.stopkey))
        end_time = GetSecs;
        disp('Experiment manually aborted.');
        clear screen
        break;
    end
end



total_time = GetSecs - start_time;


%%


% save params:
data.subj_id = subj_id;
data.date = datestr(now,30);
data.stim_category = stim_category;
data.block_order = block_order;
data.stim_order = stim_order;
data.targets = targets_temp;
data.subj_responses = subj_responses; 
data.total_time = total_time;

save([outdir outfile],'w1','data')



%% verify validation at the end of the experiment

if eyetracking
    MRI_eyecalibration_int(w1,0,1);  %no calibration, just validate
end

% WaitSecs(.2);

%% close screen

% Screen('Close', w1.window);
clear screen
ShowCursor;
% ListenChar(0);
disp(['total_time = ' num2str(total_time)]);

% w1.total_time = total_time;
% w2.total_time = total_time;

for ii = 1:20, 
disp('DONE_DONE_DONE_DONE_DONE_DONE_DONE_DONE_DONE_DONE_DONE_DONE_DONE_DONE_DONE_DONE_DONE_DONE_DONE_DONE_DONE_DONE_DONE_DONE');
end

return

