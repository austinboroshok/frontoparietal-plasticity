function [keys,response,isCorrect] = keys_get_response(keys,dat,coherence,response,isCorrect)
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
    
    response = find(resp);
    keys.isDown = 1;
    
    %is response correct?
    if response == 1 && coherence > 0 || response == 2 && coherence == 0
        
        display(['...Correct']);
        
        isCorrect = 1;
        
        %play sound for correct response
        if dat.feedback
            sound(dat.stm.sound.sFeedback, dat.stm.sound.sfFeedback);               % sound presentation
        end
        
    else
        isCorrect = 0;
        display(['...Wrong']);
    end
    
elseif keyCode(keys.esc)
    
    keys.killed = 1;
    keys.isDown = 1;
    
elseif sum(resp) == 0
    
    keys.isDown = 0;
    
end

