function [w] = initialize_screen(ScreenNum,background_color,window_size)

% Screen('CloseAll')
% 
% comp = Screen('Computer');
% if comp.windows,
%     mac_mode = 0;
% elseif ~comp.windows
%     mac_mode = 1;
% end
% 
% 

%%

% comp = Screen('Computer');
% if comp.windows,
%     mac_mode = 0;
% elseif ~comp.windows
%     mac_mode = 1;
% end
% 
% 
% if mac_mode,
%     ScreenNum = max(Screen('Screens'));
% elseif ~mac_mode,
%     ScreenNums = (Screen('Screens'));
%     if length(ScreenNums) > 1,
%         ScreenNum = 1;
%     else
%         ScreenNum = 0;
%     end
% end

%%


if nargin < 3, window_size = []; end
[w.window, w.wRect] = Screen('OpenWindow', ScreenNum ,background_color,window_size);

w.win = w.window;
w.res = w.wRect;

[w.ScreenWidth, w.ScreenHeight]=Screen('WindowSize', w.window);
w.ScreenCenterX = w.ScreenWidth/2;
w.ScreenCenterY = w.ScreenHeight/2;
w.ScreenCenter = [w.ScreenCenterX, w.ScreenCenterY];

w.white = WhiteIndex(w.window);
w.black = BlackIndex(w.window);
w.gray = round(((w.white-w.black)/2));
w.background_color = background_color;

w.default_textsize = 30;

w.eye2scr_distance = 30; %inches
w.physical_width = 15.75; %inches
w.physical_height  = 11.75;
% w.target_fix_dva = 2;
% w.fix_color = [0,0,0];

w.Screen_struct.sz = [w.physical_width w.physical_height];
w.Screen_struct.vdist = w.eye2scr_distance;
w.pixperdva = (w.ScreenCenter./2) ./ ((180/pi) .* atan((w.Screen_struct.sz./2)/w.Screen_struct.vdist));
w.degperpix=1./w.pixperdva;
w.pixperdva_w = w.pixperdva(1);
w.pixperdva_h = w.pixperdva(2);




%% misc:

% Screen(w.window,'TextSize',40);
% Screen(w.window,'TextFont','sans-serif'); %'Times New Roman','Arial', 'Geneva', 'Helvetica', 'sans-serif'




% xy_LR = [w.ScreenCenterX - el.fix_size, w.ScreenCenterX + el.fix_size; w.ScreenCenterY, w.ScreenCenterY];
% xy_UD = [w.ScreenCenterX, w.ScreenCenterX; w.ScreenCenterY - el.fix_size, w.ScreenCenterY + el.fix_size];
%
% xy = [xy_LR xy_UD];
