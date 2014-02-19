function verb_gen_1_11_debug(TESTING)
%function verb_generation
%by Nao Tsuchiya and Alexis Chidi based on saccade_loc_munoz 
%Modified by Remya Nair - 12/01/2007 - Converted code from PTB2 to PTB3
%Modified by Remya Nair - 05/22/2008 - Modified code for CVA technique

nargin = 0
dbstop if error

%open necessary directories
%basedir = 'c:\DocumentsandSettings\lkpaul\Desktop\verbgen';

%basedir = 'E:\lkpaul\Desktop\verbgen'

basedir = pwd
 
% basedir = 'C:\verbgen';
warning('off','MATLAB:dispatcher:InexactMatch')


%Experiment or practice?
if nargin < 1
  TESTING = 0; % 0 if experiment, 1 for testing/debugging
end

if TESTING
  subj = 'aa';
else
  %get subject info
  subj = input('Subject Initials: ','s');
end

% Blind flag
blind = 0;

%some initial set up
time = clock;
yr = num2str(time(1));

%suffix for logfile
suffix = ['_' yr(3:4) '_' num2str(time(2)) '_' num2str(time(3)) '_'  num2str(time(4)) '_' num2str(time(5))];



%open logfile
logdir = fullfile(basedir,'log');
logfile = sprintf(strcat(suffix,'_bg_',subj,'_log.m'));
clk = clock;
cd (logdir);
fid = fopen([logfile, '.txt'], 'wt');


%display info
if ~blind
  frameRate = Screen(0,'frameRate');
  
  %color settings
  
  bgColor = [0 0 0];
  fp_color  = [255 255 255];
  
  %screen settings
 
  rect = Screen(0, 'rect');
  scr_wth=rect(3);
  scr_hgt=rect(4);
  
end

%fixation cross creation
if ~blind
CrossWidth = 5;
rect1=[(rect(3)/2 - CrossWidth - CrossWidth / 2) (rect(4)/2 - CrossWidth / 2) (rect(3)/2 + CrossWidth + CrossWidth / 2) (rect(4)/2 + CrossWidth / 2)]
rect2=[(rect(3)/2 - CrossWidth / 2) (rect(4)/2 - CrossWidth - CrossWidth / 2) (rect(3)/2 + CrossWidth / 2) (rect(4)/2 + CrossWidth + CrossWidth / 2)]

w = Screen('OpenWindow', 0, bgColor); 

Screen('FillRect',w,fp_color,rect1);
Screen('FillRect',w,fp_color,rect2);
Screen('Flip',w);

centerX = rect(3)/2;
centerY = rect(4)/2;

end


%load word lists
%FEW
cd (basedir)
[col,few_stim] = textread('verbgen_few.txt','%s %s')
num_few = length(few_stim);
rand('state',cputime);
list_few = randperm(num_few);

for lc = 1:num_few;
  lc;
  list_few(lc);
  few_stim{list_few(lc)};
end

%MANY
[col,many_stim] = textread('verbgen_many.txt', '%s%s');
num_many = length(many_stim);
rand('state',cputime);
list_many = randperm(num_many);

for lc = 1:num_many;
  lc;
  list_many(lc);
  many_stim{list_many(lc)};
end

%READ
[col,read_stim] = textread('verbgen_read.txt', '%s%s');
num_read = length(read_stim);
rand('state',cputime);
list_read = randperm(num_read);

for lc = 1:num_read;
  lc;
  list_read(lc);
  read_stim{list_read(lc)};
end

cd ..

%fMRI timing stuff
%write into log file
if TESTING % THIS IS FOR DEBUGGING
  initial_wait_secs = 1 %how long should this be?
  repetition = 4; % # repetitions of each type of block
  %restDur = 6;
  instrDur = 1.0;
  cueDur = 1.0;
%   blankDur = 0.1;
  stimDur = 1.0;
  %restStim = 1.9;
  respDur = 2.0;
  nBlock  = 3;
  fixDur = 3.0
else % THIS IS FOR REAL EXPERIMENTS
  initial_wait_secs = 8 %how long should this be? this should last until scanner trigger arrives.
  repetition = 1%4;%1 % # repetitions of each type of block
  %restDur = 6;
  instrDur = 1.0;
  cueDur = instrDur;
  %blankDur = 0.1;% Not required
  stimDur = 1.0;
  %restStim = 19.9;% the Rest condition needs to be removed
  respDur = 2.0;
  nBlock  = 1%3; %# block types: few, many, read ('rest' condition has been eliminated)
  fixDur = 3.0
end

trialDur = cueDur + stimDur + respDur + fixDur; %length of trial (7s)
nTrialPerBlock =3%6; %# trials per block


%log timing info
fprintf(fid,'Initial Wait %d\n',initial_wait_secs);
fprintf(fid,'# Repetitions %d\n',repetition);
fprintf(fid,'Instruction Time:\t%f\n', instrDur);
fprintf(fid, 'Cue Duration %d\n',cueDur);
%fprintf(fid, 'Blank Duration %d\n',blankDur);
fprintf(fid, 'Stimulus Duration %d\n',stimDur);
%fprintf(fid, 'Rest Block Duration %d\n',restStim);
fprintf(fid, 'Response Time %d\n',respDur);
fprintf(fid, ' # of Blocks for each condition %d\n',nBlock);
fprintf(fid, 'Trial Duration %d\n',trialDur);
fprintf(fid, ' Trails per Block %d\n',nTrialPerBlock);
fprintf(fid, ' Fixation Duration %d\n',fixDur);
% % % fprintf(f, '%d','Block Type  ');
% % % fprintf(f, '%d\n',iBlockType);


%Block Duration
blockDur = trialDur * nTrialPerBlock; %block length: 42s
%restBlockDur = restStim + blankDur; %block length: 20s % No rest block

totalTime =  repetition*((nBlock)*blockDur) %total time for experiment (504s)

%INSERT RANDOMIZATION OF ORDER OF BLOCKS
%many = 1, few = 2, read = 3, rest = 4 % rest =4 has been eliminated

%
% Font size handling
%
fontsize = 70;
fontscale = 17.5 * fontsize / 60;

%Start Experiment

if ~blind
  
  %set up text for user interface
  Screen(w,'TextFont','Courier New');
  Screen(w,'TextSize',fontsize);
  Screen(w,'TextStyle',0);
end



%-----------------------------------------
% Setup Block Types
%-----------------------------------------
% block_type = zeros(repetition,4);
block_type = zeros(repetition,3);
for rc = 1:repetition
  block_type(rc,:) = randperm(3);
end
disp(block_type)

%randomize order of words
f=1; %initialize word counters
m=1;
r=1;

g = randperm(64);

% %centering info
% wordmany=g(m);
% stim = many_stim{list_many (wordmany)};
% stimsize = fontscale*length(stim);
% stim


% Screen and text parameters
%%%%sx = 1024;
sx=rect(3);
sy = rect(4);%768;
%%%sy=rect(4);
symid   = round(sy/2) - fontscale;


% count_fixend = 0;
% count_bs = 0;
 count_bt = 0;
% count_ts = 0;
% count_tt = 0;
% count_ce = 0;
% count_te = 0;
% count_re = 0;
% count_be = 0;


%wait for trigger
% TR trigger character
% Old silver box : ''''
% New black box : '5'
triggerKey = KbName('5%');%53
%triggerKey = KbName('5');%101

escapeKey = KbName('q');
flag_key=1;

if ~blind
  trigger = 0
  while ~trigger;
    [trigger,secs,keyCode] = KbCheck;
    if keyCode(triggerKey)
        flag_key = 0;
    end
  end;
end

if ~flag_key
  %Screen('copywindow',fixation,w,fp_r,fp_dst);
  hideCursor;
end
 
expStart = GetSecs

elapsed_time = 0;

% % % % % % % fid = fopen([logfile, '.txt'], 'a+t');
fprintf(fid,'Initial wait period %d\n',0);

% while getsecs < expStart + initial_wait_secs; end

% % % % % % fid = fopen([logfile, '.txt'], 'a+t');
fprintf(fid,'Entering repetition loop t = %f\n',getsecs-expStart);


% Zero the accumlated block time sum
accum_block_time = 0;
% accum_block_time = initial_wait_secs;

%start Loop
for iRepeat =1:repetition
    
  x = 1;
 
% % % % % % % fid = fopen([logfile, '.txt'], 'a+t');  
fprintf(fid, 'Entering block loop t = %f\n',getsecs-expStart);

  
  
  for iBlock = 1:3    % each block

      block_time = 0; % Ideal time sum for this block
    
      %randomize order of blocks
    iBlockType = block_type(iRepeat,iBlock);
             count_bt = count_bt + 1;
             which_blockType(iRepeat,iBlock) = iBlockType;
% % % % % % % % %              fid = fopen([logfile, '.txt'], 'a+t');
           fprintf(fid,'Block Type t%d\n',iBlockType); %log BlockType

           
           
     for iTrial = 1:nTrialPerBlock % start of trial

    % present instructions
       if ~flag_key
           switch iBlockType
                case {1,2}
          %stimsize = fontscale * length('Generate Verbs');
                 stimsize = fontscale * length('g');
                 sxmid   = round(sx/2) - stimsize;
                 Screen(w, 'DrawText','g', sxmid, symid, 255);
                 Screen('Flip',w)     
                case 3
         % stimsize = fontscale*length('Read only!');
                stimsize = fontscale*length('r');
                sxmid   = round(sx/2) - stimsize;        
                Screen(w, 'DrawText', 'r', sxmid, symid, 255)
                 Screen('Flip',w)
%         otherwise
%           stimsize = fontscale*length('Rest');
%           sxmid   = round(sx/2) - stimsize;
%           Screen(w, 'DrawText', 'Rest', sxmid, symid, 255)
%           Screen('Flip',w)
           end
      end
    
    
  
    
    % Wait for instruction to finish
    
  %  while  getsecs < expStart + initial_wait_secs + instrDur + accum_block_time; end

      while  getsecs <= expStart + instrDur + accum_block_time; end
    
    % Add instruction duration to current block time sum
    block_time = block_time + instrDur
      
      
    accum_block_time = accum_block_time + instrDur;


    if ismember (iBlockType, [1,2,3]) %word blocks
     
    

% % % % % % % fid = fopen([logfile, '.txt'], 'a+t');
fprintf(fid,'Entering Trial loop %f\n',getsecs-expStart);

      

        %                 count_ts = count_ts + 1;

        %                 tic
        if iBlockType == 1 % MANY
          wordmany = g(m);
          m = m+1;
          Many = many_stim{list_many (wordmany)};
          %iMany = iMany+1; % increases counter
          stim = Many; % specifies which word to present
% % % % % % %           fid = fopen([logfile, '.txt'], 'a+t');
          fprintf(fid, 'Word:\t%s\n',stim);
          

        elseif iBlockType == 2 % FEW
          %few_cond = few_cond +1;
          %Few = few_stim(few_cond);
          wordfew=g(f);
          f=f+1;
          Few = few_stim{list_few (wordfew)};
          %iFew = iFew+1; % increases counter
          stim = Few;
% % % % % % %           fid = fopen([logfile, '.txt'], 'a+t');
          fprintf(fid, 'Word:\t%s\n',stim);

        elseif iBlockType == 3 % READ
          wordread=g(r);
          r=r+1; %increases counter
          Read = read_stim{list_read(wordread)};
          stim = Read;
% % % %           fid = fopen([logfile, '.txt'], 'a+t');
          fprintf(fid, 'Word:\t%s\n',stim)
        end

    end;  
     
          FlushEvents('keydown');
          
          % present stimuli
          stimsize = fontscale*length(stim);
          sxmid = round(sx/2) - stimsize;

          if ~flag_key
            Screen(w, 'DrawText', stim, sxmid, symid, 255)
             Screen('Flip',w)
          end

          % Wait for end of stimulus presentation
          %while getsecs <  expStart + instrDur + stimDur + accum_block_time; end
while getsecs < expStart + stimDur + accum_block_time; end
          % Add stim duration to block time sum
          
          block_time = block_time + stimDur
           
          accum_block_time=accum_block_time+stimDur;
          %highlight stimulus during response time
          if ~flag_key
            Screen(w, 'TextStyle', 4);
            Screen(w, 'DrawText', stim, sxmid, symid, 255);
             Screen('Flip',w)
          end

          
          % Wait for end of respDur
        %  while getsecs < expStart + instrDur + stimDur + respDur + accum_block_time; end
 while getsecs < expStart + respDur + accum_block_time; end
          % Add response duration to block time sum
          block_time = block_time + respDur
          accum_block_time=accum_block_time+respDur;
          
         % reset text style
          if ~flag_key
            Screen (w,'TextStyle',0);
          end

          
          if ~blind
             Screen('FillRect',w,fp_color,rect1);
             Screen('FillRect',w,fp_color,rect2);
             Screen('Flip',w);
          end;

         % while getsecs < expStart + instrDur + stimDur + respDur + fixDur + accum_block_time; end
     
           while getsecs < expStart + fixDur + accum_block_time; end
           
           block_time = block_time + fixDur
           accum_block_time = accum_block_time + fixDur;
       


      end % go to next trial
      
      block_time
      
     end; % go to next block
    
    
end % go to next repetition
 
timeElapsed = getsecs - expStart


if ~flag_key
  stimsize = fontscale*length('End of Session. Please wait.');
  sxmid   = round(sx/2) - stimsize;
  Screen(w, 'DrawText', 'End of Session!', sxmid, symid, 255)
  Screen('Flip',w);
end

% % % % % fid = fopen([logfile, '.txt'], 'a+t');
fprintf(fid,'Time Elapsed %f\n',timeElapsed);
fprintf(fid,' Block type %d\n',which_blockType);


fclose(fid);


if ~flag_key
  Screen('CloseAll');
  ShowCursor;
end



whichRun = 1; %change whichRun if use different parameters
%loggy = 'log';

cd(logdir)

save(logfile);

cd ..
ShowCursor;
