% Part of PTBStaircase set.  Does NOT belong in the ~PTBStaircase
% directory.
% Robin Held 
% Banks Lab
% UC Berkeley

% Input a cell composed of staircases and randomly select one that has not
% been completed.  If all have been completed, return 0.

function [scell] = initializeStaircase(scell)
    

	randomval=rand*scell.initialValue_random_range;
	random_offset= floor(randomval/scell.stepLimit)*scell.stepLimit;
    
    scell.currentValue = (scell.initialValue+(2*round(rand)-1)*random_offset) ;  %If its the first value, then this will return the initial value plus or minus some offset within initialValue_random_range, but rounded to the nearest minimum step unit
    
    %Uncomment these lines for optimizer exp (comparison)
  	scell.currentValue = scell.MCS_stimuli(randi(length(scell.MCS_stimuli)));
    scell.initialized='yes';
	
	scell.complete=0;
	scell.lastDirection=0;
	scell.currentReversals=0;
