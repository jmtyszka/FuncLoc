% MAKE SLIDES 
% Combine a photograph and a sentence on the same slide
% -----------------------------------------------------
clear all; close all hidden
basedir = pwd;
load all_question_data.mat
t = unique(qim(:,2));
% get photo filenames
photodir = '/Users/bobspunt/Desktop/photo';
cd('photos');

for p = 1:length(t)
    
    imaddborder([photodir filesep t{p}],4,'');
    
end










    