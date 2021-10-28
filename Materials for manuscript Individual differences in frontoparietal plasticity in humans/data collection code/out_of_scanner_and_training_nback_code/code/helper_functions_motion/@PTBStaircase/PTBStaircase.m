% Part of PTBStaircase class.
%Staircase algorithm was started by Bjorn, modified by Robin and was
%heavily adapted by David
%
% Code heavily borrowed from quest2 examples provided by Bjorn Vlaskamp

% Class constructor function
function ms = mystaircase

% Staircase class constructor
ms.direction = [];
ms.currentCoherence = [];
ms.stepSize = [];
ms.maxCoherence = [];
ms.minCoherence = [];
ms.stepLimit = [];
ms.maxReversals = [];
ms.maxTrials = [];           % If there are this many trials, mark the staircase as complete
ms.currentReversals = 0;
ms.reversalFlag = [];
ms.altVariable = [];            % Some variable that is different for each staircase
ms.complete = 0;               % Is this staircase complete (max # of reversals met)
ms.responses = [];              % Vector containing each response
ms.coherences = [];             % Vector containing each stimulus value
ms.numUp = [];                  % numUp and numDown are used for staircases that are
ms.numDown = [];                % not 1-up/1-down.  
ms.training = [];               % Is this a training session?
                                
ms = class(ms,'PTBStaircase');