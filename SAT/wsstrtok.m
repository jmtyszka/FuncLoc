function [token remainder] = wsstrtok(str)
%This function behaves much like the builtin function strtok except that it preserves leading and trailing whitespace
%e.g. strtok( 'this is a test' ) returns ['this' 'is a test] while
%wsstrtok('this is a test') returns ['this ' 'is a test'].
%Thus for wsstrtok, strcmp(strcat(token,remainder),str) = true

if isempty(str) 
	return
end;

token = '';

%Read beginning whitespace characters
while ~isempty(str) && (strncmp(str,' ',1) || strncmp(str,'\t',1) || strncmp(str,'\n',1) || strncmp(str,char(10),1) || strncmp( str, '\r', 1) || strncmp(str,'\l',1 ))
	token = [token str(1)]; %Note you cannot replace this with strcat as strcat removes trailing whitespace
	str = str(2:length(str));
end

%Read non-whitespace characters off the front
while ~isempty(str) && ~(strncmp(str,' ',1) || strncmp(str,'\t',1) || strncmp(str,'\n',1) || strncmp(str,char(10),1) || strncmp( str, '\r', 1) || strncmp(str,'\l',1 ))
	token = [token str(1)]; %Note you cannot replace this with strcat as strcat removes trailing whitespace
	str = str(2:length(str));
end

%Read additional whitespace characters
while ~isempty(str) && (strncmp(str,' ',1) || strncmp(str,'\t',1) || strncmp(str,'\n',1) || strncmp(str,char(10),1) || strncmp( str, '\r', 1) || strncmp(str,'\l',1 ))
	token = [token str(1)]; %Note you cannot replace this with strcat as strcat removes trailing whitespace
	str = str(2:length(str));
end

remainder = str;

return
