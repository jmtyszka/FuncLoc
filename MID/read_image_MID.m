image_dir2 = ['C:\Script\Balance\fMRI1\image\Inst'];

cue0_file =imread([image_dir2 filesep 'cue0.jpg'],'JPG');
cue0 = Screen('MakeTexture', w.window, cue0_file); 

cue1_file =imread([image_dir2 filesep 'cue1.jpg'],'JPG');
cue1 = Screen('MakeTexture', w.window, cue1_file); 

cue2_file =imread([image_dir2 filesep 'cue2.jpg'],'JPG');
cue2 = Screen('MakeTexture', w.window, cue2_file); 

target_file =imread([image_dir2 filesep 'target.jpg'],'JPG');    
target = Screen('MakeTexture', w.window, target_file); 

fix_file =imread([image_dir2 filesep 'fix.jpg'],'JPG');    
fix = Screen('MakeTexture', w.window, fix_file); 