curDir = pwd;
clc
try 
	version = PsychtoolboxVersion;
	disp(sprintf('Psychtoolbox found. Version:\n----------------------------\n%s',version));
catch
	uiwait(warndlg('Psychtoolbox not detected on this machine. You must install psychtoolbox for tom_localizer to work correctly.','modal'));
	return
end
uiwait(msgbox('Select your main experimental directory. The directory tom_localizer will be made here.','modal'));
folder_name = uigetdir(pwd);
root_dir = fullfile(folder_name,'tom_localizer');
text_dir = fullfile(root_dir,'text_files');
beha_dir = fullfile(root_dir,'behavioural');
fprintf('\n');
disp(sprintf('Making directory %s',root_dir))
mkdir(root_dir);
fileList{1} = root_dir;
disp(sprintf('Making directory %s',text_dir))
mkdir(text_dir);
fileList{end+1} = text_dir;
disp(sprintf('Making directory %s',beha_dir))
mkdir(beha_dir);
disp(sprintf('\n----------------------------\n'));
fileList{end+1} = beha_dir;
textFT = dir('*question.txt');
textF  = {textFT.name};
for f=1:length(textF)
	disp(sprintf('Copying %s',textF{f}));
	copyfile(fullfile(pwd,textF{f}),fullfile(text_dir,textF{f}));
	fileList{end+1} = fullfile(text_dir,textF{f});
end
textFT = dir('*story.txt');
textF  = {textFT.name};
for f=1:length(textF)
	disp(sprintf('Copying %s',textF{f}));
	copyfile(fullfile(pwd,textF{f}),fullfile(text_dir,textF{f}));
	fileList{end+1} = fullfile(text_dir,textF{f});
end
disp(sprintf('\n----------------------------\n'));
disp(sprintf('Copying tom_localizer.m'));
copyfile(fullfile(pwd,'tom_localizer.m'),fullfile(root_dir,'tom_localizer.m'));
fileList{end+1} = fullfile(root_dir,'tom_localizer.m');
disp(sprintf('\n----------------------------\n'));
disp('...Validating...');
jlen = 0;
for i=1:length(fileList)
	if ~exist(fileList{i})
		fprintf('Could not find %s! Setup failed.',fileList{i})
		return
	end
	j = sprintf('%.1f',(i/length(fileList)*100));
	fprintf(repmat('\b',[1 jlen]));
	jlen = length(j);
	fprintf(j);
end
disp(sprintf('\n----------------------------\n'));
fprintf('Setup has completed successfully!\n');
