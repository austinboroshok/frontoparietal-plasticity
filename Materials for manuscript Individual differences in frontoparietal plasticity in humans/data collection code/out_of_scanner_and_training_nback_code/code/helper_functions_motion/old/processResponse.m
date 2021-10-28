% Part of PTBStaircase class
% Robin Held
% Banks Lab
% UC Berkeley

% This function takes in the latest response and updates the number of
% reversals, step size, etc.
% Here, 0 means the response should be skipped, 1 means 'less,' (or
% in the case of slant nulling, that the stimulus appeared to have
% negative slant), and 2 means 'more'

function [ms] = processResponse(ms,response)


% Add response to response vector
allresponses        = [get(ms,'responses') response];
allcoherences       = get(ms,'coherences');
complete            = get(ms,'complete');
stepSize            = get(ms,'stepSize');
currentReversals    = get(ms,'currentReversals');

% Check whether this is the first response
if length(allresponses) ~= 1
          
    % Check whether the current response is the same as the last one
    if response ~= allresponses(length(allresponses) - 1)
        
        % this was a reversal
        currentReversals = currentReversals + 1;
        reversalFlag = 1;
        
        % Check if the max # of reversals has been met
        if (currentReversals == get(ms,'maxReversals'))
            
            complete = 1;
            display 'Staircase complete!';
            
        else
            
            % Halve the step size
            stepSize = stepSize / 2;
            
            % Make sure the stepSize is larger than the minimum
            if abs(stepSize) < abs(get(ms,'stepLimit'))
                stepSize = sign(stepSize) * abs(get(ms,'stepLimit'));
            end
            
        end
        
    else %response is same as previous
        
        reversalFlag = 0;
        
    end
    
    if(length(allresponses)>get(ms,'maxTrials'))
        complete = 1;
        display 'Staircase terminated, trial count exceeded';
    end
    
else
    
    % This is the first response, so make sure the first value was recorded
    allcoherences = get(ms,'currentCoherence');
    reversalFlag = 0;
    
end

% Determine the next stimulus value...if the staircase is not complete
if ~complete
    
    if response == 1 %coherent
        
        if reversalFlag
            if get(ms,'numUp') == 1 && get(ms,'numDown') == 2
                stepSign = 0; %keep coherence the same for one trial after reversal
            elseif get(ms,'numUp') == 1 && get(ms,'numDown') == 1
                stepSign = -1;
            else
                error('invalid staircase procedure');
            end
        else
            stepSign = -1; % decrease coherence
        end
        
    elseif response == 2 %random
        
        stepSign = 1; % increase coherence
        
    end
    
    newValue = (get(ms,'currentCoherence') + stepSign * stepSize);
    
    % Make sure the new value is not outside the acceptable range
    if newValue > get(ms,'maxCoherence')
        newValue = get(ms,'maxCoherence');
    elseif newValue < get(ms,'minCoherence')
        newValue = get(ms,'minCoherence');
    end
    
       
    
    
    %     if ((stepSign == 1 && reversalFlag >= get(ms,'numUp'))  || ...
    %             (stepSign == -1 && reversalFlag >= get(ms,'numDown'))) % make an adjustment
    %
    %         % Make sure the new value is not outside the acceptable range
    %         newValue = (get(ms,'currentCoherence') + stepSign * stepSize);
    %         if newValue > get(ms,'maxCoherence')
    %             newValue = get(ms,'maxCoherence');
    %         elseif newValue < get(ms,'minCoherence')
    %             newValue = get(ms,'minCoherence');
    %         end
    %
    %         reversalFlag = 0;  %reset responserun after an adjustment
    %
    %     else  %don't make an adjustment
    %         newValue = get(ms,'currentCoherence');
    %     end
    
    % Add the new value to the array of values
    allcoherences = [allcoherences newValue];
    ms = set(ms,'currentCoherence',newValue);
    
end

ms = set(ms,'responses',allresponses,'coherences',allcoherences,'currentReversals',currentReversals,'reversalFlag',reversalFlag,'complete',complete,'stepSize',stepSize);


% Debugging items
display(['Reversals: ' num2str(get(ms,'currentReversals'))]);


