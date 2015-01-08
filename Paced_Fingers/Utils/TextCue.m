function [t0,t1,ch] = TextCue(txt,col,dur,screen_info)

fprintf('  Presenting text cue\n');

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