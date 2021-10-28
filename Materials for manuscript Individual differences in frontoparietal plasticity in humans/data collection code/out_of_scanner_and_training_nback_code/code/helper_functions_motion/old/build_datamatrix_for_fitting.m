function dat = build_datamatrix_for_fitting(dat)
%
%

% BUILD DATA MATRIX
for d = 1:length(dat.directions)            % get number of conditions
    
    % trial indices at this direction
    trial_inds  = dat.trials.direction == dat.directions(d);
    
    % coherence levels measured for this direction
    coherences  = unique(dat.trials.coherence(trial_inds)); % determine number of coherence levels
    
    % for each coherence level
    for c = 1:length(coherences)   
        
        coherence_inds      = dat.trials.coherence == coherences(c);                        % trial indices at this coherence
        num_yes             = sum(trial_inds & coherence_inds & dat.trials.response == 1);     % number of times observer responded "coherent"
        num_no              = sum(trial_inds & coherence_inds & dat.trials.response == 2);     % number of times observer responded "random"
        
        dat.pfitM(d).direction = dat.directions(d);
        dat.pfitM(d).coherences(c) = coherences(c);
        dat.pfitM(d).num_yes(c) = num_yes;
        dat.pfitM(d).num_no(c) = num_no;
        dat.pfitM(d).percent_yes(c) = num_yes/(num_no + num_yes);

    end
end