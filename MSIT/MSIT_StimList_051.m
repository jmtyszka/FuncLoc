easy_stim = {'100' '020' '003' '100' '020' '003'}; % 3 easy stimuli
hard_stim = {'112' '211' '131' '311' '221' '212' '232' '322' '331' '313' '332' '233'}; % 12 hard stimuli

% 24 trials per blocl
% 3 blocks each for each session

easy=[];
easy1=[];
for i = 1:16,
    easy1{i} = Shuffle(easy_stim);
    easy= [easy easy1{i}];
end

hard = [Shuffle([hard_stim, hard_stim]),Shuffle([hard_stim, hard_stim]),Shuffle([hard_stim, hard_stim]),Shuffle([hard_stim, hard_stim])];

easy_ans = zeros(1,96);
hard_ans = zeros(1,96);

for a = 1:length(easy)
    if strcmp(char(easy(a)), '100')==1
        easy_ans(a)=1;
    elseif strcmp(char(easy(a)), '020')==1
        easy_ans(a)=2;
    elseif strcmp(char(easy(a)), '003')==1
        easy_ans(a)=3;
    end
end

for b = 1:length(hard)
    if strcmp(char(hard(b)), '221')==1 || strcmp(char(hard(b)), '212')==1 || strcmp(char(hard(b)), '331')==1 || strcmp(char(hard(b)), '313')==1
        hard_ans(b)=1;
    elseif strcmp(char(hard(b)), '112')==1 || strcmp(char(hard(b)), '211')==1 || strcmp(char(hard(b)), '332')==1 || strcmp(char(hard(b)), '233')==1
        hard_ans(b)=2;
    elseif strcmp(char(hard(b)), '131')==1 || strcmp(char(hard(b)), '311')==1 || strcmp(char(hard(b)), '232')==1 || strcmp(char(hard(b)), '322')==1
        hard_ans(b)=3;
    end
end