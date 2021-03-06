%=========================================================================
% LOI - Localizer - for Tim 32 PC
% 
% CHANGE LOG
% 2012_11_12 - Current version added by Bob Spunt
%=========================================================================

%---------------------------------------------------------------
% DEFAULT VARIABLES
%---------------------------------------------------------------

% paths
basedir = pwd;
stimdir = [basedir filesep 'stimuli'];
datadir = [basedir filesep 'data'];
designdir = [basedir filesep 'design/ordering'];

% font options
theFont='Arial';
theFontSize=42;
theFontSize2=46;

% task defaults
cueDur = 2.5;
maxDur = 1.75;
ISI = .35;
nTrialsBlock = 7;

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
%% PRINT VERSION INFORMATION TO SCREEN
%---------------------------------------------------------------
script_name='- Photo Judgment Study -'; boxTop(1:length(script_name))='=';
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
switch upper(computer)
  case 'MACI64'
    subdevice_string='- Choose device for PARTICIPANT responses -'; boxTop(1:length(subdevice_string))='-';
    fprintf('\n%s\n%s\n%s\n',boxTop,subdevice_string,boxTop)
    inputDevice = hid_probe;
  case {'PCWIN','PCWIN64'}
    % JMT:
    % Do nothing for now - return empty chosen_device
    % Windows XP merges keyboard input and will process external keyboards
    % such as the Silver Box correctly
    inputDevice = [];
  otherwise
    % Do nothing - return empty chosen_device
    inputDevice = [];
end
%---------------------------------------------------------------
%% WRITE TRIAL-BY-TRIAL DATA TO LOGFILE
%---------------------------------------------------------------
d=clock;
logfile=sprintf('sub%s_loi.log',subjectID);
fprintf('\nA running log of this session will be saved to %s\n',logfile);
fid=fopen(logfile,'a');
if fid<1,
    error('could not open logfile!');
end;
fprintf(fid,'Started: %s %2.0f:%02.0f\n',date,d(4),d(5));
WaitSecs(.25);

%---------------------------------------------------------------
%% INITIALIZE SCREENS
%---------------------------------------------------------------
screens=Screen('Screens');
screenNumber=max(screens);
w=Screen('OpenWindow', screenNumber,0,[],32,2);
scrnRes     = Screen('Resolution',screenNumber);               % Get Screen resolution
[x0 y0]		= RectCenter([0 0 scrnRes.width scrnRes.height]);   % Screen center.
[wWidth, wHeight]=Screen('WindowSize', w);

% test resolution (stimPC should be at 1280 x 1024)
if ~isequal([wWidth wHeight],[1280 1024])
  fprintf('\n\n\n\nERROR: Set screen resolution to 1280 x 1024\n\n\n\n');
  clear screen
  return
end


% commented this out for PC which is at 1024 x 1280
% if ~debugging_mode,
%     if ~isequal([w1.ScreenWidth w1.ScreenHeight],[1600 1200])
%         disp('Screen resolution is not set to 1600 x 1200');
%         clear screen;
%         keyboard
%         return;
%     end
% end

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

% cues
fixation='+';
posadd = 50;

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
%% TEST THE BUTTON BOX
%---------------------------------------------------------------
bbtester(inputDevice, w)

%---------------------------------------------------------------
%% iNITIALIZE SEEKER VARIABLE
%---------------------------------------------------------------
DrawFormattedText(w,sprintf('LOADING\n\n0%% complete'),'center','center',white,42);
Screen('Flip',w);

% get design (contains timing information)
load([designdir filesep 'design.mat'])
load([designdir filesep 'all_question_data.mat'])
ordered_questions = preblockcues(blockSeeker(:,4));
pbc_brief = regexprep(preblockcues,'Is the person ','');

% KEY for "blockSeeker"
% 1 - block #
% 2 - condition (1=EH,2=AH,3=EL,4=AL)
% 3 - onset (s)
% 4 - cue # (corresponds to variables preblockcues & isicues, which are
% cell arrays containing the filenames for the cue screens contained in the
% folder "questions")

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
% photo slides
for i = 1:length(qim)
    
    slideName{i} = qim{i,2};
    tmp1 = imread([stimdir filesep slideName{i}]);
    tmp2 = tmp1;
    slideTex{i} = Screen('MakeTexture',w,tmp2);
    DrawFormattedText(w,sprintf('LOADING\n\n%d%% complete', ceil(100*i/length(qim))),'center','center',white,42);
    Screen('Flip',w);
    
end;
instructTex = Screen('MakeTexture', w, imread([basedir filesep 'instruction.jpg']));
fixTex = Screen('MakeTexture', w, imread([basedir filesep 'fixation.jpg']));

% Flip up instruction screen
Screen('FillRect', w, grayLevel);
Screen('Flip', w);
WaitSecs(0.1);
Screen('DrawTexture',w,instructTex);
Screen('Flip',w);

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

% present fixation cross until onset of first block
Screen('DrawTexture', w, fixTex);
Screen('Flip',w);

try

nBlocks = length(blockSeeker);


for b = 1:nBlocks
    
    % get relevant data for this block
    tmpSeeker = trialSeeker(trialSeeker(:,1)==b,:);
%     pbcue = preblockcues{blockSeeker(b,4)};
    pbcue = pbc_brief{blockSeeker(b,4)};
    isicue = isicues{blockSeeker(b,4)};
    
    % wait for block onset, then preblock cue
    Screen('TextSize',w,theFontSize);
    Screen('TextStyle',w,0);
    DrawFormattedText(w,'Is the person\n\n\n','center','center',white,46);
    Screen('TextStyle',w,1);
    Screen('TextSize',w,theFontSize2);
    DrawFormattedText(w,pbcue,'center','center',white,46);
 
    WaitSecs('UntilTime',anchor + blockSeeker(b,3));
    Screen('Flip', w);
    
    % flip a blank screen before onset
    Screen('FillRect', w, grayLevel);
    WaitSecs('UntilTime',anchor + blockSeeker(b,3) + cueDur);
    Screen('Flip', w);
    
    for t = 1:nTrialsBlock
        
        %-----------------
        % Present stimulus
        %----------------- 
        Screen('DrawTexture',w,slideTex{tmpSeeker(t,5)})
        if t==1
            WaitSecs('UntilTime',anchor + blockSeeker(b,3) + cueDur + ISI);
        else
            WaitSecs('UntilTime',anchor + offset + ISI);
        end
        Screen('Flip',w);
        onset = GetSecs;
        tmpSeeker(t,6) = onset - anchor;
        if t==nTrialsBlock
          Screen('DrawTexture', w, fixTex);
        else
          DrawFormattedText(w,isicue,'center','center',white,46);
        end
        WaitSecs(.20)
        %-----------------
        % Record response
        %-----------------
        noresp = 1;
        while noresp && GetSecs - onset < maxDur
            [keyIsDown,secs,keyCode] = KbCheck(inputDevice);
            keyPressed = find(keyCode);
            if keyIsDown & ismember(keyPressed,resp_set)
%                 Screen('FillRect', w, grayLevel);
%                 Screen('Flip', w);
                tmp = KbName(keyPressed);
                tmpSeeker(t,7) = secs - onset;
                tmpSeeker(t,8) = str2double(tmp(1));
                noresp = 0;
           end;
        end;
        %--------------------------------------------
        % Present ISI (or fixation, if last trial
        %--------------------------------------------
        Screen('Flip', w);
        offset = GetSecs - anchor;
        tmpSeeker(t,9) = offset;
        if tmpSeeker(t,7)==0
            while GetSecs - onset < maxDur + ISI - .1
                [keyIsDown,secs,keyCode] = KbCheck(inputDevice);
                keyPressed = find(keyCode);
                if keyIsDown & ismember(keyPressed,resp_set)
                    tmp = KbName(keyPressed);
                    tmpSeeker(t,7) = secs - onset;
                    tmpSeeker(t,8) = str2double(tmp(1));
                end;
            end;
        end
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
outfile=sprintf('loi_%s_%s_%02.0f-%02.0f.mat',subjectID,date,d(4),d(5));
cd(datadir)
try
    save(outfile, 'trialSeeker', 'blockSeeker', 'subjectID', 'ordered_questions', 'qvalence'); 
catch
	fprintf('couldn''t save %s\n saving to loi_behav.mat\n',outfile);
	save loi_behav;
end;
cd(basedir)
%---------------------------------------------------------------
%% CLOSE SCREENS
%---------------------------------------------------------------
Screen('CloseAll');
Priority(0);
ShowCursor;
disp('Backing up data... please wait.');
bob_sendemail({'bobspunt@gmail.com','conte3@caltech.edu'},'conte loi behavioral data','see attached', [datadir filesep outfile]);
disp('All done!');




