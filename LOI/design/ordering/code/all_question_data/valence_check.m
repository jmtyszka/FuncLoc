clear all
basedir = pwd;
allfacedir = [basedir filesep 'FACE' filesep 'ALL'];
allhanddir = [basedir filesep 'HAND' filesep 'ALL'];
% ---------------------------------------
% read pleasantness data
% ---------------------------------------
[n t r] = xlsread('data_pleasantness.xlsx.');
t = t(1,:);
for i = 1:length(t)
    idx = strfind(t{i},'.jpg');
    allim{i} = t{i}(idx-5:idx+3);
    v = n(:,i);
    imemo(i) = nanmedian(v);
end
% ---------------------------------------
% get images
% ---------------------------------------
faceim = files([allfacedir filesep '*jpg']);
handim = files([allhanddir filesep '*jpg']);
% ---------------------------------------
% get unpleasantness data for images
% ---------------------------------------
for i = 1:length(faceim)
    
    tmp = imemo(strcmp(allim,faceim{i}));
    face_na(i) = tmp(1);
    tmp = imemo(strcmp(allim,handim{i}));
    hand_na(i) = tmp(1);
    
end
% ---------------------------------------
% test for differences
% ---------------------------------------  
[H,P,CI,STATS] = ttest2(face_na, hand_na, .05, 'both', 'unequal'); 


