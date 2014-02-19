function [nx, ny, textbounds] = DrawFormattedText_new(win, tstring, sx, sy, color, wrapat, hshift, vshift)
% [nx, ny, textbounds] = DrawFormattedText_new(win, tstring [, sx][, sy][, color][, wrapat][, hshift][, vshift])
%
% Draws a string of text 'tstring' into Psychtoolbox window 'win'. Allows
% some basic formatting. The text string 'tstring' may contain newline
% characters '\n'. Whenever a newline character '\n' is encountered, a
% linefeed and carriage return is performed, breaking the text string into
% lines. 'sx' defines the left border of the text: If it is
% left out, text starts at x-position zero, otherwise it starts at the
% specified position 'sx'. If sx=='center', then each line of text is
% horizontally centered in the window. 'sy' defines the top border of the
% text. If left out, it starts at the top of the window, otherwise it
% starts at the specified vertical pixel position. If sy=='center', then
% the whole text is vertically centered in the window. 'color' is the color
% value of the text (color index or [r g b] triplet or [r g b a]
% quadruple). If color is left out, the current text color from previous
% text drawing commands is used. 'wrapat', if provided, will automatically
% break text strings longer than 'wrapat' characters into newline separated
% strings of roughly 'wrapat' characters. This is done by calling the
% WrapString function (See 'help WrapString').
%
% The function returns the new (nx, ny) position of the text drawing cursor
% and the bounding rectangle 'textbounds' of the drawn string. (nx,ny) can
% be used as new start position for connecting further text strings to the
% bottom of the drawn text string. Calculation of these bounds is
% approximative, so it may give wrong results with some text fonts and
% styles on some operating systems.
%
% See DrawFormattedTextDemo for a usage example.

% History:
% 10/17/06  Written (MK).
% 11/01/06  Add support for correct handling of 3D rendering mode (MK).
% 11/22/06  More 3D handling: Save/restore backface cull state (MK).
% 05/14/07  Return a more meaningful end cursor position (printf - semantics) (MK)
% 12/12/07  Changed wrapat to wrap at a pixel number instead of a character number
% 12/14/07  Added hshift and vshift


% We need GL for drawing in 3D rendering mode:
global GL;

if nargin < 1 || isempty(win)
    error('DrawFormattedText: Windowhandle missing!');
end

if nargin < 2 || isempty(tstring)
    error('DrawFormattedText: Text string missing!');
end

%fprintf('DrawFormattedText_new received: %s\n',tstring);

% Default x start position is left border of window:
if nargin < 3 || isempty(sx)
    sx=0;
end

if ischar(sx) && strcmpi(sx, 'center')
    xcenter=1;
    sx=0;
else
    xcenter=0;
end

% No text wrapping by default:
if nargin < 6 || isempty(wrapat)
    wrapat = 0;
end

% If '\n' is already encoded as a char(10) as in Octave, then
% there's no need for replacemet.
if char(10) == '\n'
   newlinepos = [];
end

%THIS IS THE PRIMARY THING THAT IS CHANGED FROM THE ORIGINAL
%(DrawFormattedText.m)
%Wraps at a pixel count instead of a character count  

if wrapat > 0
    currentline = [];
	remainder = tstring;
	formattedtext = [];
	while ~isempty(remainder)
		[token remainder] = wsstrtok(remainder);
        %fprintf('currentline = %s\n',currentline);
        
		%If the single word token is longer than wrapat it gets a line by itself
		if isempty(currentline) 
			[normBoundsRect, offsetBoundsRect] = Screen(win,'TextBounds', token );
			if( normBoundsRect(3) > wrapat )
				formattedtext = [formattedtext token '\n']; %Note strcat throws away leading and trailing whitespace, so you need to use matrix notation to concatenate
				continue;
			end;
		end;
			
		[normBoundsRect, offsetBoundsRect] = Screen(win,'TextBounds',[currentline token] );
        
        %fprintf( 'Testing line: \n %s \n width is %d pixels\n',[currentline token],normBoundsRect(3));
        
        if( normBoundsRect(3) > wrapat ) %If adding the token made the string too long
			formattedtext = [formattedtext currentline '\n']; %Add the currentline
			remainder = [token remainder]; %Put the token back in the string.
			currentline = ''; 
		else
			%If adding the token didn't make the string too long
			currentline = [currentline token];
		end
	end;
    %fprintf('tstring was \n\n %s \n\n Formatted text is \n\n %s \n\n',tstring,formattedtext);
	tstring = [formattedtext currentline];
end
		
% Convert all conventional linefeeds into C-style newlines:
newlinepos = strfind(tstring, '\n');

while ~isempty(newlinepos)
    % Replace first occurence of '\n' by ASCII code 10:
    tstring = [ tstring(1:min(newlinepos)-1) char(10) tstring(min(newlinepos)+2:end)];
    % Search next occurence of linefeed (if any) in new expanded string:
    newlinepos = strfind(tstring, '\n');
end

% Query textsize for implementation of linefeeds:
theight = Screen('TextSize', win);
% Query window size as well:
[winwidth winheight] = Screen('WindowSize', win);

% Default y start position is top of window:
if nargin < 4 || isempty(sy)
    sy=0;
end

if ischar(sy) && strcmpi(sy, 'center')
    % Compute vertical centering:
    
    % Compute height of text box:
    numlines = length(strfind(tstring, char(10))) + 1;
    bbox = SetRect(0,0,1,numlines * theight);
    % Center box in window:
    [rect,dh,dv] = CenterRect(bbox, Screen('Rect', win));

    % Initialize vertical start position sy with vertical offset of
    % centered text box:
    sy = dv;
end

% Keep current text color if noone provided:
if nargin < 5 || isempty(color)
    color = [];
end

% Init cursor position:
xp = sx;
yp = sy+vshift;
nx = xp;
ny = yp;

minx = inf;
miny = inf;
maxx = 0;
maxy = 0;

% If we are in 3D mode, we need to make sure we have a ortho-projection set
% up.
if (~isempty(GL)) && (Screen('Preference', 'Enable3DGraphics')>0)
    % 3D mode active:
    gl3dmode = 1;
    
    % First we backup all relevant transformation matrices and set up
    % identity orthonormal transforms for our purpose:
    glMatrixMode(GL.PROJECTION);
    glPushMatrix;
    glLoadIdentity;
    gluOrtho2D(0, winwidth, winheight, 0);
    glMatrixMode(GL.MODELVIEW);
    glPushMatrix;
    glLoadIdentity;

    % Disable lighting and blending and texture mapping:
    culling_on = glIsEnabled(GL.CULL_FACE);
    lights_on = glIsEnabled(GL.LIGHTING);
    blending_on = glIsEnabled(GL.BLEND);
    tex2d_on = glIsEnabled(GL.TEXTURE_2D);
    texrect_on = glIsEnabled(GL.TEXTURE_RECTANGLE_EXT);
    glDisable(GL.CULL_FACE);
    glDisable(GL.LIGHTING);
    glDisable(GL.BLEND);    
    glDisable(GL.TEXTURE_2D);
    glDisable(GL.TEXTURE_RECTANGLE_EXT);
else
    % Pure 2D drawing, nothing special to do.
    gl3dmode = 0;
end

% Parse string, break it into substrings at line-feeds:
while length(tstring)>0
    % Find next substring to process:
    crpositions = strfind(tstring, char(10));
    if ~isempty(crpositions)
        curstring = tstring(1:min(crpositions)-1);
        tstring = tstring(min(crpositions)+1:end);
        dolinefeed = 1;
    else
        curstring = tstring;
        tstring =[];
        dolinefeed = 0;
    end

    % tstring contains the remainder of the input string to process in next
    % iteration, curstring is the string we need to draw now.

    % Any string to draw?
    if ~isempty(curstring)
        % Horizontally centered output required?
        if xcenter
            % Yes. Compute text bounding box for this substring and compute
            % dh, dv position offsets to center it in the center of window.
            bbox=Screen('TextBounds', win, curstring);
            [rect,dh,dv] = CenterRect(bbox, Screen('Rect', win));
            % Set drawing cursor to horizontal x offset:
            xp = dh;
        end
            
        [nx ny] = Screen('DrawText', win, curstring, xp + hshift, yp, color);
    else
        % This is an empty substring (pure linefeed). Just update cursor
        % position:
        nx = xp;
        ny = yp;
    end

    % Update bounding box:
    minx = min([minx , xp, nx]);
    maxx = max([maxx , xp, nx]);
    miny = min([miny , yp, ny]);
    maxy = max([maxy , yp, ny]);

    % Linefeed to do?
    if dolinefeed
        % Update text drawing cursor to perform carriage return:
        if xcenter==0
            xp = sx;
        end
        yp = ny + theight;
    else
        % Keep drawing cursor where it is supposed to be:
        xp = nx;
        yp = ny;
    end
    % Done with substring, parse next substring.
end

% Add one line height:
maxy = maxy + theight;

% Create final bounding box:
textbounds = SetRect(minx, miny, maxx, maxy);
% Create new cursor position. The cursor is positioned to allow
% to continue to print text directly after the drawn text.
% Basically behaves like printf or fprintf formatting.
nx = xp;
ny = yp;

% Was this drawing in 3D mode?
if gl3dmode > 0
    % Yes. Need to restore transform matrices and other GL state:
    glMatrixMode(GL.PROJECTION);
    glPopMatrix;
    glMatrixMode(GL.MODELVIEW);
    glPopMatrix;

    % Conditionally reenable lighting and blending and texture mapping:
    if culling_on
        glEnable(GL.CULL_FACE);
    end
    
    if lights_on
        glEnable(GL.LIGHTING);
    end

    if blending_on
        glEnable(GL.BLEND);
    end

    if tex2d_on
        glEnable(GL.TEXTURE_2D);
    end

    if texrect_on
        glEnable(GL.TEXTURE_RECTANGLE_EXT);
    end

end

return;
