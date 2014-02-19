function initialize_screen

Screen('CloseAll')




if ismac,
    ScreenNum = max(Screen('Screens'));
elseif ~ismac,
    ScreenNums = (Screen('Screens'));
    if length(ScreenNums) > 1,
        ScreenNum = 1;
    else
        ScreenNum = 0;
    end
end
disp(ScreenNum)
[w.win , w.winRect] = Screen('OpenWindow', ScreenNum,[0 0 0]);