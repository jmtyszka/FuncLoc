function Paced_Fingers(debug)
% Unimanual and bimanual, cued, paced finger tapping task.
%
% SYNTAX: condmat = Paced_Fingers(debug)
%
% Conditions:
% Left: Index-middle finger alternating tapping on left hand
% Right: Index-middle finger alternating tapping on right hand
% Both: Synchronized, mirrored index-middle finger alternating tapping on
% both hands.
% Total of 5 trials for each condition with SOA.
% Total time ~6 minutes.
%
% ARGS:
% debug = debug level:
%   0 = expt in magnet (6 reps, 3 conds) approx 6 mins
%   1 = debug
%   2 = expt timings - estimate expt timing and volumes
%   3 = training outside magnet (3 reps, 2 conds) approx 4 mins
%   4 = training timings - estimate training timing and volumes
%
% AUTHOR : Mike Tyszka, Ph.D.
% CONSULTANTS : Lynn Paul, Warren Brown
% PLACE  : Caltech Brain Imaging Center
% DATES  : 01/12/2007 JMT Adapt AgCC_Matching.m (JMT)
%          11/30/2007 JMT Update comments
%          05/28/2008 JMT Add training timing and bug fix for PT 3x
%          08/25/2008 JMT Adapt for uni- and bimanual paced tapping
%
% Copyright 2007-2008 California Institute of Technology.
% All rights reserved.

% Default args
if nargin < 1; debug = 0; end

%% Parameters

% Tapping cue presentation duration in seconds
pres_time = 0.25;

% Paced cue rate in Hz
pres_rate = 3.0;

% Check blanking time against maximum possible tapping rate
blank_time = 1/pres_rate - pres_time;
if blank_time <= 0
  fprintf('Tapping rate (%0.3fHz) is too fast\n', pres_rate);
  return
end

% Trial parameters for experimental and debugging modes
switch debug
  case 1
    t_iti   = [1 1]; % 1.0s ITI
    t_cue   = [1.5 1.5];
    t_soa   = [1 1];
    t_trial = [5 5]; % 1.0s trial duration
  otherwise
    t_iti   = [18 18]; % Full ITI
    t_cue   = [1.5 1.5];
    t_soa   = [1 4];
    t_trial = [16 16]; % Full trial duration
end

cond_name = {'Left','Right','Both'};
n_conds = length(cond_name);
switch debug
  case 1
    n_reps = 3; % Debugging
  case 3
    n_reps = 3; % Training
  otherwise
    n_reps = 6; % Experiment or timing estimate
end

%% Setup conditions

% Three conditions:
% 1. Left hand two-finger tapping
% 2. Right hand two-finger tapping
% 3. Both hands two-finger tapping (mirrored, synchronized)

% Seed pseudorandom number generator
% Matt Leonard chose this seed :)
rand('state',77);

% Setup random permutation of tasks
% Randomly permute each repetition of all conditions
cond_id = zeros(n_conds,n_reps);
for rc = 1:n_reps
  cond_id(:,rc) = randperm(n_conds)';
end

% Save matrix form of condition list
condmat = cond_id;

% Flatten condition matrix
cond_id = cond_id(:);

%% Prepare trial order and timings

% Prepare trial order and delay timings in advance
% Trial order is a random permutation of the conditions
% Prepare duration and ITI are uniform randomly distributed.

fprintf('Preparing trial order and timings\n');

% Total number of trials
n_trials = n_conds * n_reps;

% Seed pseudorandom number generator
% Matt Leonard chose this seed :)
rand('state',77);

% Setup random durations for all trial sections
iti_dur   = rand(1,n_trials) * (max(t_iti) - min(t_iti)) + min(t_iti);
cue_dur   = rand(1,n_trials) * (max(t_cue) - min(t_cue)) + min(t_cue);
soa_dur   = rand(1,n_trials) * (max(t_soa) - min(t_soa)) + min(t_soa);
trial_dur = rand(1,n_trials) * (max(t_trial) - min(t_trial)) + min(t_trial);

% Optional timing report for expt or training modes
switch debug

  case {2,4}

    total_secs = sum([iti_dur cue_dur soa_dur trial_dur]);
    scan_mins = fix(total_secs / 60);
    scan_secs = fix(total_secs - scan_mins * 60);

    % Report timings and return
    fprintf('\n');
    fprintf('Bimanual Timings\n');
    fprintf('---------------------\n');
    fprintf('ITI           : %0.1fs (%0.1fs)\n',mean(iti_dur),std(iti_dur));
    fprintf('Cue           : %0.1fs (%0.1fs)\n',mean(cue_dur),std(cue_dur));
    fprintf('SOA           : %0.1fs (%0.1fs)\n',mean(soa_dur),std(soa_dur));
    fprintf('Trial         : %0.1fs (%0.1fs)\n',mean(trial_dur),std(trial_dur));
    fprintf('Total time    : %dm%ds\n',scan_mins,scan_secs);
    fprintf('Total volumes : %d (TR = 2s)\n',ceil(total_secs/2));

    fprintf('\n');
    fprintf('Condition Summary\n');
    fprintf('-----------------\n');
    fprintf('Number of conditions : %d\n', n_conds);
    fprintf('Total of each condition : ');
    for cc = 1:n_conds
      fprintf('%d ',sum(cond_id == cc));
    end
    fprintf('\n');
    fprintf('Condition ids:\n');
    disp(condmat);

    return

  otherwise

    % Do nothing

end

%% Subject ID input

sid = input('Subject ID: ','s');
if isempty(sid); return; end

%% Setup display screens
fprintf('Initializing screens\n');

try

  % This script calls Psychtoolbox commands available only in OpenGL-based
  % versions of the Psychtoolbox. (So far, the OS X Psychtoolbox is the
  % only OpenGL-base Psychtoolbox.)  The Psychtoolbox command AssertPsychOpenGL will issue
  % an error message if someone tries to execute this script on a computer without
  % an OpenGL Psychtoolbox
  AssertOpenGL;

  % Get the list of screens and choose the one with the highest screen number.
  % Screen 0 is, by definition, the display with the menu bar. Often when
  % two monitors are connected the one without the menu bar is used as
  % the stimulus display.  Chosing the display with the highest dislay number is
  % a best guess about where you want the stimulus displayed.
  screens = Screen('Screens');
  screenNumber = max(screens);

  % Black -> background, White -> foreground colors
  black = BlackIndex(screenNumber);
  white = WhiteIndex(screenNumber);
  
  % Standard RGB color vectors
  black_rgb = [  0   0   0];
  white_rgb = [255 255 255];
  red_rgb   = [255   0   0];
  dark_rgb  = [ 32  32  32];

  % Create a double-buffered screen
  [w,rect] = Screen('OpenWindow',screenNumber,black,[],[],2);
  Screen('FillRect',w,black);
  Screen('Flip',w);
  Screen('FillRect',w,black);

  % Get screen dimensions
  fprintf('Determining screen size: ');
  sx = rect(3); sy = rect(4);
  fprintf('%d x %d\n',sx,sy);

  % Initialize font
  fontsize = 64;
  fontname = 'Arial';
  fontcolor = white;
  Screen('TextFont', w, fontname);
  Screen('TextSize', w, fontsize);
  Screen('TextColor', w, fontcolor);

  % Construct screen info structure
  screen_info.window = w;
  screen_info.sx = sx;
  screen_info.sy = sy;
  screen_info.sx0 = round(sx/2);
  screen_info.sy0 = round(sy/2);
  screen_info.fontsize = fontsize;
  screen_info.fontname = fontname;
  screen_info.black = black;
  screen_info.white = white;

  % Red fixation cross setup
  fix_col = red_rgb;
  fix_size = round(sx/32);
  
  %% Setup cue boxes for each condition
  box_size = round(sx/16);
  box_color_L1 = [dark_rgb;  white_rgb; dark_rgb;  dark_rgb];
  box_color_L2 = [white_rgb; dark_rgb;  dark_rgb;  dark_rgb];
  box_color_R1 = [dark_rgb;  dark_rgb;  white_rgb; dark_rgb];
  box_color_R2 = [dark_rgb;  dark_rgb;  dark_rgb;  white_rgb];
  box_color_B1 = [dark_rgb;  white_rgb; white_rgb; dark_rgb];
  box_color_B2 = [white_rgb; dark_rgb;  dark_rgb;  white_rgb];

  %% Setup hardware
  % Slice triggers, biopac, etc

  fprintf('Initializing hardware\n');

  % TR trigger character for silver box USB output
  triggerKey = KbName('5%');
  escapeKey = KbName('q');

  %% Stimulation Main Code

  fprintf('Starting Stimulation\n');

  % Hide cursor
  HideCursor;

  % Wait until all keys are released.
  while KbCheck; end;

  % Wait for TR trigger character or quit only in mode 0 (no debug)
  if debug < 1

    keep_going = 1;

    while keep_going

      % Check keyboard
      % Note that keyCode is a 256 element logical vector
      [keyIsDown,timeSecs,keyCode] = KbCheck;

      if keyIsDown

        % Flush the event buffer
        FlushEvents('keyDown');

        % Handle 'q' key press
        if keyCode(escapeKey)
          return
        end

        % Handle trigger character arriving
        if keyCode(triggerKey)
          keep_going = 0;
          trigger_tstamp = timeSecs;
        end

      end

    end

  else

    % Just record the current time
    trigger_tstamp = GetSecs;

  end

  % Start seconds timer
  tic;

  %----------------------------------------------------
  % Trial loop
  %
  % for gc = 1:n_sessions
  %   for tc = 1:n_trials
  %     Cue
  %     SOA gap
  %     Trial
  %     ITI
  %   end
  % end
  %
  % Preparation and ITI times are randomly jittered. Durations are
  % pseudorandom and can be regenerated from a constant seed.
  % Actual durations are recorded and saved to a plain text file.
  %----------------------------------------------------

  fprintf('Starting trial loop\n');

  % Initialize onset vectors
  cue_onset   = zeros(1,n_trials);
  soa_onset   = zeros(1,n_trials);
  trial_onset = zeros(1,n_trials);
  iti_onset   = zeros(1,n_trials);

  for tc = 1:n_trials

    fprintf('Trial %d\n',tc);
    
    cond_str = cond_name{cond_id(tc)};
    
    % Set flashing box colors
    switch lower(cond_str)
      case 'left'
        box_color1 = box_color_L1;
        box_color2 = box_color_L2;
      case 'right'
        box_color1 = box_color_R1;
        box_color2 = box_color_R2;
      case 'both'
        box_color1 = box_color_B1;
        box_color2 = box_color_B2;
    end

    %-------------------------------------------
    % Inter-trial Interval (ITI)
    % Fixation
    %-------------------------------------------

    [t0,t1,ch] = Fixation(fix_size,fix_col,iti_dur(tc),screen_info);
    if ch == escapeKey
      sca; % Close all screens
      fprintf('User aborted\n');
      return
    end

    iti_onset(tc) = t0 - trigger_tstamp;

    %---------------------------------------
    % Cue condition type
    %---------------------------------------

    [t0,t1,ch] = PrepareCue(cond_str, white, cue_dur(tc), screen_info);
    if ch == 'q'
      Screen closeall
      fprintf('User aborted\n');
      return
    end

    cue_onset(tc) = t0 - trigger_tstamp;

    %-----------------------------------------------------
    % SOA
    %-----------------------------------------------------

    [t0,t1,ch] = Fixation(fix_size,fix_col,soa_dur(tc),screen_info);
    if ch == 'q'
      Screen closeall
      fprintf('User aborted\n');
      return
    end

    soa_onset(tc) = t0 - trigger_tstamp;

    %-----------------------------------------------------
    % Present flashing cue boxes to pace tapping
    %-----------------------------------------------------

    t0 = GetSecs;
    t1 = t0 + trial_dur(tc);

    % Flashing box loop until t1
    while GetSecs < t1
      TappingCue(box_color1,box_size,pres_time,screen_info);
      TappingCue(box_color2,box_size,pres_time,screen_info);
    end

    trial_onset(tc) = t0 - trigger_tstamp;

    % Check for quit button

  end % Trial loop

  % Display actual total time of session
  toc;

  % Blank screen for 10 seconds
  BlankScreen(10,screen_info);

  % Clean up
  sca;

  %% Save conditions and timings
  fname = sprintf('%s_%s',sid,datestr(now,30));
  save(fname,...
    'trigger_tstamp',...
    'cond_name','cond_id',...
    'n_conds','n_reps','n_trials',...
    'iti_onset','iti_dur',...
    'cue_onset','cue_dur',...
    'soa_onset','soa_dur',...
    'trial_onset','trial_dur');
  
catch

  % This "catch" section executes in case of an error in the "try" section
  % above.  Importantly, it closes the onscreen window if its open.
  sca;
  ShowCursor;
  Priority(0);
  psychrethrow(psychlasterror);

end