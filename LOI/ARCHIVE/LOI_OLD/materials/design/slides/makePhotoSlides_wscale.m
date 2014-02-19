% MAKE SLIDES 
% Combine a photograph and a sentence on the same slide
% -----------------------------------------------------
clear all; close all hidden

basedir = pwd;

% get scale
sc = imread('scale.jpg');

% get photo filenames
photodir = [basedir filesep 'photos'];
cd(photodir)
d = dir('*.jpg');

% begin photo loop
for p = 1:length(d)
    
    % read in photo
    op = imread(d(p).name);
    dims = size(op);
    op = imresize(op,[750 1000]);

    
    % create new image, add in resized photo
    sc(226:975,301:1300,:) = op;

    % resize image
    slide = imresize(sc,[1200 1600]);

    
    % save the new image
    cd([basedir filesep 'slides'])
    [path name ext] = fileparts(d(p).name);
    imwrite(slide,[name '.jpg'],'jpg')
    cd(photodir)
        
end
cd(basedir)









    