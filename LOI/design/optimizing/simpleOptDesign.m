%SIMPLEOPTDESIGN Optimize an event-related design
%
% This script will compute contrast efficiencies for a series of simulated
% event-related designs (with parameters specified in a separate function for
% design matrix creation). Following the simulation, a time stamped folder will be
% in the folder from which the script is run. In the folder, details
% regarding the most efficient designs will be saved. This includes a .mat
% file with all of the design information, as well as separate text files
% for the most efficient designs. The text files will have 5 columns:
%
%   column 1 -- trial #
%   column 2 -- condition
%   column 3 -- onsets (in secs)
%   column 4 -- trial duration (in secs)
%   column 5 -- jitter (post-trial); note that the final value corresponds
%   to the time after the last trial offset until the run is over
%   
%
% Russ Poldrack, 10/19/2004
% Adapted, Bob Spunt, 02/02/2011
% University of California, Los Angeles
%
% ---------------------------------UPDATES---------------------------------
%   original adaptation - 02/02/2011
%   updated with weighting/maxtime/text files - 02/19/2011
%   updated with ISI and trial length columns for text files - 07/29/2011
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%-----------------------------------------
% User should specify the following:
%-----------------------------------------
desmtx_func='create_desmtx';        % name of your function for creating the design matrix
% assuming the conditions are as follows: 
% Face_High Hand_High Face_Low Hand_Low
L=[1 0 -1 0; 0 1 0 -1; .5 -.5 .5 -.5]';   % contrasts of interest (each row = new contrast)
conWeights=[1 1 .5];               % how to weight each contrast in overall efficiency estimation? 
TR=2.5;                               % your TR length                   
hpf=128;                            % your high-pass filter (in secs)
nruns=1000000;                          % how many different random designs to test?
maxtime=60*1;                      % max time to run (in minutes)
nkeep=2;
%-----------------------------------------
% Run some checks to make things will run
%-----------------------------------------
% check to make sure SPM is in path
if ~exist('spm_hrf'),
  error('you must have SPM99/2/5/8 in your MATLAB path!');
end;

% check to make sure desmtx_func exists
if ~exist('desmtx_func'),
  error('desmtx_func must be specified!');
end;
fprintf('Checking %s.m... ',desmtx_func);
if ~exist(desmtx_func, 'file'),
  error(sprintf('%s.m does not exist!',desmtx_func));
end;

% test out the create_desmtx function
create_desmtx=str2func(desmtx_func);
% first see if it runs at all
try
  d=create_desmtx(TR,hpf);
catch
  [m,i]=lasterr;
  errmsg=sprintf('Problem executing %s:\n%s',desmtx_func,m);
  error(errmsg);
end;

% now check to make sure the outputs look right
if isfield(d,'desmtx') & isfield(d,'onsets'),
  desmtx=d.desmtx;
  onsets=d.onsets;
else
  error(['output from desmtx_func must contain desmtx and onsets members']);
end;

if size(desmtx,1)<size(desmtx,2),
  error('design matrix does not seem to have the proper dimensions');
end;

ncontrasts=size(L,2);               % just computes the number of contrasts
if (size(desmtx,1)<size(desmtx,2)),
  error('desmtx should have TRs in rows and conditions in columns!');
else
  nconds=size(desmtx,2);
  if nconds~=size(L,1),
    error('contrast vectors must be same width (Y dim) as design matrix!');
  else
     L(end+1,:)=0;
  end;
end;
fprintf('Looks OK\n');

%-----------------------------------------------------------------
% Now, loop through random designs and compute efficiency of each
%-----------------------------------------------------------------
tStart=tic; % start the timer
% initialize some storage variables
efficiency=zeros(ncontrasts+1,nruns);
keeper_id=zeros(1,nkeep);
keeper_eff=zeros(1,nkeep);
keeper_design=cell(1,nkeep);

% loop through random designs
for x=1:nruns,
    d=create_desmtx(TR,hpf);
    desmtx=d.desmtx;
    desmtx(:,end+1)=1;  % add intercept to desmtx
    for c=1:ncontrasts
       efficiency(c,x)=1/trace(L(:,c)'*pinv(desmtx'*desmtx)*L(:,c));
    end
    effTotal=sum(conWeights'.*efficiency(1:end-1,x));
    efficiency(end,x)=effTotal;
    if effTotal>min(keeper_eff)
        eff_zeros=find(keeper_eff==0);
        if eff_zeros
            new_entry=eff_zeros(1);
        else
            new_entry=find(keeper_eff==min(keeper_eff));
            if length(new_entry)>1
                new_entry=new_entry(1);
            end
            fprintf('Replacing slot %d: %0.5f with %0.5f (design %d of %d)\n',...
                new_entry,keeper_eff(new_entry),effTotal,x,nruns);
        end

        % save some vars
        keeper_id(new_entry)=x;
        keeper_eff(new_entry)=effTotal;
        keeper_design(new_entry)={d};

    end;
    if toc(tStart)>(maxtime*60)
        break
    end
end

% make a unique directory and save the best designs as txt files
thetime=fix(clock);
tmp=zeros(nkeep,2); tmp(:,1)=keeper_eff; tmp(:,2)=1:nkeep;
tmp=sortrows(tmp,-1);
dirNAME=sprintf('best_designs_%s_%d-%d-%d',date,thetime(4:6));
mkdir(dirNAME); cd(dirNAME)
for i=1:nkeep
    eval(sprintf('design%d=keeper_design{tmp(%d,2)}.combined;',i,i))
    fname=sprintf('design%d.txt',i);
    eval(sprintf('dlmwrite(fname,design%d,''delimiter'',''\\t'');',i));
end;
save optdesign.mat keeper_id keeper_eff keeper_design
fprintf('\nFinish time: %s %02d:%02d:%02d\n',date,thetime(4:6));


