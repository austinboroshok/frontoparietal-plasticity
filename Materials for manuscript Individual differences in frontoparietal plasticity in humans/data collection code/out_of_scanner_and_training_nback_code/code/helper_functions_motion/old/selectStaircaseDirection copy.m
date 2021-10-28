% Part of PTBStaircase set.  Does NOT belong in the ~PTBStaircase
% directory.
% Robin Held 
% Banks Lab
% UC Berkeley

% Input a cell composed of staircases and randomly select one that has not
% been completed.  If all have been completed, return 0.

function [scnum] = selectStaircaseDirection(scell,direction)

    % Initial scnum setting will be replaced later
    scnum = -1;

    % Get the number of staircases
    sc_length = length(scell);
    
    % Get indices for this direction
    inds = [];
    for i = 1:sc_length
        
        if get(scell{i},'direction') == direction
            
            inds = [inds i];
               
        end
        
    end
    
    % Make sure at least one of the staircases for this direction is incomplete
    num_incomplete = 0;
    
    for i = 1:sc_length
        
        if ~get(scell{i},'complete') && get(scell{i},'direction') == direction
            
            num_incomplete = num_incomplete + 1;
               
        end
        
    end
    
    % select an incomplete staircase at random
    if num_incomplete > 0
        
        while scnum <= 0
            
            % Randomly select a staircase number
            scnum = ceil(rand * sc_length);
            
            % continue looking if staircase is empty or direction is wrong
            if get(scell{scnum},'complete') || get(scell{scnum},'direction') ~= direction
                scnum = 0;
            end
            
        end
        
    else
        
        % Report that all of the staircases for this direction are complete
        scnum = 0;
    end
    