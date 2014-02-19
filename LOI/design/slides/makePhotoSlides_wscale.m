% MAKE SLIDES 
% Combine a photograph and a sentence on the same slide
% -----------------------------------------------------
clear all; close all hidden

basedir = pwd;
npixels = 2;

% get scale
sc = imread('scale.jpg');

% get photo filenames
photodir = [basedir filesep 'photos'];
outputdir = [basedir filesep 'slides'];
mkdir(outputdir);
d = files([photodir filesep '*.jpg']);

% begin photo loop
for p = 1:length(d)
    
    % read in photo
    op = imread([photodir filesep d{p}]);
    dims = size(op);
    op = imresize(op,[750 1000]);
    
%     % add border
%     op(:,1:npixels,:) = 250;
%     op(1:npixels,:,:) = 250;
%     op(:,end-(npixels-1):end,:) = 250;
%     op(end-(npixels-1):end,:,:) = 250;

    % create new image, add in resized photo
    sc(226:975,301:1300,:) = op;

    % resize image
    slide = imresize(sc,[900 1200]);

    % save the new image
    cd([basedir filesep 'slides'])
    imwrite(slide,[outputdir filesep d{p}],'jpg')
    cd(photodir)
        
end









    