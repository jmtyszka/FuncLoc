function [design]=create_desmtx(TR,hpf)
%CREATE_DESMTX Create a design matrix for use by simpleOptDesign.m
%
% RETURNS...
%   design = structure with the following fields:
%       'desmtx' -- the filtered X matrix (excluding intercept)
%       'onsets' -- onsets (in secs) for each condition
%       'cond' -- vector indicating ordering of conditions
%       'combined' -- array with the following columns:
%               1: trial number
%               2: cond
%               3: onsets
%
% ARGUMENTS...
%   TR = repetition time in secs
%   hpf = high-pass filter (in secs) - for temporally filtering the design
%
%
% Customization options for the design are provided in the section titled
% "Specify some design matrix features". Currently, the code is setup to 
% automatically produce jitter values that have a pseudoexponential 
% Currently, it is setup to produce jitter values that have a
% pseudoexponential distribution with a specific min, mean, and max values.
% If you prefer a different distribution, modify the section titled 
% "Get a pseudoexponential distribution of ISIs". 
%
% Adapted by Bob Spunt from code from Russ Poldrack
% University of California, Los Angeles
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%-----------------------------------------------------------------
% Specify some design matrix features
%-----------------------------------------------------------------
nconds=4;                       % number of conditions
trials_per_cond=[4 4 4 4];     % number of trials in each condition (length must much nconds)
maxRep=1;                       % maximum number of repeat trials from same condition
trial_length=16;                 % trial length (in seconds)
ntrials=sum(trials_per_cond); % computes total number of trials
minISI=7;               % mininimum interstimulus interval (in seconds)
maxISI=13;               % maximum interstimulus interval (in seconds)
meanISI=9;              % desired mean interstimulus interval (in seconds)
restBegin=8;            % amount of rest to add in beginning of scan (in seconds)
restEnd=8;             % amount of rest to add at end of scan (in seconds)
scan_length=ceil((restBegin + restEnd + ntrials*(meanISI+trial_length))/TR);  % computes total scan length (in TRs)
TReff=TR/46;            % computes effective TR

%-----------------------------------------------------------------
% Get a pseudoexponential distribution of ISIs 
%-----------------------------------------------------------------
jitSample = [minISI:TReff:maxISI repmat(minISI:TReff:meanISI,1,8)];
goodJit=0;
while goodJit==0
    jitters=randsample(jitSample,ntrials-1,1);
    if mean(jitters) < meanISI+TReff && mean(jitters) > meanISI-TReff
       goodJit=1;
    end
end

%-----------------------------------------------------------------
% Determine stimulus onset times
%-----------------------------------------------------------------
onset=zeros(1,ntrials);
onset(1)=restBegin;
for t=2:ntrials,
  onset(t)=onset(t-1) + trial_length + jitters(t-1);
end;
jitters(end+1)=restEnd;

%-----------------------------------------------------------------
% Make some trial orders
%-----------------------------------------------------------------
move_on=0;
while move_on<(ntrials-maxRep)
    order=zeros(ntrials,1);
    orderIDX=randperm(ntrials);
    tmp=cumsum(trials_per_cond);
    for i=1:nconds
        order(orderIDX(1+(tmp(i)-trials_per_cond(i)):tmp(i)))=i;
    end;
    for i = 1:(ntrials-maxRep) 	
        checker=0;
        for r = 1:maxRep
            if order(r+i)~=order(i)
               checker=0; break;
            else
               checker=checker+1;
            end;
        end;
        if checker==maxRep,
           move_on=0;
           break;
        else
           move_on=move_on+1;
        end;
    end
end 
cond=order;

%------------------------------------------------------------------------
% Create the design matrix (oversample the HRF depending on effective TR)
%------------------------------------------------------------------------
oversamp_rate=TR/TReff;
dmlength=scan_length*oversamp_rate;
oversamp_onset=(onset/TR)*oversamp_rate;
hrf=spm_hrf(TReff);  
desmtx=zeros(dmlength,nconds);
for c=1:nconds
  r=zeros(1,dmlength);
  cond_trials= cond==c;
  cond_ons=fix(oversamp_onset(cond_trials))+1;
  r(cond_ons)=1;
  cr=conv(r,hrf);
  desmtx(:,c)=cr(1:dmlength)';
  onsets{c}=onset(cond==c);  % onsets in actual TR timescale
end;
% sample the design matrix back into TR timescale
desmtx=desmtx(1:oversamp_rate:dmlength,:);

%------------------------------------------------------------------------
% Filter the design matrix
%------------------------------------------------------------------------
K.RT = TR;
K.HParam = hpf;
K.row = 1:length(desmtx);
K = spm_filter(K);
for c=1:nconds
    desmtx(:,c)=spm_filter(K,desmtx(:,c));
end

%------------------------------------------------------------------------
% Save the design matrix
%------------------------------------------------------------------------
design.desmtx=desmtx;
design.onsets=onsets;
design.cond=cond;
design.combined=zeros(ntrials,5);
design.combined(:,1)=1:ntrials;
design.combined(:,2)=cond;
design.combined(:,3)=onset;
design.combined(:,4)=repmat(trial_length,ntrials,1);
design.combined(:,5)=jitters;
