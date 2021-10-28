function [dat,keys] = keys_get_response_testing(w,keys,dat,trial,blockTrial,nback,sound_index,TrialStartTime)
%
%

[~, ~, keyCode] = KbCheck(-3);

yes = keyCode(keys.yes);
no = keyCode(keys.no);

respCode = {'yes','no'};

% if there was a new response
if any([yes no]) && keys.isDown == 0
    
    dat.trials.respTime(trial) = GetSecs - TrialStartTime;
    
    % display response
    if yes
        response = 1;
        DrawFormattedText(w, ['YES (' dat.scr.response_mapping{1} ')'], 'center', dat.scr.y_center_pix - dat.scr.y_center_pix/8, [255 255 0]);
        
    elseif no
        response = 2;
        DrawFormattedText(w, ['NO (' dat.scr.response_mapping{2} ')'], 'center', dat.scr.y_center_pix + dat.scr.y_center_pix/8, [255 255 0]);
    end
    
    % store response
    display(['Response is ... ' respCode{response}]);
    
    dat.trials.resp(trial)  = response;
    keys.isDown = 1;
    
    %is response correct?
    
    % if the trial number is greater than the nback number
    if blockTrial > nback
        
        if response == 1 && sound_index == dat.trials.sound_index(trial-nback)
            
            dat.trials.isCorrect(trial) = 1;
            display(['...Correct']);
            
        elseif response == 2 && ~(sound_index == dat.trials.sound_index(trial-nback))
            
            dat.trials.isCorrect(trial) = 1;
            display(['...Correct']);
            
        elseif response == 1 && ~(sound_index == dat.trials.sound_index(trial-nback))
            
            dat.trials.isCorrect(trial) = 0;
            display(['...Wrong']);
            
        elseif response == 2 && sound_index == dat.trials.sound_index(trial-nback)
            
            dat.trials.isCorrect(trial) = 0;
            display(['...Wrong']);
            
            %         %play sound for incorrect response
            %         if dat.feedback
            %             sound(dat.stm.sound.sNo, dat.stm.sound.sfNo);               % sound presentation
            %         end
            
        end
        
    elseif blockTrial <= nback
        
        % first trials, correct answer is always no
        if response == 1
            
            dat.trials.isCorrect(trial) = 0;
            display(['...Wrong']);
            
        elseif response == 2
            
            dat.trials.isCorrect(trial) = 1;
            display(['...Correct']);
             
        end
        
    end
    
    Screen('Flip',  w, [], 1);
    
    
elseif keyCode(keys.esc)
    
    keys.killed = 1;
    keys.isDown = 1;
    
elseif any([yes no]) == 0
    
    keys.isDown = 0;
    
end

