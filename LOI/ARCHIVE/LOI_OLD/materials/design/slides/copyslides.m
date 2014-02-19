% MAKE SLIDES 
% Combine a photograph and a sentence on the same slide
% -----------------------------------------------------
clear all; close all hidden

basedir = pwd;

[n t raw] = xlsread('STIMDATA.xlsx');
% get photo filenames
photodir = '/Users/bobspunt/Desktop/Dropbox/Bob/Research/Caltech/whyhow/stimuli/loi/photos/all_900x1200';
d = t(:,1);
cd('photos');

for p = 1:length(d)
    
    imaddborder(d{p},4,'border_');
    
end

% % begin photo loop
% for p = 1:length(d)
%     
%     copyfile([photodir filesep '900x1200_' d{p}], ['photos' filesep d{p}]);
%         
% end










    