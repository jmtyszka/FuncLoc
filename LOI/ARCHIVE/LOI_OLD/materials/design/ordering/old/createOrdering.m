% SPECS

% block level
nBlocks = 16;           % # blocks
nTrialsBlock = 6;       % # trials/block
foilDists = [1 1 2 2];  % distribution of # foils/block

% trial level
stimDur = 3;
ITI = .5;
nYes = 18;
nNo = 6;

% read in data
design = load('design1.txt');
cdir = pwd;
cd ../../task/stimuli
d = dir('1*.jpg');
for i = 1:length(d)
   tmp = d(i).name;
   stimmat(i,1) = i;
   stimmat(i,2) = str2num(tmp(1:end-4));
   stimmat(i,3) = str2num(tmp(4));
   stimmat(i,4) = str2num(tmp(5));
   stimmat(i,5) = str2num(tmp(6));
   stimid(i) = str2num(tmp(1:4));
end;
cd(cdir)

% total time
totalTime = ceil(sum(design(end,3:5)));

% KEY for "blockSeeker"
% 1 - block #
% 2 - condition (1=aH,2=eH,3=aL,4=eL)
% 3 - onset (s)
blockSeeker = design(:,1:3);

% KEY for stimulus name
% 1:3   - photo code
% 4     - behavior category (1=EMO, 2=ACT)
% 5     - a priori level of inference (1:4)
% 6     - correct response (0=NO, 1=YES)

% KEY for stimmat
% 1     - slide # 
% 2     - photo code (corresponds to filename)
% 3     - behavior category (1=EMO, 2=ACT)
% 4     - level of inference (1=LOW, 2=HIGH)
% 5     - correct response (1=YES, 2=NO)
% 6     - (ADDED) 1:4 condition to match blockSeeker
stimmat(stimmat(:,5)==0,5) = 2;
stimmat(:,6) = 0;
stimmat(stimmat(:,3)==1 & stimmat(:,4)==1,6) = 4;
stimmat(stimmat(:,3)==1 & stimmat(:,4)~=1,6) = 2;
stimmat(stimmat(:,3)==2 & stimmat(:,4)==1,6) = 3;
stimmat(stimmat(:,3)==2 & stimmat(:,4)~=1,6) = 1;
stimmat(:,7) = stimid;

% build trialSeeker variable
% 1 - block #
% 2 - trial #
% 3 - condition (1=aH,2=eH,3=aL,4=eL)
% 4 - normative response (1=Yes, 2=No)
% 5 - slide # (corresponds to order in stimulus dir)
trialSeeker = zeros(nBlocks*nTrialsBlock,5);
for i = 1:nBlocks
    start = 1+(i-1)*nTrialsBlock;
    finish = i*nTrialsBlock;
    trialSeeker(start:finish,1) = i;
end
for i = 1:nTrialsBlock
    trialSeeker(i:nTrialsBlock:end,2) = i;
end
trialSeeker(:,3) = reshape(repmat(design(:,2),1,nTrialsBlock)',nBlocks*nTrialsBlock,1);
trialSeeker(:,4) = 1;

maxreps = 2;
badorder = 1;
while badorder
    
    badorder = 0;
    tmpSeeker = trialSeeker;
    
    for c = 1:4     % loop through conditions
        
        allidx = find(tmpSeeker(:,3)==c);
        tmp = randperm(4);
        randFoilDists = foilDists(tmp);
        
        for f = 1:4     % loop through blocks
            
            cidx = allidx(1+(f-1)*nTrialsBlock:f*nTrialsBlock);
            nfoil = randFoilDists(f);
            tmp = 1+ randperm(nTrialsBlock-1);
            tmpSeeker(cidx(tmp(1:nfoil)),4) = 2;
            
        end;    % end block loop
        
    end;    % end condition loop
    
    % check to see if there are too many repeat "no" responses
    count = 0;
    norm = tmpSeeker(:,4);
    for i = 2:length(tmpSeeker)
        if norm(i)==2 && norm(i-1)==2
            count = count + 1;
        end
    end
    if count>maxreps
        badorder = 1;
    end
    
end
trialSeeker = tmpSeeker;


% check to see if two photos are distant enough
minphotodist = 10;
badorder = 1;
while badorder
    
    badorder = 0;
    % find appropriate slides to fill in blocks
    for c = 1:4
        yesidx = find(trialSeeker(:,3)==c & trialSeeker(:,4)==1);
        noidx = find(trialSeeker(:,3)==c & trialSeeker(:,4)==2);
        cstim = stimmat(stimmat(:,6)==c,:);
        yescstim = cstim(cstim(:,5)==1,1);
        nocstim = cstim(cstim(:,5)==2,1);
        trialSeeker(yesidx,5) = yescstim(randperm(nYes));
        trialSeeker(noidx,5) = nocstim(randperm(nNo));
    end

    % now check!
    norm = stimmat(trialSeeker(:,5),end);
    for i = 1:length(norm)-minphotodist
        cphoto = norm(i);
        postcphoto = norm(i+1:i+minphotodist);
        if sum(cphoto==postcphoto)
            badorder = 1;
            break
        end
    end
    
end



    




save design.mat totalTime blockSeeker trialSeeker stimmat




