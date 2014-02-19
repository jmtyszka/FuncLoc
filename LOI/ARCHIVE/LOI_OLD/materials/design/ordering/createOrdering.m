% SPECS
clear all
basedir = pwd;

% save? 
FLAG = 0;

% block level
nBlocks = 16;           % # blocks
nTrialsBlock = 7;       % # trials/block
foilDists = [3 3 3 3];  % distribution of # foils/block

% trial level
stimDur = 2.5;
ITI = .5;
nYes = 32;
nNo = 24;

% read in data
design = load('design2.txt');
[n t raw] = xlsread('STIMDATA.xlsx');

preblockcues = { ...
% hand high
'preblockcue_competitive.jpg'
'preblockcue_learning.jpg'
'preblockcue_helpful.jpg'
'preblockcue_fun.jpg'
% face high
'preblockcue_surprised.jpg'
'preblockcue_confident.jpg'
'preblockcue_proud.jpg'
'preblockcue_friendly.jpg'
% hand low
'preblockcue_both.jpg'
'preblockcue_lifting.jpg'
'preblockcue_pressing.jpg'
'preblockcue_reaching.jpg'
% face low
'preblockcue_smiling.jpg'
'preblockcue_gazing.jpg'
'preblockcue_mouth.jpg'
'preblockcue_camera.jpg'};

isicues = { ...
% hand high
'isicue_competitive.jpg'
'isicue_learning.jpg'
'isicue_helpful.jpg'
'isicue_fun.jpg'
% face high
'isicue_surprised.jpg'
'isicue_confident.jpg'
'isicue_proud.jpg'
'isicue_friendly.jpg'
% hand low
'isicue_both.jpg'
'isicue_lifting.jpg'
'isicue_pressing.jpg'
'isicue_reaching.jpg'
% face low
'isicue_smiling.jpg'
'isicue_gazing.jpg'
'isicue_mouth.jpg'
'isicue_camera.jpg'};

% totalTime
% -------------
totalTime = ceil(sum(design(end,3:5)));

% blockSeeker
% -------------
% 1 - block #
% 2 - condition (1=aH,2=eH,3=aL,4=eL)
% 3 - onset (s)
% 4 - cue idx 
blockSeeker = design(:,1:3);
cueidx = [1:4; 5:8; 9:12; 13:16];
for i = 1:4
    blockSeeker(blockSeeker(:,2)==i,4) = cueidx(i,:);
end

% trialSeeker
% -------------
% 1 - block #
% 2 - trial #
% 3 - condition (1=aH,2=eH,3=aL,4=eL)
% 4 - normative response (1=Yes, 2=No)
% 5 - stimulus # (corresponds to order in stimulus dir)
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

for i = 1:nBlocks
    
    ccue = preblockcues{blockSeeker(i,4)};
    name = ccue(strfind(ccue,'_')+1:strfind(ccue,'.')-1);
    if blockSeeker(i,2)<3
        idx = find(strcmp(t(:,4),name));
        norm = n(idx,4);
    else
        idx = find(strcmp(t(:,6),name));
    end;
    
    bad = 1;
    
    while bad
        
        bad = 0;
        idx = idx(randperm(length(idx)));
        norm = n(idx,6);
        if norm(1)==2
            bad = 1;
            continue
        end
        count = 0;
        for s = 2:5
            count = count + 1;
            test(count) = sum(norm(s:s+2));
        end
        if any(test==6)
            bad = 1;
        else
            bad = 0;
            trialSeeker(trialSeeker(:,1)==i,[4 5]) = [norm idx];
        end

    end

end

if FLAG
save design.mat totalTime blockSeeker trialSeeker preblockcues isicues
end



