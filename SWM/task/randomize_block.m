function block_order = randomize_block(num,strt,fnsh)

%figure out how many blocks we have
b = 0; %number of blocks
i = strt;
while i <= fnsh
    b = b+1;
    start_points(b) = i;
    i = i + num(i); %jump ahead by the number of lines specified in the first line of the r block
end;
    
p = randperm(b); %randomize the order of blocks within a section

block_order = [];
for i = 1:b %number of blocks
    if start_points(p(i)) +num(start_points(p(i)))-1 > fnsh
       fprintf('Error: check your num and type columns for consistency\n\n'); 
    end
    block_order = [block_order start_points(p(i)):(start_points(p(i)) +num(start_points(p(i)))-1)]; %p(i) is the block you are getting, start_points is where the block starts, and num is how long the block is        
end;
     
if length(block_order) ~= (fnsh - strt + 1)
    fprintf('Uh oh.  length(block_order) ~= (fnsh - strt + 1)\n')
    fprintf('length(block_order) = %d, strt = %d, fnsh = %d, b = %d.\n',length(block_order),strt,fnsh,b)
end;
