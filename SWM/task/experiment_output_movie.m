function experiment_output(MSS_output,PRINT_OUTPUT)

%experiment_output(MSS_output)
%Takes output of MSS and prints a short report to the screen and to a tab
%delimited file.  PRINT_OUTPUT is a 0,1 flag that specifies whether output
%should only be printed to the screen (0), or also to a .txt file (1).


if isempty(MSS_output)
    fprintf('You gave me no file.\n')
    return;
end;

load(MSS_output);


if PRINT_OUTPUT
    fid = fopen(['test_output.txt'],'w');

    if ~isempty(key_presses_movie2)
        fprintf(fid,'\n\nAll Keys Pressed:\n\nKey\tTime\tAccompanying Stimulus\n');
        for i = 1:length(key_presses_movie2);
            fprintf(fid,'%s\t%.2f\t%s\n',key_presses_movie2.key{i},key_presses_movie2.time(i),key_presses_movie2.stimulus{i});    
        end
    end;
end;

