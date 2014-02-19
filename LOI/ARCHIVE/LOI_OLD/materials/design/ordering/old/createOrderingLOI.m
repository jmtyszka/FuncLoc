% ------------------------------------------------------------------------
% CLOSED-FORMAT LEVEL OF INFERENCE STUDY
% Script for Ordering Stimuli
% ------------------------------------------------------------------------

% read in data
cdir = pwd;
load run1.txt
load run2.txt
runboth = [run1; run2];
runboth(1:80,1) = 1;
runboth(81:160,1) = 2;
cd ../../../stimuli/loi
d = dir('1*.jpg');
for i = 1:length(d)
   tmp = d(i).name;
   stimmat(i,1) = str2num(tmp(1:end-4));
   stimmat(i,2) = str2num(tmp(4));
   stimmat(i,3) = str2num(tmp(5));
   stimmat(i,4) = str2num(tmp(6));
end;
cd(cdir)



% KEY for "run1" and "run2"
% 1 - trial #
% 2 - condition (1:4: emo; 5:8: act)
% 3 - scheduled trial onset
% 4 - max trial duration
% 5 - inter-trial interval

% KEY for stimulus name
% 1:3   - photo code
% 4     - behavior category (1=EMO, 2=ACT)
% 5     - a priori level of inference (1:4)
% 6     - correct response (0=NO, 1=YES)

% KEY for stimmat
% 1     - photo code
% 2     - behavior category (1=EMO, 2=ACT)
% 3     - a priori level of inference (1:4)
% 4     - correct response (0=NO, 1=YES)
% 5     - (ADDED) 1:8 condition to match run1/run2 vars
% 6     - (ADDED) stimulus #
% 7     - (ADDED) unique photo #

stimmat(:,5) = stimmat(:,3);
stimmat(stimmat(:,2)==2,5) = stimmat(stimmat(:,2)==2,5)+4;
stimmat(:,6) = 1:length(stimmat);
stimmat(:,7) = reshape(repmat(1:40,4,1),160,1);
emostim = stimmat(stimmat(:,2)==1,:);
actstim = stimmat(stimmat(:,2)==2,:);
for i = 1:8
    stims{i} = stimmat(stimmat(:,5)==i,:);
end

minphotodist = 10;
reps = 2;
correps = 8;
badrun=1;
while badrun
    badrun=0;
    tmp = runboth;
    tmp(:,6) = 0;
    tmp(:,7) = 0;
    tmp(:,8) = 0;
    tmp(:,9) = 0;
    % build a random array
    for i=1:8
        tmpstim = stims{i};
        randidx = randperm(20);
        tmp(tmp(:,2)==i,6:9) = tmpstim(randidx,[6 4 7 1]);
    end
    % compute indices
    for r=1:2
        crun = tmp(tmp(:,1)==r,:);
        for i=1:8
            cstim = crun(crun(:,2)==i,6);
            acc(r,i) = sum(stimmat(cstim,4));
        end
    end
    % check for bad number of acc trials
    runacc = sum(acc,2);
    if sum(sum(acc<7))>0 || runacc(1)~=60
        badrun=1;
    end
    if badrun==0
        % check for too many incorrect trials in a row
        for r = 1:2
            ctmp = tmp(tmp(:,1)==r,7);
            for i = 1+reps:length(ctmp)
                if ctmp(i)==0
                    last = ctmp(i-reps:i-1);
                    last = last==0;
                    if sum(last)==reps
                        badrun=1;
                    end
                end
            end
        end
        if badrun==0
            % check for too many correct trials in a row
            for r = 1:2
                ctmp = tmp(tmp(:,1)==r,7);
                for i = 1+correps:length(ctmp)
                    if ctmp(i)==1
                        last = ctmp(i-correps:i-1);
                        if sum(last)==correps
                            badrun=1;
                        end
                    end
                end
            end
            if badrun==0
                % check for same photo being too close together
                for r = 1:2
                    ctmp = tmp(tmp(:,1)==r,8);
                    for i = 1:length(ctmp)-minphotodist
                        cphoto = ctmp(i);
                        postcphoto = ctmp(i+1:minphotodist);
                        if sum(cphoto==postcphoto)
                            badrun=1;
                        end
                    end
                end
            end
        end
    end
end
    
% make seeker variable
Seeker = zeros(size(tmp));
Seeker(:,1) = tmp(:,1);     % run
Seeker(1:80,2) = 1:80;      % trial 
Seeker(81:160,2) = 1:80;    
Seeker(:,3) = tmp(:,2);     % condition
Seeker(:,4) = tmp(:,6);     % slide #
Seeker(:,5) = tmp(:,9);     % slide code
Seeker(:,6) = tmp(:,8);     % photo #
Seeker(:,7) = tmp(:,7);     % correct response
Seeker(Seeker(:,7)==0,7) = 2;
Seeker(:,8) = tmp(:,3);     % onset
Seeker(:,9) = tmp(:,5);     % iti

    
% KEY Seeker
% 1 - Run # (1 or 2)
% 2 - Trial # (1:80 per run)
% 3 - Condition # (EMO = 1:4, ACT = 5:8)
% 4 - Slide # (corresponds to order in stimulus folder)
% 5 - Slide Code (corresponds to slide filename)
% 6 - Photo # (Odd #s = EMO, Even #s = ACT)
% 7 - Correct Response (2 = NO, 1 = YES)
% 8 - Scheduled Onset (seconds)
% 9 - Scheduled ITI (seconds)
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    