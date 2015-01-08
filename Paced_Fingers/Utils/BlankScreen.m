function [t0,t1] = BlankScreen(dur,screen_info)

fprintf('  Blanking screen\n')

t0 = GetSecs;
t1 = t0 + dur;

Screen('FillRect',screen_info.window,screen_info.black);
Screen('Flip',screen_info.window);

while GetSecs < t1; end