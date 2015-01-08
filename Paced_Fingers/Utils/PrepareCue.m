function [t0,t1,ch] = PrepareCue(txt,col,dur,screen_info)
% Present preparation cue for finger tapping.
%
% SYNTAX: [t0,t1] = PrepareCue(box_color, box_size, dur, screen_info)
%
% ARGS:
% box_color = matrix of colors for boxes (4 x 3)
% box_size = box dimensions (in pixels)
% dur = duration of box presentation in seconds
% screen_info = screen information structure used by PTB
% 
% AUTHOR: Mike Tyszka, Ph.D.
% PLACE : Caltech Brain Imaging Center
% DATES : 11/18/2007 JMT Created for Bimanual protocol
%         09/24/2008 JMT Adapt for Paced_Fingers protocol
%
% Copyright 2008 California Institute of Technology.
% All rights reserved.

fprintf('  Presenting preparation cue\n');

t0 = GetSecs;
t1 = t0 + dur;

txt_rect = Screen('TextBounds', screen_info.window, txt);
xpos = screen_info.sx0 - RectWidth(txt_rect)/2;
ypos = screen_info.sy0 - RectHeight(txt_rect)/2;

Screen('FillRect', screen_info.window, screen_info.black);
Screen('DrawText', screen_info.window, txt, xpos, ypos, col);
Screen('Flip',screen_info.window);

ch = ' ';
while GetSecs < t1 && ch ~= 'q';
  if CharAvail; ch = lower(GetChar); end
end