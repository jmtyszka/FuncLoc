function [keyCaught key_presses_movie movie_start] = DisplayMovie(movie,win,stpEvt,maxTime,inputDevice)

%function [keyCaught key_presses_movie movie_start] = DisplayMovie(movie,win,stpEvt,inputDevice)
% 
%Play movie 'movie' in window 'win' where stpEvt keys will stop the video,
%and input device is specified from MSS (e.g. device number of button box)
% This script allows playback for synchronized playback of video and sound. 
% This script assumes that resources are preloaded
% This script will record all keys pressed while a movie is being displayed
% (key_presses_movie) as well as the specific key that caused a stop event,
% should one occur (keyCaught)
% This script is adapted from PlayMoviesDemoOSX
% This needs MacOS-X 10.3.9 or 10.4.x with Quicktime-7 installed!

DEBUG = 1;
keyCaught = [];
key_presses_movie = struct('key',{{}},'time',[]); %matrix to hold key pressed, time of key press--> will be used to store back up info

d=clock; % read the clock information
		 % this spits out an array of numbers from year to second

output_filename_movie=sprintf('moviebackup_%s_%02.0f-%02.0f.mat',date,d(4),d(5));
    
% Initial display 
% Screen('Flip',win);

% Playbackrate defaults to 1
rate=1;

% Seek to start of movie (timeindex 0):
Screen('SetMovieTimeIndex', movie, 0);
movie_start = GetSecs;

% Start playback of movie. This will start
% the realtime playback clock and playback of audio tracks, if any.
% Play 'movie', at a playbackrate = 1, with endless loop=0 and
% 1.0 == 100% audio volume.
Screen('PlayMovie', movie, rate, 0, 1.0);

dstRect = CenterRect(ScaleRect(Screen('Rect', win),1,1 ) , Screen('Rect', win)); %this allows rezising of the movie (current setting is 1,1 but can be changed)

KbQueueCreate(inputDevice);

k = 0;
% Fetch video frames and display them...
while(1)
    if (abs(rate)>0)
        
        
        KbQueueStart;
        
        % Return next frame in movie, in sync with current playback
        % time and sound.
        % tex either the texture handle or zero if no new frame is
        % ready yet. pts = Presentation timestamp in seconds.
        [tex] = Screen('GetMovieImage', win, movie, 1);

        % Has the movie ended?
        if tex<=0 
            break;
        end;
        
        %Has the movie played for the total time specified in maxTime?
        if maxTime > 0 && GetSecs - movie_start >= maxTime
            break;
        end;

        % Draw the new texture immediately to screen:
        Screen('DrawTexture', win, tex,[],dstRect);
        Screen('DrawingFinished',win);
        
        [pressed, firstPress]=KbQueueCheck;

        if pressed
            
            %record the keypresses in the temporal order that they were pressed
            keylist = firstPress;
            while sum(keylist)>0, %if a key was pressed 
                j = find(keylist==min(nonzeros(keylist))); %find the keys that were pressed
                for k = 1:length(j)
                    key_presses_movie.key{length(key_presses_movie.key)+1} = KbName(j(k));
                    key_presses_movie.time(length(key_presses_movie.time)+1) = keylist(j(k))-movie_start; %records time in relation to start of movie to facilitate backup of keys pressed
                    keylist(j(k))=0;
                end
            end;
            
            if mod(k,30) == 0;
                % save key presses to the movie key presses back up file
                save(output_filename_movie,'key_presses_movie');
            end;
            k= k +1;

            
            %if stpEvt occurs, then, break
            [stopped stopEvt] = is_stop_event(firstPress,stpEvt);
            if stopped
                if DEBUG
                    fprintf('Trying to stop movie.\n');
                end;
                Screen('PlayMovie', movie, 0);
                Screen('CloseMovie', movie);
                Screen('Flip', win);
                if DEBUG
                    fprintf('Display movie is returning %s\n',KbName(firstPress));
                end;
                KbQueueRelease; 
                keyCaught = stopEvt;
                return;
                %break;
            end
        end;
        
        [keyIsDown,secs,keyCode]=KbCheck(inputDevice);
        
        if ~keyIsDown
            KbQueueFlush;
        end
        
        % Update display:
        Screen('Flip', win);
        
        % Release texture:
        Screen('Close', tex);
    end;
end;

% Screen('Flip', win);

% Done. Stop playback:
Screen('PlayMovie', movie, 0);

% Close movie object:
Screen('CloseMovie', movie);