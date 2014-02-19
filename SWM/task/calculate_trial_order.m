function trial_order = calculate_trial_order(type,num)

%this function takes in the vector "type" and the vector "num" associated
%with the MSS script, and sorts them according to the rules of MacStim
%NOTE!  BLOCK MAC STIM ORDERING OPTIONS NOT IMPLEMENTED HERE-- NO BLOCK
%OPTION 'b', Option 'r' is still in beta

default_order = 1:length(type); %sets default to consecutive, single trial order

type = lower(type);
type(find(type=='p')) = 's'; %for order purposes, pause and single trials are the same thing
type(find(type=='c')) = 's'; %for order purposes, continuous and single trials are the same thing

%make sure inputs are valid
if ~exist('type')
    fprintf('Your type vector does not exist.  Returning default order.\n')
    trial_order = default_order;
    return;
elseif isempty(type)
    fprintf('Your type vector is empty.  Returning default order.\n')
    trial_order = default_order;
    return;
elseif ~isempty(find(type~='s' & type~='r' & type~='b' & type~=0))
    fprintf('Your type contains invalid characters or numbers.  Returning default order.\n')
    trial_order = default_order;
    return;
end;

try
    if isempty(find(type~='s')) | isempty(find(type~=0)) %if all single trials or if not specified
        trial_order = 1:length(type);
        return; 
    end;

    num(find(num==0)) = 1; %change default padded values (zeros) to ones to prepare for randomization        
    trial_order = 1:length(type);     
    begin_block = -1;

    for i = 1:length(type)
        if type(i) == 'r' && begin_block < 0 
            begin_block = i;
        end
        if type(i)~= 'r' && begin_block > 0
            if i - begin_block > 1
                trial_order(begin_block:i-1) = randomize_block(num,begin_block,i-1); % = block_order
            end;
            begin_block = -1;
        end;
    end;

    if type(end) == 'r' && begin_block > 0
        trial_order(begin_block:i) = randomize_block(num,begin_block,length(type));
    end;
    
catch
    fprintf('\nPROBLEM! I didn''t understand your input for type or num. \nMake sure that number of ''r''s and nums make sense.\n!!!FALLING BACK TO DEFAULT ORDER!!!\n');  
    trial_order = default_order;
end;

