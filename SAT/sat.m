%=========================================================================
% Social Attribution Task - Experimental task for fMRI
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
script_name='- Animated Shapes Task -'; boxTop(1:length(script_name))='=';
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
logfile=sprintf('sub%s_sat.log',subjectID);
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
theFontSize=40;
Screen('TextSize',w,40);
theight = Screen('TextSize', w);
Screen('TextFont',w,theFont);
Screen('TextColor',w,white);

% movie defaults
rate=1;     % playback rate
movieSize=.75;     % 1 is fullscreen
dstRect = CenterRect(ScaleRect(Screen('Rect', w),movieSize,movieSize),Screen('Rect', w)); 

% cues
socialCue='People: All Friends?';
socialProbe='All Friends?\n\n1=Yes     2=No';
bumperCue='Bumper Cars: All Same Weight?';
bumperProbe='All Same Weight?\n\n1=Yes     2=No';
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
movieDur = 15;
maxTime = movieDur;
cueDur = 2.75;
probeDur = 3;

% get design
cd design
Seeker = load('design1.txt');
Seeker(:,4:5) = [];
Seeker(:,4) = Seeker(:,3); 
Seeker(:,3) = Seeker(:,4)-3;
Seeker(:,5) = Seeker(:,4)+movieDur;
Seeker(:,6:9) = 0;
cd ..

% SEEKER COLUMN KEY
% 1 - trial #
% 2 - condition (1=Bumper, 2=Social)
% 3 - intended cue onset
% 4 - intended movie onset
% 5 - intended probe onset
% 6 - movie #
% 7 - correct response (1=Yes, 2=No)
% 8 - actual movie onset
% 9 - actual response (1=Yes, 2=No)
% 10 - RT to probe onset

% total time (s)
totalTime = ceil(Seeker(end,5)+3+12);

% display GET READY screen
Screen('FillRect', w, grayLevel);
Screen('Flip', w);
WaitSecs(0.25);
DrawFormattedText_new(w, 'Get ready! Please remember to keep your head still.', 'center','center',white, 600, 0, 0);
Screen('Flip',w);

%---------------------------------------------------------------
%% GET AND LOAD STIMULI
%---------------------------------------------------------------

fmt='mov';
cd stimuli
d=dir(['b*.' fmt]);
cpath = pwd;
idx = randperm(10);
for i=1:length(d)
    bName{i} = d(idx(i)).name;
    [movie movieduration fps imgw imgh] = Screen('OpenMovie', w, [cpath filesep d(idx(i)).name]);
    bStim(i) = movie;
    bSeek(i,1) = str2num(bName{i}(2:3));
    bSeek(i,2) = str2num(bName{i}(end-4));
end;
Seeker(Seeker(:,2)==1,6:7) = bSeek;
d=dir(['s*.' fmt]);
idx = randperm(10);
for i=1:length(d)
    sName{i} = d(idx(i)).name;
    [movie movieduration fps imgw imgh] = Screen('OpenMovie', w, [cpath filesep d(idx(i)).name]);
    sStim(i) = movie;
    sSeek(i,1) = str2num(sName{i}(2:3));
    sSeek(i,2) = str2num(sName{i}(end-4));
end;
Seeker(Seeker(:,2)==2,6:7) = sSeek;
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
bCount = 0;
sCount = 0;

for t=1:nTrials
    
    % Present trial cue (in condition and target gender contingent way)
    if Seeker(t,2)==1
        Screen('DrawText',w,bumperCue,bumperCuePosX,PosY);
        probe = bumperProbe;
    else 
        Screen('DrawText',w,socialCue,socialCuePosX,PosY);
        probe = socialProbe;
    end;
    WaitSecs('UntilTime', anchor + Seeker(t,3)); 
    Screen('Flip', w);
    WaitSecs(2.75)
    Screen('FillRect', w, grayLevel);
    Screen('Flip', w);
    if Seeker(t,2)==1
        bCount=bCount+1;
        movieMov=bStim(bCount);
        Screen('SetMovieTimeIndex', movieMov, 0);
        Screen('PlayMovie', movieMov, rate, 0, 0);
    else
        sCount=sCount+1;
        movieMov=sStim(sCount);
        Screen('SetMovieTimeIndex', movieMov, 0);
        Screen('PlayMovie', movieMov, rate, 0, 0);    
    end 
    WaitSecs('UntilTime', anchor + Seeker(t,4));

    % Present Stimulus
    endMovie=0;
    stimStart=GetSecs;
    while (endMovie<2)
        while(1)
            if (abs(rate)>0)
                [tex] = Screen('GetMovieImage', w, movieMov, 1);
                if tex<=0 
                    Screen('SetMovieTimeIndex', movieMov, Screen('GetMovieTimeIndex', movieMov) - .01);
                    [tex] = Screen('GetMovieImage', w, movieMov, 1);
                elseif (maxTime > 0 && GetSecs - stimStart >= maxTime)
                    endMovie=2;
                    break;
                end;
                Screen('DrawTexture', w, tex,[],dstRect);
                Screen('DrawingFinished',w);
                Screen('Flip', w);
                Screen('Close', tex);
            end;
        end;
    end;
    Seeker(t,8)=stimStart-anchor;
    
    % Present Probe
    DrawFormattedText(w,probe,'center','center',white, 600, 0, 0);
    Screen('Flip',w);
    probeStart = GetSecs;
    % Record Response
    while GetSecs - probeStart < probeDur
        [keyIsDown,secs,keyCode] = KbCheck(inputDevice);
        if keyIsDown && (keyCode(b1a) || keyCode(b1b) || keyCode(b2a) || keyCode(b2b))
            Seeker(t,10)=secs-probeStart;
            Screen('DrawText',w,fixation,fixPosX,PosY);
            Screen('Flip', w);
            if keyCode(b1a) || keyCode(b1b)
                Seeker(t,9)=1;
            elseif keyCode(b2a) || keyCode(b2b)
                Seeker(t,9)=2;
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
outfile=sprintf('socatt_%s_%s_%02.0f-%02.0f.mat',subjectID,date,d(4),d(5));

cd data
try
    save(outfile, 'Seeker','subjectID'); % if give feedback, add:  'error', 'rt', 'count_rt',
catch
	fprintf('couldn''t save %s\n saving to sat_behav.mat\n',outfile);
	save sat_behav;
end;
cd ..

%---------------------------------------------------------------
%% CLOSE SCREENS
%---------------------------------------------------------------
Screen('CloseAll');
Priority(0);
ShowCursor;
