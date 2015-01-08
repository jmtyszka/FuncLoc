function [t0,t1,ch] = Fixation(fix_size,fix_col,dur,screen_info)

fprintf('  Presenting fixation cross\n');

t0 = GetSecs;
t1 = t0 + dur;

vert_rect = [0 0 fix_size/8 fix_size];
horiz_rect = [0 0 fix_size fix_size/8];
vert_rect = CenterRectOnPoint(vert_rect,screen_info.sx0,screen_info.sy0);
horiz_rect = CenterRectOnPoint(horiz_rect,screen_info.sx0,screen_info.sy0);

% Fixation cross (draw offscreen and flip)
Screen('FillRect',screen_info.window,screen_info.black);
Screen('FillRect',screen_info.window,fix_col,vert_rect);
Screen('FillRect',screen_info.window,fix_col,horiz_rect);
Screen('Flip',screen_info.window);

FlushEvents;
ch = ' ';
while GetSecs < t1 && ch ~= 'q';
  if CharAvail; ch = lower(GetChar); end
end