function [t0,t1] = CenterSquare(box_size,box_col,dur,screen_info)

t0 = GetSecs;
t1 = t0 + dur;

box_rect = [0 0 box_size box_size];
box_rect = CenterRectOnPoint(box_rect,screen_info.sx0,screen_info.sy0);

% Fixation cross (draw offscreen and blit)
Screen(screen_info.offscreen,'FillRect',screen_info.bgcolor);
Screen(screen_info.offscreen,'FillRect',box_col,box_rect);
Screen(screen_info.onscreen,'WaitBlanking');
Screen('CopyWindow',screen_info.offscreen,screen_info.onscreen);

while GetSecs < t1; end