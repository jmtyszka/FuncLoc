function draw_text_centered(w, text, color, textsize, y_offset, write_background)

if ~exist('write_background','var'), 
    write_background = 1;
end
if ~exist('y_offset','var'), 
    y_offset = 0;
end
    
if nargin == 0, 
    text = 'no text provided...';
    color = [0 0 0];
    textsize = 30;
end

if nargin == 1,
    color = [0 0 0];
    textsize = 30;
end

if nargin ==2,
    textsize = 30;
end

Screen(w.window,'TextSize',textsize);

[text_size] = Screen('TextBounds', w.window, text);
text_x = text_size(1,3);
text_y = text_size(1,4);

text_x_offset =  w.ScreenCenterX - (text_x/2);
text_y_offset =  w.ScreenCenterY - (text_y/2) + y_offset;

if write_background,
    Screen('FillRect',w.window, w.background_color);
end
Screen('DrawText', w.window, text, text_x_offset, text_y_offset, color);


