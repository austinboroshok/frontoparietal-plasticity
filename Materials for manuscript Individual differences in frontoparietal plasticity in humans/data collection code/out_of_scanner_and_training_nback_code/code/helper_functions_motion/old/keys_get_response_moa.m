function [keys,coherence,done] = keys_get_response_moa(keys,dat,coherence)
%
%

[~, ~, keyCode] = KbCheck();

big_up      = keyCode(keys.big_up);
big_down    = keyCode(keys.big_down);
same        = keyCode(keys.space);
done        = keyCode(keys.enter);

resp = sum([big_up big_down same done]);

% if there was a new response
if resp == 1 && keys.isDown == 0
    
    keys.isDown = 1;
    
    %update coherence based on response
    if big_up
        
        if coherence >= 25
            
            coherence = min([100 coherence + dat.big_stepsize]);
        else
            coherence = min([100 coherence + dat.small_stepsize]);
        end
            
        
    elseif big_down
        
        if coherence >= 25
        
            coherence = max([0 coherence - dat.big_stepsize]);
        else
            
            coherence = max([0 coherence - dat.small_stepsize]);
        end
        
    elseif same
        
        coherence = coherence;
        
    elseif done
        
        coherence = coherence;
        
    end

    display(num2str(coherence));
        
    
elseif keyCode(keys.esc)
    
    keys.killed = 1;
    keys.isDown = 1;
    
elseif resp == 0
    
    keys.isDown = 0;
    
end

