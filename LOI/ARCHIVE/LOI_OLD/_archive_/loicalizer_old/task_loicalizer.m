function task_loicalizer(subjectID,inputDevice,w)
%=========================================================================
% LOICALIZER
%=========================================================================

if nargin==0

    home
    %---------------------------------------------------------------
    %% PRINT VERSION INFORMATION TO SCREEN
    %---------------------------------------------------------------
    script_name='- Photo Judgment Test -'; boxTop(1:length(script_name))='=';
    fprintf('%s\n%s\n%s\n',boxTop,script_name,boxTop)
    %---------------------------------------------------------------
    %% GET USER INPUT
    %---------------------------------------------------------------
    % get subject ID
    subjectID=input('\nEnter subject ID: ','s');
    while isempty(subjectID)
        disp('ERROR: no value entered. Please try again.');
        subjectID=input('Enter subject ID: ','s');
    end;
    %---------------------------------------------------------------
    %% SET UP INPUT DEVICES
    %---------------------------------------------------------------
    subdevice_string='- Choose device for PARTICIPANT responses -'; boxTop(1:length(subdevice_string))='-';
    fprintf('\n%s\n%s\n%s\n',boxTop,subdevice_string,boxTop)
    inputDevice = hid_probe;
    
end

%---------------------------------------------------------------
%% DEFAULTS
%---------------------------------------------------------------

% instructions
instructions = ...
'For each photo, answer the question: Does the caption fit? \n\nPress 1 to say YES and 2 to say NO.';
wrapat = 42;
instructFontSize = 40;

% fixation options
theFont='Arial';
theFontSize=44;
posadd = 50;

% durations
maxDur = 3.5;
ITI = .5;

%---------------------------------------------------------------
%% WRITE TRIAL-BY-TRIAL DATA TO LOGFILE
%---------------------------------------------------------------
d=clock;
logfile=sprintf('sub%s_loicalizer.log',subjectID);
fprintf('\nA running log of this session will be saved to %s\n',logfile);
fid=fopen(logfile,'a');
if fid<1,
    error('could not open logfile!');
end;
fprintf(fid,'Started: %s %2.0f:%02.0f\n',date,d(4),d(5));
WaitSecs(.25);


% response keys
trigger=KbName('5%');
b1a=KbName('1');
b1b=KbName('1!');
b2a=KbName('2');
b2b=KbName('2@');
b3a=KbName('3');
b3b=KbName('3#');
b4a=KbName('4');
b4b=KbName('4$');
resp_set = [b1a b1b b2a b2b b3a b3b b4a b4b];

%---------------------------------------------------------------
%% INITIALIZE SCREENS
%---------------------------------------------------------------
% Screen('Preference', 'OverrideMultimediaEngine', 1);
screens=Screen('Screens');
screenNumber=max(screens);
if nargin==0
w=Screen('OpenWindow', screenNumber,0,[],32,2);
end
scrnRes     = Screen('Resolution',screenNumber);               % Get Screen resolution
[x0 y0]		= RectCenter([0 0 scrnRes.width scrnRes.height]);   % Screen center.
[wWidth, wHeight]=Screen('WindowSize', w);
xcenter=wWidth/2;
ycenter=wHeight/2;
priorityLevel=MaxPriority(w);
Priority(priorityLevel);

% colors
grayLevel=0;    
black=BlackIndex(w); % Should equal 0.
white=WhiteIndex(w); % Should equal 255.
Screen('FillRect', w, grayLevel);
Screen('Flip', w);

% text
Screen('TextSize',w,theFontSize);
theight = Screen('TextSize', w);
Screen('TextFont',w,theFont);
Screen('TextColor',w,white);

% movie defaults
rate=1;     % playback rate
movieSize=.75;     % 1 is fullscreen
maxTime=2.95;  % maximum time (in secs) to display each movie
dstRect = CenterRect(ScaleRect(Screen('Rect', w),movieSize,movieSize),Screen('Rect', w)); 

% cues
fixation='+';

% compute default Y position (vertically centered)
numlines = length(strfind(fixation, char(10))) + 1;
bbox = SetRect(0,0,1,numlines*theight);
[rect,dh,dv] = CenterRect(bbox, Screen('Rect', w));
PosY = dv - posadd;
% compute X position for fixation
bbox=Screen('TextBounds', w, fixation);
[rect,dh,dv] = CenterRect(bbox, Screen('Rect', w));
fixPosX = dh;
HideCursor;

%---------------------------------------------------------------
%% iNITIALIZE SEEKER VARIABLE
%---------------------------------------------------------------
% display GET READY screen
DrawFormattedText(w,'LOADING','center','center',white,wrapat);
Screen('Flip',w);
% get design (contains timing information)
load design.mat

% KEY for "blockSeeker"
% 1 - block #
% 2 - condition (1=aH,2=eH,3=aL,4=eL)
% 3 - onset (s)

% KEY for "trialSeeker"
% 1 - block #
% 2 - trial #
% 3 - condition (1=aH,2=eH,3=aL,4=eL)
% 4 - normative response (1=Yes, 2=No)
% 5 - slide # (corresponds to order in stimulus dir)
% 6 - actual onset
% 7 - response time (s) [0 if NR]
% 8 - actual response [0 if NR]
% 9 - actual offset
trialSeeker(:,6:9) = 0;

%---------------------------------------------------------------
%% GET AND LOAD STIMULI
%---------------------------------------------------------------
cd stimuli
stimpath = pwd;
d = dir('1*.jpg');
for i = 1:length(d)
   
    slideName{i} = d(i).name;
    slideTex{i} = Screen('MakeTexture',w,imread(slideName{i}));
    
end;
cd ..
Screen('FillRect', w, grayLevel);
Screen('Flip', w);
WaitSecs(0.1);
Screen('TextSize',w,instructFontSize);
% title = sprintf('Photo Judgment Test - Round %s',num2str(runID));
title = 'Photo Judgment Test';
fullinstruct = [title '\n\n' instructions];
% DrawFormattedText(w,fullinstruct,'center','center',white,wrapat);
tex = Screen('MakeTexture', w, imread('instruction.jpg'));
Screen('DrawTexture',w,tex);
Screen('Flip',w);
Screen('TextSize',w,theFontSize);


%---------------------------------------------------------------
%% WAIT FOR TRIGGER
%---------------------------------------------------------------
DisableKeysForKbCheck([]);
secs=KbTriggerWait(trigger,inputDevice);	% wait for trigger, return system time when detected
anchor=secs;		% anchor timing here (because volumes are discarded prior to trigger)
% DisableKeysForKbCheck(trigger);     % So trigger is no longer detected
WaitSecs(0.001);

%---------------------------------------------------------------
%% TRIAL PRESENTATION
%---------------------------------------------------------------

% present fixation cross until first trial cue onset
Screen('DrawText',w,fixation,fixPosX,PosY);
Screen('Flip', w);

try

nBlocks = length(blockSeeker);
nTrialsBlock = 5;

for b = 1:nBlocks
    
    % before first trial, present a GET READY message
    DrawFormattedText(w,'- GET READY -','center',PosY,white,wrapat);
    WaitSecs('UntilTime',anchor + blockSeeker(b,3) - 2);
    Screen('Flip',w);
    Screen('FillRect', w, grayLevel);
    
    % get part of trialSeeker for this block
    tmpSeeker = trialSeeker(trialSeeker(:,1)==b,:);

    % flip a blank screen before onset
    WaitSecs('UntilTime',anchor + blockSeeker(b,3) - .5);
    Screen('Flip', w);
    
    for t = 1:nTrialsBlock
        
        %-----------------
        % Present stimulus
        %----------------- 
        Screen('DrawTexture',w,slideTex{tmpSeeker(t,5)})
        if t==1
            WaitSecs('UntilTime',anchor + blockSeeker(b,3));
        else
            WaitSecs('UntilTime',anchor + offset + ITI);
        end
        Screen('Flip',w);
        onset = GetSecs;
        tmpSeeker(t,6) = onset - anchor;
        WaitSecs(.25)
        %-----------------
        % Record response
        %-----------------
        noresp = 1;
        while noresp && GetSecs - onset < maxDur
            [keyIsDown,secs,keyCode] = KbCheck(inputDevice);
            keyPressed = find(keyCode);
            if keyIsDown & ismember(keyPressed,resp_set)
                Screen('DrawText',w,fixation,fixPosX,PosY);
                Screen('Flip', w);
                tmp = KbName(keyPressed);
                tmpSeeker(t,7) = secs - onset;
                tmpSeeker(t,8) = str2double(tmp(1));
                noresp = 0;
           end;
        end;
        % Present fixation cross during intertrial interval
        Screen('DrawText',w,fixation,fixPosX,PosY);
        Screen('Flip', w);
        if tmpSeeker(t,7)==0
            while GetSecs - onset < maxDur + .4
                [keyIsDown,secs,keyCode] = KbCheck(inputDevice);
                keyPressed = find(keyCode);
                if keyIsDown & ismember(keyPressed,resp_set)
                    tmp = KbName(keyPressed);
                    tmpSeeker(t,7) = secs - onset;
                    tmpSeeker(t,8) = str2double(tmp(1));
                end;
            end;
        end
        offset = GetSecs - anchor;
        tmpSeeker(t,9) = offset;

    end

    % store info from this block
    trialSeeker(trialSeeker(:,1)==b,:) = tmpSeeker;
            
    % print trials in block to logfile 
    for t = 1:size(tmpSeeker,1)
        fprintf(fid,[repmat('%d\t',1,size(tmpSeeker,2)) '\n'],tmpSeeker(t,:));
    end

end;    % end of block loop

WaitSecs('UntilTime', anchor + totalTime);

catch
    Screen('CloseAll');
    Priority(0);
    psychrethrow(psychlasterror);
end;

%---------------------------------------------------------------
%% SAVE DATA
%---------------------------------------------------------------
d=clock;
outfile=sprintf('loicalizer_%s_%s_%02.0f-%02.0f.mat',subjectID,date,d(4),d(5));

cd data
try
    save(outfile, 'trialSeeker', 'blockSeeker', 'subjectID'); 
catch
	fprintf('couldn''t save %s\n saving to cfsat_behav.mat\n',outfile);
	save loicalizer_behav;
end;
cd ..

if nargin==0
    %---------------------------------------------------------------
    %% CLOSE SCREENS
    %---------------------------------------------------------------
    Screen('CloseAll');
    Priority(0);
    ShowCursor;
end

%=========================================================================
% SUBFUNCTIONS
%=========================================================================


function chosen_device = hid_probe()
%% Written by DJK, 2/2007
%%
%% This function returns the desired input device for scanning.
%% The HID will need to see the buttonbox device for this to work,
%% which often means the cable should be plugged into the computer
%% before launching Matlab.

chosen_device = [];
numDevices=PsychHID('NumDevices');
devices=PsychHID('Devices');
candidate_devices = [];
top_candidate = [];

% probe_string='Searching for Devices ...';
% fprintf('%s\n',probe_string)

for n=1:numDevices,
	if (~(isempty(findstr(devices(n).transport,'USB'))) || ~isempty(findstr(devices(n).usageName,'Keyboard')))
		disp(sprintf('Device #%d is a potential input device [%s, %s]\n',n,devices(n).usageName,devices(n).product))
		candidate_devices = [candidate_devices n];
		if (devices(n).productID==16385 | devices(n).vendorID==6171 | devices(n).totalElements==274)
			top_candidate = n;
		end
	end
end

prompt_string = sprintf('Which device for responses (%s)? ', num2str(candidate_devices));

if ~isempty(top_candidate)
	prompt_string = sprintf('%s [Enter for %d]', prompt_string, top_candidate);
end

while isempty(chosen_device)
	chosen_device = input(prompt_string);
	if isempty(chosen_device) & ~isempty(top_candidate)
		chosen_device = top_candidate;
	elseif isempty(find(candidate_devices == chosen_device))
		fprintf('Invalid Response!\n')
		chosen_device = [];
	end
end