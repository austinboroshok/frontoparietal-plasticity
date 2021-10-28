function dat = fit_psycho_functions(dat)
%
%
% FIT PSYCHOMETRIC FUNCTIONS
for d = 1:length(dat.directions)            % get number of conditions
    
    
    [uEst,varEst] = FitCumNormYN(dat.pfitM(d).coherences,dat.pfitM(d).num_yes,dat.pfitM(d).num_no);
    
    dat.mu(d) = uEst;
    dat.var(d) = varEst;
end