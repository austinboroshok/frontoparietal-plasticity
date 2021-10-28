% Mostly written by Bjorn Vlaskamp
function a = set(a,varargin)

property_argin = varargin;

while length(property_argin) >= 2,
    
    prop = property_argin{1};
    val = property_argin{2};
    property_argin = property_argin(3:end);
    
    switch prop
        
        case 'currentCoherence'
            a.currentCoherence = val;
        case 'direction'
            a.direction = val;
        case 'stepSize';
            a.stepSize = val;
        case 'maxReversals'
            a.maxReversals = val;
        case 'maxTrials'
            a.maxTrials = val;
        case 'currentReversals'
            a.currentReversals = val;
        case 'reversalFlag'
            a.reversalFlag = val;
        case 'complete'
            a.complete = val;
        case 'responses'
            a.responses = val;
        case 'coherences'
            a.coherences = val;
        case 'stepLimit'
            a.stepLimit = val;
        case 'maxCoherence'
            a.maxCoherence = val;
        case 'minCoherence'
            a.minCoherence = val;
        case 'altVariable'
            a.altVariable = val;
        case 'numUp'
            a.numUp = val;
        case 'numDown'
            a.numDown = val;
        case 'training'
            a.training=val;
            
            
            
        otherwise
            if ischar(prop),
                error(['Property ' prop ' does not exist in this class!'])
            else
                disp('Property: ')
                disp(prop)
                error('Property does not exist in this class!')
            end
            
    end
end
