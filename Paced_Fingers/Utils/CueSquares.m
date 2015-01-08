function [t0,t1] = TappingCue(box_color,box_size,dur,screen_info)
% Present four tapping cue squares centrally.
%
% SYNTAX: [t0,t1] = TappingCue(box_color,box_size,dur,screen_info)
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

t0 = GetSecs;
t1 = t0 + dur;

% Construct rectangles
box_rect = [0 0 box_size box_size];

for bc = 1:nbox

  % Calculate box position
  x0 = screen_info.sx0 + box_size * (bc-1-nbox/2);
  y0 = screen_info.sy0;

% Center the box at the correct location
  rect = CenterRectOnPoint(box_rect,x0,y0);

  % Draw box
  Screen(screen_info.offscreen,'FillRect',color(bc),rect);
  
end

Screen(screen_info.onscreen,'WaitBlanking');
Screen('CopyWindow',screen_info.offscreen,screen_info.onscreen);

while GetSecs < t1; end