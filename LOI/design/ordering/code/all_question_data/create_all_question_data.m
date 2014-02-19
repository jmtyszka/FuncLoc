count = 0;
im = {};
data = [];
basedir = pwd;
tmp = folders('0*');

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

for i = 1:length(tmp)
    
    cd([basedir filesep tmp{i}]);
    q = folders('Is*');

    for b = 1:length(q)
        
        fprintf('\n%s', q{b})
        
             
        cd([basedir filesep tmp{i} filesep q{b} filesep 'YES']);

        tt = files('*.jpg');
        if isempty(tt)
            fprintf('\n\n%\n\n', q{b});
        end
        for p = 1:length(tt)
            count = count + 1;
            data(count,1) = i;
            data(count,2) = 1;
            tmpemo = imemo(strcmp(allim,tt{p}));
            data(count,3) = tmpemo(1);
            tmpname = [regexprep(q{b},'_',' ') '?'];
            im(count,1) = cellstr(tmpname);
            im(count,2) = tt(p);
        end
        
        cd([basedir filesep tmp{i} filesep q{b} filesep 'NO']);

        tt = files('*.jpg');
                if isempty(tt)
            fprintf('\n\n%\n\n', q{b});
        end
        for p = 1:length(tt)
            count = count + 1;
            data(count,1) = i;
            data(count,2) = 2;
            tmpemo = imemo(strcmp(allim,tt{p}));
            data(count,3) = tmpemo(1);
            tmpname = [regexprep(q{b},'_',' ') '?'];
            im(count,1) = cellstr(tmpname);
            im(count,2) = tt(p);
        end
        
    end

end
   
    
cd(basedir)
qim = im;
qdata = data;
save all_question_data.mat qim qdata
