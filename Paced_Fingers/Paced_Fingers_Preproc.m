function Bimanual_Preproc(dname)
% Bimanual_Preproc(dname)
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 05/12/2006 JMT From scratch

% Let user select output .mat file for AgCC Motor paradigm v4

if nargin < 1
  [fname,dname] = uigetfile('*.mat','Select record file');
  if isequal(fname,0) || isequal(dname,0)
    return
  end
end

% Load the record vectors from the file
load(fullfile(dname,fname));

if ~exist('cond_id','var')
  fprintf('MAT file does not contain bimanual task information\n');
  return
end

% Experimental parameter report
fprintf('Bimanual Coordination Task\n');
fprintf('--------------------------\n');
fprintf('Original conditions   : %d\n', n_conds);
fprintf('Number of repetitions : %d\n', n_reps);
fprintf('Number of trials      : %d\n', n_trials);

% Setup condition names
names = {'Together','Alternate','Cue'};
n_conds = length(names);

% Fill the cell arrays required by SPM5
onsets    = cell(1,n_conds);
durations = cell(1,n_conds);

fprintf('Fill condition onsets and durations\n');

% Together: either together or alternate
fprintf('Extracting onsets and durations for %s\n', names{1});
tog_trials = find(cond_id == 1);
onsets{1} = trial_onset(tog_trials);
durations{1} = trial_dur(tog_trials);

% Coordination : alternate only
fprintf('Extracting onsets and durations for %s\n', names{2});
alt_trials = find(cond_id == 2);
onsets{2} = trial_onset(alt_trials);
durations{2} = trial_dur(alt_trials);

% Cue event (1.5s, but model as event)
fprintf('Extracting onsets for %s event\n',names{3});
onsets{3} = cue_onset;
durations{3} = 0;

% Save conditions to mat file ready for SPM5
[pth,name] = fileparts(fullfile(dname,fname));
cond_name = [name '_conds.mat'];
fprintf('Creating %s\n',cond_name);
save(fullfile(pth,cond_name),'names','onsets','durations');