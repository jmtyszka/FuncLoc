function verb_gen(TESTING)
%function verb_generation
%by Nao Tsuchiya and Alexis Chidi based on saccade_loc_munoz
%Modified by Remya Nair - 12/01/2007 - Converted code from PTB2 to PTB3
%Modified by Remya Nair - 05/22/2008 - Modified code for CVA technique

nargin = 0;
dbstop if error

basedir = pwd ;
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

% Open logfile
logdir = fullfile(basedir,'log');
if ~exist(logdir,'dir')
  mkdir(logdir);
end
logfile = fullfile(logdir,[subj suffix '_log.txt']);
fid = fopen(logfile, 'wt');

% Display info
if ~blind
  frameRate = Screen(0,'frameRate');
  
  % Color settings
  
  bgColor  = [0 0 0];
  fp_color = [255 255 255];
  
  % Screen settings
  rect = Screen(0, 'rect');
  sx = rect(3);
  sy = rect(4);
  
end

% Fixation cross creation
if ~blind
  
  CrossWidth = 5;
  rect1=[(sx/2 - CrossWidth - CrossWidth / 2) (sy/2 - CrossWidth / 2) (sx/2 + CrossWidth + CrossWidth / 2) (sy/2 + CrossWidth / 2)];
  rect2=[(sx/2 - CrossWidth / 2) (sy/2 - CrossWidth - CrossWidth / 2) (sx/2 + CrossWidth / 2) (sy/2 + CrossWidth + CrossWidth / 2)];
  
  w = Screen('OpenWindow', 0, bgColor);
  
  Screen('FillRect',w,fp_color,rect1);
  Screen('FillRect',w,fp_color,rect2);
  Screen('Flip',w);
  
end


% Load word lists
% FEW
cd (basedir)
[col,few_stim] = textread('verbgen_few.txt','%s %s');
num_few = length(few_stim);
rand('state',cputime);
list_few = randperm(num_few);

for lc = 1:num_few
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
  initial_wait_secs = 1; %how long should this be?
  repetition = 4; % # repetitions of each type of block
  instrDur = 1.0;
  cueDur = 1.0;
  stimDur = 1.0;
  respDur = 2.0;
  nBlock  = 3;
  fixDur = 3.0;
else % THIS IS FOR REAL EXPERIMENTS
  initial_wait_secs = 8; %how long should this be? this should last until scanner trigger arrives.
  repetition = 4;%1 % # repetitions of each type of block
  instrDur = 1.0;
  cueDur = instrDur;
  stimDur = 1.0;
  respDur = 2.0;
  nBlock  = 3;% 1; %# block types: few, many, read ('rest' condition has been eliminated)
  fixDur = 3.0;
end

trialDur = cueDur + stimDur + respDur + fixDur; %length of trial (7s)
nTrialPerBlock =6; %# trials per block

% Block Duration
blockDur  = trialDur * nTrialPerBlock; %block length: 42s
totalTime = repetition*((nBlock)*blockDur); %total time for experiment (504s)

% log timing info
fprintf(fid, 'Initial Wait %d\n',initial_wait_secs);
fprintf(fid, '# Repetitions %d\n',repetition);
fprintf(fid, 'Instruction Time:\t%f\n', instrDur);
fprintf(fid, 'Cue Duration %f\n',cueDur);
fprintf(fid, 'Stimulus Duration %f\n',stimDur);
fprintf(fid, 'Response Time %f\n',respDur);
fprintf(fid, '# of Blocks for each condition %d\n',nBlock);
fprintf(fid, 'Trial Duration %f\n',trialDur);
fprintf(fid, 'Trials per Block %d\n',nTrialPerBlock);
fprintf(fid, 'Fixation Duration %f\n',fixDur);
fprintf(fid, 'Block Duration %f\n',blockDur);
fprintf(fid, 'Total Time %f\n',totalTime);

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
disp(block_type);

% randomize order of words
f = 1; %initialize word counters
m = 1;
r = 1;

g = randperm(64);

% Text center with offset
symid = round(sy/2) - 2 * fontscale;

count_bt = 0;

% Wait for trigger
% TR trigger character
% Old silver box : ''''
% New black box : '5'
triggerKey = KbName('5%');%53
escapeKey = KbName('q');
flag_key=1;

if ~blind
  trigger = 0;
  while ~trigger;
    [trigger,secs,keyCode] = KbCheck;
    if keyCode(triggerKey)
      flag_key = 0;
    end
  end;
end

if ~flag_key
  hideCursor;
end

expStart = GetSecs;

elapsed_time = 0;

fprintf(fid,'Initial wait period %d\n',0);

fprintf(fid,'Entering repetition loop t = %f\n',getsecs-expStart);

% Zero the accumlated block time sum
accum_block_time = 0;

%start Loop
for iRepeat =1:repetition
  
  x = 1;
  
  fprintf(fid, 'Entering block loop t = %f\n',getsecs-expStart);
  
  for iBlock = 1:3    % each block
    
    block_time = 0; % Ideal time sum for this block
    
    %randomize order of blocks
    iBlockType = block_type(iRepeat,iBlock);
    count_bt = count_bt + 1;
    which_blockType(iRepeat,iBlock) = iBlockType;
    fprintf(fid,'Block Type %d\n',iBlockType); %log BlockType
    
    for iTrial = 1:nTrialPerBlock % start of trial
      
      % present instructions
      if ~flag_key
        switch iBlockType
          case {1,2}
            % 03/25/2013 JMT Replace g with D (Denken)
            stimsize = fontscale * length('D');
            sxmid   = round(sx/2) - stimsize;
            Screen(w, 'DrawText','D', sxmid, symid, 255);
            Screen('Flip',w)
          case 3
            % 03/25/2013 JMT Replace r with L (Lesen)
            stimsize = fontscale*length('L');
            sxmid   = round(sx/2) - stimsize;
            Screen(w, 'DrawText', 'L', sxmid, symid, 255)
            Screen('Flip',w)
        end
      end
      
      % Wait for instruction to finish
      while  getsecs <= expStart + instrDur + accum_block_time; end
      
      % Add instruction duration to current block time sum
      block_time = block_time + instrDur;
      
      accum_block_time = accum_block_time + instrDur;

      if ismember (iBlockType, [1,2,3]) %word blocks
      
        fprintf(fid,'Entering Trial loop %f\n',getsecs-expStart);
      
        if iBlockType == 1 % MANY
          wordmany = g(m);
          m = m+1;
          Many = many_stim{list_many (wordmany)};
          stim = Many; % specifies which word to present
          fprintf(fid, 'Word:\t%s\n',stim);
          
        elseif iBlockType == 2 % FEW
          wordfew=g(f);
          f=f+1;
          Few = few_stim{list_few (wordfew)};
          stim = Few;
          fprintf(fid, 'Word:\t%s\n',stim);
          
        elseif iBlockType == 3 % READ
          wordread=g(r);
          r=r+1; %increases counter
          Read = read_stim{list_read(wordread)};
          stim = Read;
          fprintf(fid, 'Word:\t%s\n',stim);
        end
        
      end
      
      FlushEvents('keydown');
      
      % present stimuli
      stimsize = fontscale*length(stim);
      sxmid = round(sx/2) - stimsize;
      
      if ~flag_key
        Screen(w, 'DrawText', stim, sxmid, symid, 255)
        Screen('Flip',w)
      end
      
      % Wait for end of stimulus presentation
      while getsecs < expStart + stimDur + accum_block_time; end

      % Add stim duration to block time sum
      block_time = block_time + stimDur;
      
      accum_block_time=accum_block_time+stimDur;
      % highlight stimulus during response time
      if ~flag_key
        Screen(w, 'TextStyle', 4);
        Screen(w, 'DrawText', stim, sxmid, symid, 255);
        Screen('Flip',w)
      end      
      
      % Wait for end of respDur
      while getsecs < expStart + respDur + accum_block_time; end

      % Add response duration to block time sum
      block_time = block_time + respDur;
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
      
      while getsecs < expStart + fixDur + accum_block_time; end
      
      block_time = block_time + fixDur;
      accum_block_time = accum_block_time + fixDur;
      
    end % go to next trial
    
  end % go to next block
  
end % go to next repetition

timeElapsed = getsecs - expStart;

if ~flag_key
  % 03/25/2013 JMT Translate to german
  stimsize = fontscale*length('Ende der Sitzen');
  sxmid   = round(sx/2) - stimsize;
  Screen(w, 'DrawText', 'Ende der Sitzen', sxmid, symid, 255)
  Screen('Flip',w);
end

fprintf(fid,'Time Elapsed %f\n',timeElapsed);
fprintf(fid,'Block type %d\n',which_blockType);

fclose(fid);

if ~flag_key
  Screen('CloseAll');
  ShowCursor;
end

ShowCursor;