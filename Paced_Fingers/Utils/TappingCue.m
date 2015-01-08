function [t0,t1] = TappingCue(box_color, box_size, dur, screen_info)
% Present four tapping cue squares centrally.
%
% SYNTAX: [t0,t1] = TappingCue(box_color, box_size, dur, screen_info)
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

nbox = size(box_color,1);

for bc = 1:nbox

  % Calculate box position
  x0 = screen_info.sx0 + box_size * (bc-(nbox+1)/2) * 1.5;
  y0 = screen_info.sy0;

  % Center the box at the correct location
  box_rect = CenterRectOnPoint(box_rect,x0,y0);

  % Draw box
  Screen('FillRect',screen_info.window,box_color(bc),box_rect);
  
end

% Final reveal
Screen('Flip',screen_info.window);

while GetSecs < t1; end