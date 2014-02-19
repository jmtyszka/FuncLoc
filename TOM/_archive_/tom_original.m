%=========================================================================
% Theory of Mind Localizer - Experimental task for fMRI
%=========================================================================
home; clear all

%---------------------------------------------------------------
%% ASSIGN RESPONSE KEYS
%---------------------------------------------------------------
trigger=KbName('5%');
b1a=KbName('1');
b1b=KbName('1!');
b2a=KbName('2');
b2b=KbName('2@');

%---------------------------------------------------------------
%% PRINT VERSION INFORMATION TO SCREEN
%---------------------------------------------------------------
script_name='- Story Task -'; boxTop(1:length(script_name))='=';
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
%% WRITE TRIAL-BY-TRIAL DATA TO LOGFILE
%---------------------------------------------------------------
d=clock;
logfile=sprintf('sub%s_tom.log',subjectID);
fprintf('\nA running log of this session will be saved to %s\n',logfile);
fid=fopen(logfile,'a');
if fid<1,
    error('could not open logfile!');
end;
fprintf(fid,'Started: %s %2.0f:%02.0f\n',date,d(4),d(5));
WaitSecs(.25);

%---------------------------------------------------------------
%% SET UP INPUT DEVICES
%---------------------------------------------------------------

subdevice_string='- Choose device for PARTICIPANT responses -'; boxTop(1:length(subdevice_string))='-';
fprintf('\n%s\n%s\n%s\n',boxTop,subdevice_string,boxTop)
inputDevice = hid_probe;

%---------------------------------------------------------------
%% INITIALIZE SCREENS
%---------------------------------------------------------------
% Screen('Preference', 'OverrideMultimediaEngine', 1);
screens=Screen('Screens');
screenNumber=max(screens);
w=Screen('OpenWindow', screenNumber,0,[],32,2);
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
theFont='Arial';
theFontSize=30;
Screen('TextSize',w,30);
theight = Screen('TextSize', w);
Screen('TextFont',w,theFont);
Screen('TextColor',w,white);


% cues
socialCue='People: All Friends?';
socialProbe='All Friends?\n\n1:Yes   2:No';
bumperCue='Bumper Cars: All Same Weight?';
bumperProbe='All Same Weight?\n\n1:Yes   2:No';
fixation='+';

% compute default Y position (vertically centered)
numlines = length(strfind(fixation, char(10))) + 1;
bbox = SetRect(0,0,1,numlines*theight);
[rect,dh,dv] = CenterRect(bbox, Screen('Rect', w));
PosY = dv;
% compute X position for cues
bbox=Screen('TextBounds', w, bumperCue);
[rect,dh,dv] = CenterRect(bbox, Screen('Rect', w));
bumperCuePosX = dh;
bbox=Screen('TextBounds', w, socialCue);
[rect,dh,dv] = CenterRect(bbox, Screen('Rect', w));
socialCuePosX = dh;
% compute X position for fixation
bbox=Screen('TextBounds', w, fixation);
[rect,dh,dv] = CenterRect(bbox, Screen('Rect', w));
fixPosX = dh;
HideCursor;

%---------------------------------------------------------------
%% iNITIALIZE SEEKER VARIABLE
%---------------------------------------------------------------

% constants
storyDur = 10;
questionDur = 4;

% get design
cd design
Seeker = load('design1.txt');
totalTime = ceil(sum(Seeker(end,3:5)));
Seeker(:,4:5) = [];
Seeker(:,4:9) = zeros(length(Seeker),6);
Seeker(:,4) = Seeker(:,3) + 10;
Seeker(Seeker(:,2)==1,5) = randperm(10);
Seeker(Seeker(:,2)==2,5) = randperm(10);
cd ..

% SEEKER COLUMN KEY
% 1 - trial #
% 2 - condition (1=Belief, 2=Photo)
% 3 - intended story onset
% 4 - intended question onset
% 5 - stimulus index
% 6 - actual story onset
% 7 - actual question onset
% 8 - actual response
% 9 - RT to question onset

% display GET READY screen
Screen('FillRect', w, grayLevel);
Screen('Flip', w);
WaitSecs(0.25);
DrawFormattedText_new(w, 'Use button 1 to answer TRUE and button 2 to answer FALSE.\n\nPlease remember to keep your head still.', 'center','center',white, 600, 0, 0);
Screen('Flip',w);

%---------------------------------------------------------------
%% GET AND LOAD STIMULI
%---------------------------------------------------------------

cd stimuli
stimpath = pwd;
% belief
d = dir('*b_question.txt');
bq = {d.name};
d = dir('*b_story.txt');
bs = {d.name};
% photo
d = dir('*p_question.txt');
pq = {d.name};
d = dir('*p_story.txt');
ps = {d.name};
cd ../

%---------------------------------------------------------------
%% WAIT FOR TRIGGER
%---------------------------------------------------------------
secs=KbTriggerWait(trigger,inputDevice);	% wait for trigger, return system time when detected
anchor=secs;		% anchor timing here (because volumes are discarded prior to trigger)
DisableKeysForKbCheck(trigger);     % So trigger is no longer detected
WaitSecs(0.001);

%---------------------------------------------------------------
%% TRIAL PRESENTATION
%---------------------------------------------------------------

% present fixation cross until first trial cue onset
Screen('DrawText',w,fixation,fixPosX,PosY);
Screen('Flip', w);

try

nTrials = length(Seeker);   

for t=1:nTrials
    
    % Prep and flip story
    idx = Seeker(t,5);
    if Seeker(t,2)==1
        story = [stimpath filesep bs{idx}];
        question = [stimpath filesep bq{idx}];
    else
        story = [stimpath filesep ps{idx}];
        question = [stimpath filesep pq{idx}];
    end
        
    textfid			= fopen(story);
    lCounter		= 1;										% line counter
    while 1
        tline		= fgetl(textfid);							% read line from text file.
        if ~ischar(tline), break, end
        Screen(w, 'DrawText',tline,x0-380,y0-160+lCounter*45,[255]);
        lCounter	= lCounter + 1;
    end
    fclose(textfid);
    WaitSecs('UntilTime', anchor + Seeker(t,3)); 
    Screen('Flip', w);
    Seeker(t,6) = GetSecs - anchor;
    
    
    % Prep and flip question
    textfid			= fopen(question);
    lCounter		= 1; 
    while 1
        tline		= fgetl(textfid);							% read line from text file.
        if ~ischar(tline), break, end
        Screen(w, 'DrawText',tline,x0-380,y0-160+lCounter*45,[255]);
        lCounter	= lCounter + 1;
    end
    WaitSecs('UntilTime', anchor + Seeker(t,4));
    Screen('Flip', w);
    stimStart = GetSecs;
    Seeker(t,7) = stimStart - anchor;
    % Record Response
    while GetSecs - stimStart < questionDur
        [keyIsDown,secs,keyCode] = KbCheck(inputDevice);
        if keyIsDown && (keyCode(b1a) || keyCode(b1b) || keyCode(b2a) || keyCode(b2b))
            Seeker(t,9)=secs-stimStart;
            Screen('DrawText',w,fixation,fixPosX,PosY);
            Screen('Flip', w);
            if keyCode(b1a) || keyCode(b1b)
                Seeker(t,8)=1;
            elseif keyCode(b2a) || keyCode(b2b)
                Seeker(t,8)=2;
            end
       end;
    end;  
   
    % Present fixation cross during intertrial interval
    Screen('DrawText',w,fixation,fixPosX,PosY);
    Screen('Flip', w);
   
    % PRINT TRIAL INFO TO LOG FILE
    try
        fprintf(fid,[repmat('%d\t',1,size(Seeker,2)) '\n'],Seeker(t,:));
    catch   % if sub responds weirdly, trying to print the resp crashes the log file...instead print "ERR"
        fprintf(fid,'ERROR SAVING THIS TRIAL\n');
    end;
end;    % end of trial loop

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
outfile=sprintf('tom_%s_%s_%02.0f-%02.0f.mat',subjectID,date,d(4),d(5));

cd data
try
    save(outfile, 'Seeker','subjectID'); % if give feedback, add:  'error', 'rt', 'count_rt',
catch
	fprintf('couldn''t save %s\n saving to tom_behav.mat\n',outfile);
	save tom_behav;
end;
cd ..

%---------------------------------------------------------------
%% CLOSE SCREENS
%---------------------------------------------------------------
Screen('CloseAll');
Priority(0);
ShowCursor;
