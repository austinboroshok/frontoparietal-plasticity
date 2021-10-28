function [dat,keys] = keys_get_response_testing(keys,dat,trial,direction)
%
%

[~, ~, keyCode] = KbCheck(-3);

resp(1) = keyCode(keys.upright);
resp(2) = keyCode(keys.upleft);
resp(3) = keyCode(keys.downleft);
resp(4) = keyCode(keys.downright);

% if there was a new response
if sum(resp) == 1 && keys.isDown == 0
    
    if resp(1)
        response = 45;
    elseif resp(2)
        response = 135;
    elseif resp(3)
        response = 225;
    elseif resp(4)
        response = 315;
    end
    
    % store response
    display(['Response is ... ' num2str(response)]);
    
    dat.trials.resp(trial)  = response;
    keys.isDown = 1;
    
    %is response correct?
    if dat.trials.resp(trial) == direction
        
        display(['...Correct']);
        
        dat.trials.isCorrect(trial) = 1;
        
        %play sound for correct response
        if dat.feedback
            sound(dat.stm.sound.sYes, dat.stm.sound.sfYes);               % sound presentation
        end
        
    else
        dat.trials.isCorrect(trial) = 0;
        display(['...Wrong']);
        
        %play sound for incorrect response
        if dat.feedback
            sound(dat.stm.sound.sNo, dat.stm.sound.sfNo);               % sound presentation
        end
    end
    
elseif keyCode(keys.esc)
    
    keys.killed = 1;
    keys.isDown = 1;
    
elseif sum(resp) == 0
    
    keys.isDown = 0;
    
end

