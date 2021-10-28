% Mostly written by Björn Vlaskamp.  Modified by Robin held
function [uit s] = get(s,varargin)

% SET Set asset properties and return the updated object
propertyArgIn = varargin;

while length(propertyArgIn) >= 1,
    
    prop = propertyArgIn{1};
    propertyArgIn = propertyArgIn(2:end);
    
    switch prop
        case 'complete',
            uit = s.complete;
        case 'direction'
            uit = s.direction;
            
        case 'currentValue',
            if isempty(s.currentValue)
                disp('*********************************************')
                disp('You have not initialized this staircase')
                disp('Make sure that you have run the initializeStaircase routine')
                disp('*********************************************')
                uit =NaN;
            else
                uit = s.currentValue;
            end
            
        case 'altVariable'
            uit = s.altVariable;
        case 'coherences'
            uit = s.coherences;
        case 'minCoherence'
            uit = s.minCoherence;
        case 'maxCoherence'
            uit = s.maxCoherence;
        case 'maxTrials'
            uit = s.maxTrials;
        case 'stepLimit'
            uit = s.stepLimit;
        case 'maxReversals'
            uit = s.maxReversals;
        case 'numUp'
            uit = s.numUp;
        case 'numDown'
            uit = s.numDown;
        case 'reversalFlag'
            uit = s.reversalFlag;
        case 'currentCoherence'
            uit = s.currentCoherence;
        case 'stepSize'
            uit = s.stepSize;
        case 'training'
            uit = s.training;
        case 'initialized'
            uit = s.initialized;
        case 'responses'
            uit = s.responses;
        case 'currentReversals'
            uit = s.currentReversals;
        otherwise
            error('Property does not exist')
    end
end
