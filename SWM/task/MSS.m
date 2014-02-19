function MSS(tdfile,resource_path)

%%MSS(tdfile,resource_path) 
%This is a program which presents text, sound and video stimuli using a
%text delimited "script" that is compatible with Mac Stim, with certain
%added features. 
%
%tdfile should be a tab delimited file with fields:
%[type,num,pre,maxTime,totTime,rep,stpEvt,bg,st,bgFile,stFile,hshift,vshift]= textread( tab_delimited_text_file, '%c %d %f %f %f %d %s %c %c %s %s %d %d','delimiter', '\t', 'whitespace', '', 'commentstyle', 'matlab' );
%
%If you are not running your script from the directory that holds your
%tdfile, you should specify the entire path, e.g.
%/top_dir/mid_dir/location_of_td_file/tdfile.txt 
%
%resource_path is an optional field containing the location of your resources, with default as same dir
%as tdfile

%% Set up variables for subject info and script info

DEBUG = 1;
PRINT_OUTPUT = 1; %Results will always print to screen, PRINT_OUTPUT determines whether gets saved to txt file as well


experiment_name='SWMCWM';
experiment_code='WM';  % this should be a short (2-3 letter) code for the experiment
                        % it will be put as part of the data file name
script_revision_date='04/24/12';
    %Originally created 12/14/07 by Emily Falk
    %Revisions
        %7/11/08: Updated to preload sound and movie resources; Updated to allow specification of path for tdfile and
        %resource files
        %7/20/08: Fixed bugs with key checking; updated to record all key
        %presses that occur, in parallel with the rest of the code
        %(independent of stop events)
        %8/6/08: Updated to take argument re: input device
        %8/18/08: Customized fields for MEMES
        %9/18/08: Newest includes ability to scale movie files, cleans
        %numeric output (so 4$ --> 4), fixed bug that was presenting ms ISI
        %when ISI set to 0, allows truncation of video, allows
        %randomization of blocks and trials
        %10/02/08: Includes increased functionality in pre, and better
        %efficiency
        
experiment_notes='';

% print out the experiment information
fprintf('%s (revised %s)\n',experiment_name, script_revision_date);

% read in subject code
subject_code=input('Enter subject code: ','s'); % the 's' tells input to take in a text string rather than a number

% read in input device
% button_box = input('Do you want to use the button box? [Enter 1 if yes, 0 if no]: ');
% 
% if DEBUG
%     button_box
% end;

subdevice_string='- Choose device for PARTICIPANT responses -'; boxTop(1:length(subdevice_string))='-';
fprintf('\n%s\n%s\n%s\n',boxTop,subdevice_string,boxTop)
inputDevice = hid_probe;

%% Basic Input Testing

%make sure that the input script (tdfile) is actually a file
if ~exist(tdfile,'file')
    fprintf('Your input script %s does not exist.  Make sure you have the right path and filename.\n',tdfile);
else
    
    slash = findstr('/',tdfile); %find the slashes in the path specified for tdfile
    
    if isempty(slash) %if there are no slashes, we assume that no directory was provided and thus assume that tdfile is in the same dir with the MSS script
        tdfile_path = [pwd '/'];
    else    
        tdfile_path = tdfile(1:slash(end)); %if there are slashes, we assume that everything preceeding the last slash is the directory and everything following is the file name for your script
    end;
    
    if DEBUG
        fprintf('tdfile_path = %s\n',tdfile_path)
    end;
    
    %read in tab delimited file set up like MacStim (textread will read in as col vectors)
    [type,num,pre,maxTime,totTime,rep,stpEvt,bg,st,bgFile,stFile,hshift,vshift]= textread(tdfile, '%c %d %f %f %f %d %s %c %c %s %s %d %d','delimiter', '\t', 'whitespace', '', 'commentstyle', 'matlab' );
end;

%Note: defaults for totTime, stpEvt, bgFile and stFile established elsewhere
if ~exist('resource_path') %if no resource path is specified, we assume that the resources are in the same dir as your tdfile script
    resource_path = tdfile_path;
elseif isempty(resource_path)
    resource_path = tdfile_path;
end;

if ~exist(resource_path,'dir')
    fprintf('WARNING: %s IS NOT A VALID PATH.\n',resource_path);
    return
end;

if resource_path(1) ~= '/' %if resource_path does not start with a slash we assume that the resource dir is relative to the tdfile dir
    resource_path = [tdfile_path resource_path];
end;

if resource_path(end) ~= '/' %make sure resource_path ends in a slash so that it can be concatenated with stimulus file names later
    resource_path = [resource_path '/'];
end;

if DEBUG 
    fprintf('resource_path = %s\n', resource_path);
end;
    
if length(hshift) ~= length(stFile)
    fprintf('Warning: the vector hshift is shorter than the number of trials you have.  Filling with zeros\n');
    hshift = [hshift zeros(1,length(stFile)-length(hshift))];
end;

if length(vshift) ~= length(stFile)
    fprintf('Warning: the vector vshift is shorter than the number of trials you have.  Filling with zeros\n');
    vshift = [vshift zeros(1,length(stFile)-length(vshift))];
end;

if length(type) ~= length(stFile)
    fprintf('Warning: Your type vector and your stFile vector do not match in length\n');
end;

if length(pre) ~= length(stFile)
    fprintf('Warning: Your pre vector and your stFile vector do not match in length\n');
end;

if length(maxTime) ~= length(stFile)
    fprintf('Warning: Your maxTime vector and your stFile vector do not match in length\n');
end;

if length(totTime) ~= length(stFile)
    fprintf('Warning: Your totTime vector and your stFile vector do not match in length\n');
end;

if length(stpEvt) ~= length(stFile)
    fprintf('Warning: Your stpEvt vector and your stFile vector do not match in length\n');
end;

if length(bg) ~= length(stFile)
    fprintf('Warning: Your bg vector and your stFile vector do not match in length\n');
end;

if length(st) ~= length(stFile)
    fprintf('Warning: Your st vector and your stFile vector do not match in length\n');
end;

if length(bgFile) ~= length(stFile)
    fprintf('Warning: Your bgFile vector and your stFile vector do not match in length\n');
end;


for c = 1:length(stFile)
    
    if isempty(type(c))
        fprintf('In the future, you should specify a type for trial %d.  Reverting to default (s)\n',c);
        type(c) = 's';
    end;
     
    if isempty(num(c))
        fprintf('Reverting to default (1) for num(%d)\n',c)
        num(c) = '1';
    end;
        
    if isempty(pre(c))
        fprintf('Reverting to default (0) for pre(%d)\n',c)
        pre(c) = 0;
    end;
    
    %if isempty(maxTime(c))
    %    fprintf('Reverting to default (totTime) for maxTime(%d)\n',c)
    %    bg(c) = totTime(c);
    %end;
        
    %if isempty(totTime(c))
    %    fprintf('Reverting to default (maxTime) for totTime(%d)\n',c)
    %    bg(c) = maxTime(c);
    %end;
    
    if isempty(bg(c))
        fprintf('Reverting to default (t) for bg(%d)\n',c)
        bg(c) = 't';
    end;
    
    if isempty(st(c))
        fprintf('Reverting to default (t) for st(%d)\n',c)
        st(c) = 't';
    end;
    
    if isempty(rep(c))
        fprintf('Reverting to default rep for rep(%d)\n',c)
        rep(c) = 1;
    end;
    
end;
    
    
if DEBUG
    fprintf('stFile{1} = %s\n',stFile{1});
    fprintf('hshift = %d\n',hshift);
    fprintf('vshift = %d\n',vshift);
end;

if ~exist('tdfile'), 
	fprintf('File does not exist\n');
    return;
end;

%% Define Defaults and storage variables

for i=1:length(stFile)
    
    if DEBUG
        fprintf('stFile{i} pre = %s\n',stFile{i});
        fprintf('resource_path = %s\n',resource_path);
    end;
    
    %text does not need a relative directory structure, but for all other
    %resources, makes sure that directory is appended to the front of the
    %filename
    
    stFileName{i} = stFile{i}; %we will append path to all files names in next loop, but later we want to output stFile without path info when specifying output 
    bgFileName{i} = bgFile{i}; %same as above
    
    if st(i) ~= 't' && ~isempty(stFile{i})
        stFile{i} = [resource_path stFile{i}];
    end;
        
    if bg(i) ~= 't' && ~isempty(bgFile{i})
        bgFile{i} = [resource_path bgFile{i}];
    end;  
    
    if DEBUG
        fprintf('stFile{i} post = %s\n',stFile{i});
    end;
end;

% set up variables controlling trials and defaults
trigger=KbName('5%');
number_of_trials=length(stFile);
default_stimulus_duration=2; % time for stimulus, in seconds
interstimulus_interval= 0; % default time between trials, in seconds
trial_order = calculate_trial_order(type,num); %default stimulus order is consecutive
default_wrap = 600; %in pixels
default_display = sprintf('DrawFormattedText_new(w,''+'',''center'', ''center'',black, default_wrap,0,0);');
nrchannels = 2; %default number of channels for sound playback is 1 = mono (if you have stereo sound, use nrchannels = 2)

% set up variables to store data
rt =zeros(1,number_of_trials); %vector to hold reaction times
resp = cell(1,number_of_trials); %vector to hold responses made
onset = zeros(1,number_of_trials); %vector to record the actual onset of each trial
duration = zeros(1,number_of_trials); %vector to record the duration of each trial
key_presses = struct('key',{{}},'time',[],'stimulus',{{}}); %matrix to hold key pressed, time of key press, and current stimulus (will increment up)


%% set up input devices
% numDevices=PsychHID('NumDevices');
% devices=PsychHID('Devices');
%  
% if DEBUG
%     devices.product
% end;
% 
% 
% %makes start device the control computer (see note below re: customizing to your computer)
% for k = 1:numDevices,
%     if DEBUG
%         fprintf('I got into the k = 1:numDevices loop\n')
%     end;
%     
%     if (strcmp(devices(k).transport,'USB') && strcmp(devices(k).usageName,'Keyboard') && strcmp(devices(k).product,'Apple Internal Keyboard / Trackpad')), %note: this is the name of my default device-- may need to be updated depending on your system
%         homeDevice=k;
%         if DEBUG
%             fprintf('Home Device is #%d (%s)\n',homeDevice,devices(homeDevice).product);
%         end;
%         break,
%     elseif (strcmp(devices(k).transport,'USB') && strcmp(devices(k).usageName,'Keyboard')) && ~strcmp(devices(k).product,'932'),
%         homeDevice=k;
%         fprintf('Defaulting: Home Device is #%d (%s)\n',homeDevice,devices(homeDevice).product);
%         break,
%     end;
% end;
% 
% %if button box was requested at start of experiment, use it, otherwise, use
% %the keyboard
% if button_box,
%     for n=1:numDevices,
%         if (strcmp(devices(n).transport,'USB') && strcmp(devices(n).usageName,'Keyboard') && strcmp(devices(n).product,'932')),
%             inputDevice=n;
%                 fprintf('Using Device #%d (%s)\n',inputDevice,devices(inputDevice).product);
%             break,
%         end;
%     end;
% else
%     for n=1:numDevices,
%         if (strcmp(devices(n).transport,'USB') && strcmp(devices(n).usageName,'Keyboard') && ~strcmp(devices(n).product,'932')),
%             inputDevice=n;
%             break,
%         elseif (strcmp(devices(n).transport,'Bluetooth') && strcmp(devices(n).usageName,'Keyboard')),
%             inputDevice=n;
%             break,
%         elseif strcmp(devices(n).transport,'ADB') && strcmp(devices(n).usageName,'Keyboard'),
%             inputDevice=n;
%         end;
%     end;
%         fprintf('Using Device #%d (%s)\n',inputDevice,devices(n).product);
% end;


%% Create place to save the data collected to a file

d=clock; % read the clock information
		 % this spits out an array of numbers from year to second

output_filename=sprintf('%s_%s_%s_%s_%02.0f-%02.0f.mat',subject_code,experiment_code,tdfile,date,d(4),d(5));

% create a data structure with info about the run
run_info.subject_code=subject_code;
run_info.output_filename=output_filename;
run_info.experiment_notes=experiment_notes;
run_info.stimulus_input_file=tdfile;
run_info.script_revision_date=script_revision_date;
run_info.script_name=mfilename; % saves the name of the script
run_info.onsets=onset;
run_info.durations=duration;
run_info.responses=resp;
run_info.rt=rt;
run_info.trial_order=trial_order;

% save the data to the desired file
save(output_filename,'run_info','key_presses');

%% Setup initial screen & display settings

HIDeCursor;

% Set up the onscreen window, and fill with white (255)
Screen('Preference', 'Verbosity', 1);
screens=Screen('Screens');
screenNumber=max(screens);
[w, rect]=Screen('OpenWindow', screenNumber,0,[],32,2);
[wWidth, wHeight]=Screen('WindowSize', w);
grayLevel=255;
Screen('FillRect', w, grayLevel);  % NB: only need to do this once!
Screen('Flip', w);


% set up screen positions for stimuli
xcenter=wWidth/2;
ycenter=wHeight/2;

% setup basic colors
black=BlackIndex(w); % Should equal 0.
white=WhiteIndex(w); % Should equal 255.

% use Arial font
theFont='Arial';
Screen('TextFont',w,theFont);

% use 48 point font in black
Screen('TextSize',w, 30);
Screen('TextColor',w,black);
    

%% Pre-Load Sound, Picture and Video Resources, and calculate timings

stMovieList = zeros(1,length(st)); %initialize list of movie media files
stSoundList = cell(length(st),2); %initialize list of sound media files
imagetex = zeros(1,length(st)); %initialize imagetex for pics
pRect = cell(1,length(st));
stimulus_duration = zeros(1,length(st));

for i = 1:length(st),
    if DEBUG
        fprintf('Preloading: i = %d\n',i);
        fprintf('Preloading: file = %s\n',stFile{i});
    end;
    
    %preload movies
    if st(i) == 'm'
	[movie movieduration fps imgw imgh] = Screen('OpenMovie', w, stFile{i});
        stMovieList(i) = movie;

     
    %preload sounds    
    elseif st(i) == 's'
        [x,fs] = wavread(stFile{i}); %read in wav file info
        stSoundList{i,1} = x;
        stSoundList{i,2} = fs;
        
        if DEBUG
            fprintf('Trying to read sound from line %d\n',i)
        end;
    
     %preload pics
    elseif st(i) == 'p'
        if exist(stFile{i},'file') ~= 2 %if file doesn't exist, skip trial
            fprintf('Warning: your file %s does not exist on trial %d.\n',stFile{i},i);
            continue;
        end;
        a = strcmp(stFile,stFile{i});
        b = strcmp(st,st(i));
        h = zeros(length(st),1);
        h(find(hshift==hshift(i))) = 1;
        v = zeros(length(st),1);
        v(find(vshift==vshift(i))) = 1;
        c = a.*b.*h.*v;
        f = find(c,1);
        if f < i
            imagetex(i)=imagetex(f);
        else
            img = imread(stFile{i});
            itex = Screen('MakeTexture', w, img);
            imagetex(i) = itex;
         %offsets image by amount specified in hshift and vshift
            pr = CenterRect(Screen('Rect', imagetex(i)),Screen('Rect',w)); 
            pr=OffsetRect(pr, hshift(i), vshift(i));
            pRect{i}=pr;
            clear img;
        end
    end;
    
    if bg(i) == 'p'
        if exist(bgFile{i},'file') ~= 2 %if file doesn't exist, skip trial
             fprintf('Warning: your file %s does not exist on trial %d.\n',bgFile{i},i);
            continue;
        end;
        
        a = strcmp(stFile,stFile{i});
        b = strcmp(st,st(i));
        h = zeros(length(st),1);
        h(find(hshift==hshift(i))) = 1;
        v = zeros(length(st),1);
        v(find(vshift==vshift(i))) = 1;
        c = a.*b.*h.*v;
        f = find(c,1);
        if f < i
            bg_imagetex(i)=bg_imagetex(f);
        else
            img = imread(bgFile{i});
            itex = Screen('MakeTexture', w, img);
            bg_imagetex(i) = itex;
             %offsets image by amount specified in hshift and vshift
            pr = CenterRect(Screen('Rect', bg_imagetex(i)),Screen('Rect',w)); 
            pr=OffsetRect(pr, hshift(i), vshift(i));
            bRect{i}=pr;
            clear img;
        end
    end;
    
    %set stimulus duration
    if ~isempty(maxTime(i)) && st(i) ~= 's'
        stimulus_duration(i) = maxTime(i);
        if maxTime(i) == 0 %this happens if left blank in worksheet (textread function reads blanks as zeros)
            stimulus_duration(i) = default_stimulus_duration;
            fprintf('WARNING: reverted to default stimulus duration for cycle %d, st = %s, maxTime(i) = %f\n',i,stFile{i},maxTime(i))
        end;
    elseif st(i) == 's'
        %Pre calculate sound lengths
        %Note: stSoundList{i,1} = x = actual audio, stSoundList{i,2} = fs =frames/sec 
        if maxTime(i) == 0 || isempty(maxTime(i)); %if no time is specified
            stimulus_duration(i) = (size(stSoundList{i,1},1)/stSoundList{i,2});
        elseif size(stSoundList{i,1},1)/stSoundList{i,2} >= maxTime(i) %if length of sound file is greater than the time specified, play only for time specified
            stSoundList{i,1}=stSoundList{i,1}(1:round(stSoundList{i,2}*maxTime(i)));
            stimulus_duration(i) = maxTime(i);
        elseif size(stSoundList{i,1},1)/stSoundList{i,2} < maxTime(i) %if length of sound file is less than total time specified, make stimulus duration (which starts after sound is played) the difference between file length and desired time
            stimulus_duration(i) = maxTime(i);
            if DEBUG
                fprintf('Made it into this loop. Sound stimulus duration = %f\n',stimulus_duration(i));
            end;     
        end;
    else
        stimulus_duration(i) = default_stimulus_duration;
        if DEBUG
            fprintf('Reverting to default stimulus duration on cycle %d\n',i);
        end;
    end;

    if isempty(stFile{i}) && st(i) == 't'
        fprintf('Warning: stFile{%d} = []\n',i);
        stFile{i} = '+'; %default to fixation cross
    end;
    
end;

if ~isempty(find(st == 's',1))
    % Perform basic initialization of the sound driver:
    InitializePsychSound;
    PsychPortAudio('Verbosity',1);
end;

%% Start experiment and Cycle through trials

%start experiment with key press

DrawFormattedText_new(w,'You are about to start the task. You will complete a series of trials each with either 2, 3, or 4 friend names. And, for each trial you will be instructed to either think about their personalities or alphabetize their names.','center','center',black, default_wrap, 0, 0);
Screen('Flip',w);

% KbWait(homeDevice);  % wait for keypress

%---------------------------------------------------------------
%% WAIT FOR TRIGGER
%---------------------------------------------------------------
secs=KbTriggerWait(trigger,inputDevice);	% wait for trigger, return system time when detected
anchor=secs;		% anchor timing here (because volumes are discarded prior to trigger)
DisableKeysForKbCheck(trigger);     % So trigger is no longer detected
WaitSecs(0.001);


%% Set up stims

experiment_start_time = GetSecs;

for j = 1:number_of_trials,
    i = trial_order(j); %run the stimuli in the order specified by the trial_order array
    
    pre_start_time = GetSecs; %anchor as start of trial 
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %SETUP BACKGROUND STIMULUS IF ONE IS GIVEN
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    if ~isempty(bgFile{i}) %if a background file has been specified
        if bg(i) == 't' %background is text
            bg_display = sprintf('DrawFormattedText_new(w,bgFile{i},''center'', ''center'',black, default_wrap,hshift(i),vshift(i));'); 
        elseif bg(i) == 'p' %background is a picture
            %sets image up for the screen
            bg_display = sprintf('Screen(''DrawTexture'',w,bg_imagetex(i),[],bRect{i});');
        end; 
    else %if no background is specified, default background is fixation cross
        bg_display = default_display;
        if DEBUG
            fprintf('reverting to default background on cycle %d\n',i);
        end;
    end;
    
   
    %Display background stimulus for time specified in pre
    if pre(i) > 0
        eval(bg_display);
        Screen('Flip',w);
        while GetSecs < pre_start_time+pre(i)
            [keyIsDown,secs,keyCode]=KbCheck(inputDevice);
            if keyIsDown, %key is pressed
                key_presses.key{length(key_presses.key)+1} = KbName(keyCode);
                key_presses.time(length(key_presses.time)+1) = GetSecs - experiment_start_time;
                if isempty(bgFileName{i})
                    key_presses.stimulus{length(key_presses.stimulus)+1} = ['pre stimulus displayed,  bg was ' bgFileName{i}];
                else    
                    key_presses.stimulus{length(key_presses.stimulus)+1} = [bgFileName{i} 'displayed, during pre stimulus interval '];
                end
            end;
            while keyIsDown && GetSecs < pre_start_time+pre(i)
                [keyIsDown,secs,keyCode]=KbCheck(inputDevice);
                WaitSecs(0.001);
            end
        end;
    end;
    
    %%%%%%%%%%%%%%%%%%%%%%%
    %SETUP PRIMARY STIMULUS
    %%%%%%%%%%%%%%%%%%%%%%%
    
    if st(i) == 'm' %primary stimulus is a movie        
        start_time = GetSecs;
        onset(i) = start_time - experiment_start_time;
        [resp{i} keys movie_start] = DisplayMovie(stMovieList(i),w,stpEvt{i},maxTime(i),inputDevice); %this function plays a movie and sound simultaneously
       
        if ~isempty(keys)
            key_presses.key = [key_presses.key keys.key]; %append keys pressed during movie to key_presses
            key_presses.time = [key_presses.time keys.time + movie_start - experiment_start_time];
            key_presses.stimulus = [key_presses.stimulus arrayfun( @(x) stFileName{i},zeros(1,length(keys.key)),'UniformOutput',false)];
        end; 

        %update key info to save
        run_info.onsets=onset;
        run_info.durations=duration;
        run_info.responses=resp;
        run_info.rt=rt;

        % save the data to the desired file
        save(output_filename,'run_info','key_presses');
        
    else
        if st(i) == 't' %primary stimulus is text

            if DEBUG
                fprintf('stFile(%d) = %s\n',i,stFile{i});
                fprintf('size(stFile(%d)=%d\n',i,size(stFile{i},2));
            end;

            % setup text to be displayed (as written, will center text and
            % wrap at default_wrap pixels)
            displaycommand = sprintf('DrawFormattedText_new(w,stFile{i},''center'', ''center'',black, default_wrap,hshift(i),vshift(i));');

        elseif st(i) == 's' %primary stimulus is sound
            eval(bg_display); %present the background file while sound is playing
            Screen('Flip',w);
            
            t1 = GetSecs;
            
            % Open the default audio device [], with default mode [] (==Only playback),
            % and a required latencyclass of zero 0 == no low-latency mode, as well as
            % a frequency of stSoundList{i,2} = fs, and nrchannels sound channels.
            % This returns a handle to the audio device:
            pahandle = PsychPortAudio('Open', [], [], 1, stSoundList{i,2},nrchannels);
            
            % Fill the audio playback buffer with the audio data 'stSoundList{i,1} = x from above':
            PsychPortAudio('FillBuffer', pahandle, stSoundList{i,1}');
            t2 = GetSecs;
            
            if DEBUG
                fprintf( 'It took %f seconds to open PsychPortAudio and fill the buffer in iteration %d\n',t2-t1,i);
            end

            % Start audio playback for 'repetitions' repetitions of the sound data,
            % start it immediately (0) and wait for the playback to start, return onset
            % timestamp.
            t1 = PsychPortAudio('Start', pahandle, rep(i), 0, 1);
            onset(i) = t1 - experiment_start_time; %sound onset
            sound_closed = 0;

            displaycommand = bg_display; %For sound, foreground and background images are same
            
        elseif st(i) == 'p' %primary stimulus is a picture
           displaycommand = sprintf('Screen(''DrawTexture'',w,imagetex(i),[],pRect{i});');
        end; % if st(i)
        
        if DEBUG
            fprintf('\ni= %d,\nst(i) = %c\n',i, st(i));
            fprintf('displaycommand = %s\n\n',displaycommand);
        end;


        %%%%%%%%%%%%%%%%%%%%%%%
        %Put stimuli on screen
        %%%%%%%%%%%%%%%%%%%%%%%
        
        t1 = GetSecs;
        eval(displaycommand);
        [vbltime,start_time]=Screen('Flip',w);
        t2 = GetSecs;
        fprintf('We needed %f seconds to Draw texture %d.\n',t2-t1,i)
        
        if st(i) ~= 's' %can't be a movie here
            onset(i) = start_time - experiment_start_time; %get onset of the stimulus for text and picture stims (movies and sound recorded above)
        end;
     
        %update key info to save
        run_info.onsets=onset;
        run_info.durations=duration;
        run_info.responses=resp;
        run_info.rt=rt;
    
        % save the data to the desired file
        save(output_filename,'run_info','key_presses');

        %wait for a response, or for the trial to end (whichever comes first)
        no_response_yet=1;
        
        %p = pause trial
        while (type(i) == 'p' && no_response_yet == 1) || (type(i) ~= 'p' && no_response_yet == 1 && GetSecs < start_time + stimulus_duration(i)),
            [keyIsDown,secs,keyCode]=KbCheck(inputDevice);
            if keyIsDown, %key is pressed
                key_presses.key{length(key_presses.key)+1} = KbName(keyCode);
                key_presses.time(length(key_presses.time)+1) = GetSecs - experiment_start_time;
                key_presses.stimulus{length(key_presses.stimulus)+1} = stFileName{i};
                
                if is_stop_event(keyCode,stpEvt{i}) %checks if key is one specified as a stop event
                    no_response_yet=0;
                    rt(i)=secs-start_time; %record response
                    resp{i}=KbName(keyCode); %record key pressed
                    
                    if st(i) == 's'
                        % Stop playback:
                        PsychPortAudio('Stop', pahandle);
                        % Close the audio device:
                        PsychPortAudio('Close', pahandle);
                        sound_closed = 1;
                    end;
                    break;
                else
                    %Note: be aware that if you keep this part of the code,
                    %and specify certain stop events, if someone presses a
                    %key that is not a stop event and holds it down, no
                    %other keys will be recorded (including stop events)
                    %until the first key is released.
                  
                    while keyIsDown %wait until key is released to start outer loop again 
                        [keyIsDown,secs,keyCode]=KbCheck(inputDevice);
                        WaitSecs(0.001);
                    end
                end;
            end;
        end;
    end;
    
    if st(i) == 's' && ~sound_closed;
      
        % Stop playback:
        PsychPortAudio('Stop', pahandle);
        
        % Close the audio device:
        PsychPortAudio('Close', pahandle);
      
    end;
        
    duration(i) = GetSecs - onset(i) - experiment_start_time; %record actual stimulus duration time
        
    %For any remaining time, put up background
    if GetSecs < pre_start_time+totTime(i) && type(i) ~= 'p'
        eval(bg_display);
        Screen('Flip',w);
        while GetSecs < pre_start_time+totTime(i) && type(i) ~= 'p'

            [keyIsDown,secs,keyCode]=KbCheck(inputDevice);
            if keyIsDown, %key is pressed
                key_presses.key{length(key_presses.key)+1} = KbName(keyCode);
                key_presses.time(length(key_presses.time) +1) = GetSecs - experiment_start_time;
                if isempty(bgFileName{i})
                    key_presses.stimulus{length(key_presses.stimulus)+1} = ['default bg, st was ' stFileName{i}];
                else    
                    key_presses.stimulus{length(key_presses.stimulus) +1} = [bgFileName{i} ', st was ' stFileName{i}];
                end
            end;

            while keyIsDown && GetSecs < pre_start_time+totTime(i)
                [keyIsDown,secs,keyCode]=KbCheck(inputDevice);
                WaitSecs(0.001);
            end
        end;

    end;
    
    % Wait for interstimulus interval
    if interstimulus_interval ~= 0
        eval(default_display); %puts up default display for isi
        Screen('Flip',w);
        start_time = GetSecs;
        while GetSecs < start_time + interstimulus_interval,
            [keyIsDown,secs,keyCode]=KbCheck(inputDevice);
            if keyIsDown, %key is pressed
                key_presses.key{length(key_presses.key)+1} = KbName(keyCode);
                key_presses.time(length(key_presses.time)+1) = GetSecs - experiment_start_time;
                key_presses.stimulus{length(key_presses.stimulus)+1} = 'ISI';
            end

            while keyIsDown && GetSecs < start_time + interstimulus_interval
                [keyIsDown,secs,keyCode]=KbCheck(inputDevice);
                WaitSecs(0.001);
            end
            %WaitSecs(0.001);  % prevents overload and decrement of priority
        end;
    end;
    fprintf('It took %f seconds between pre_start_time and onset.\n',onset(i)-pre_start_time +experiment_start_time)
end;%for j

Screen('Close');
fprintf('The experiment lasted %f seconds\n',GetSecs-experiment_start_time)
%% Post Processing of Data

%clean up numeric responses (e.g. 3# --> 3)
run_info.responses = clean_output(run_info.responses);
key_presses.key = clean_output(key_presses.key);

% save the final, cleaned data to the desired file
save(output_filename,'run_info','key_presses');

% after everything is done, clear the screen
Screen('CloseAll'); % Close all screens, return to windows.
ShowCursor;

%print a report
experiment_output(output_filename,PRINT_OUTPUT); %Results will always print to screen, PRINT_OUTPUT determines whether gets saved to txt file as well


