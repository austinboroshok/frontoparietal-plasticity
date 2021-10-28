function [indices, targets] = generate_nback(nback,leng,num_syls)
%
% generate list of syllables with 3 or 4 targets

% randomly pick to have 3 or 4 targets
num_targets = randsample([3 4],1);

% generate a string with target number of ones
target_inds         = randi(leng-nback,1,num_targets);
targets             = zeros(1,leng);
targets(target_inds) = -1;

indices = zeros(1,leng);

for x = 1:length(targets)
    
    if targets(x) == 0 && indices(x) == 0
        
        indices(x) = randi(num_syls);
        
    elseif targets(x) == -1 && indices(x) == 0
        
        val = randi(num_syls);
        
        indices(x) = val;
        indices(x+nback) = val;
        
    end
    
end


