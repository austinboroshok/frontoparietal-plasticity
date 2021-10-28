function [dat,keys,letter_code] = keys_get_response_training(keys,dat,trial,letter_code,white_letters)
%
%

[~, ~, keyCode] = KbCheck(-3);

% if there was a new response
if sum(keyCode) && keys.isDown == 0
    
    % make sure it's a letter and play sound if it's not
    resp = upper(KbName(find(keyCode)));

    if numel(resp) == 1 && ~isempty(find(dat.letter_set == resp(1)))
        % get letter response
        letter_code = [letter_code find(keyCode)];
    else
        % make a sound, don't store response
        sound(dat.stm.sound.sNo, dat.stm.sound.sfNo);
    end
    
    KbWait(-3,1);
    
    if keyCode(keys.esc)
        
        keys.killed = 1;
        keys.isDown = 1;
        
    end

    
    if length(letter_code) == 2
        
        %characters
        letter_resp1 = upper(KbName(letter_code(1)));
        letter_resp2 = upper(KbName(letter_code(2)));
        letter_code1 = find(dat.letter_set == letter_resp1);
        letter_code2 = find(dat.letter_set == letter_resp2);
        
        % store response
        display(['Response is ... ' letter_resp1 ' ' letter_resp2 ]);
        
        dat.trials.resp{trial} = [letter_resp1 letter_resp2];
        dat.trials.respCode(trial,:) = [letter_code1 letter_code2];
        
        keys.isDown = 1;
        
        %is response correct?
        if sum(dat.trials.respCode(trial,:) == white_letters) == 2
            
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
        
    end
    
elseif keyCode(keys.esc)
    
    keys.killed = 1;
    keys.isDown = 1;
    
else
    
    keys.isDown = 0;
    
end

