function [dat,keys] = keys_get_response_orig(keys,dat,trial,coherence)
%
%

resps = {'coherent','random'};

[~, ~, keyCode] = KbCheck();


resp(1) = keyCode(keys.coherent);
resp(2) = keyCode(keys.random);

% if there was a new response
if sum(resp) == 1 && keys.isDown == 0
    
    % store response
    display(['Response is ... ' resps{logical(resp)}]);
    
    dat.trials.resp{trial} = resps{logical(resp)};
    dat.trials.respCode(trial) = find(resp);
    keys.isDown = 1;
    
    %is response correct?
    if dat.trials.respCode(trial) == 1 && coherence > 0 || dat.trials.respCode(trial) == 2 && coherence == 0
        
        display(['...Correct']);
        
        dat.trials.isCorrect(trial) = 1;
        
        %play sound for correct response
        if dat.feedback
            sound(dat.stm.sound.sFeedback, dat.stm.sound.sfFeedback);               % sound presentation
        end
        
    else
        dat.trials.isCorrect(trial) = 0;
        display(['...Wrong']);
    end
    
elseif keyCode(keys.esc)
    
    keys.killed = 1;
    keys.isDown = 1;
    
elseif sum(resp) == 0
    
    keys.isDown = 0;
    
end

