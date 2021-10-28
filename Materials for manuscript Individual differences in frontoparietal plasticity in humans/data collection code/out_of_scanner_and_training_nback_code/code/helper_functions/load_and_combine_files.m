function dat = load_and_combine_files(files,path,type)
%
%

    dat.nbacks          = [];
    dat.trials.nback    = [];
    dat.trials.resp         = [];
    dat.trials.respTime     = [];
    dat.trials.isCorrect    = [];

% load these fields from each selected file
if ~iscell(files)
    
    % just one file to be loaded
    load([path '/' files])
    
    if ~strcmp(dat.test_type,type)
        error('you loaded a posttest instead of a pretest');
    end
    
else
    
    % load each file
    for fii = 1:length(files)
        
        display(files(fii));
        tmp = load([path '/' files{fii}]);
        
        if ~strcmp(tmp.dat.test_type,type)
            error('you loaded a pretest instead of a posttest');
        end
        
    dat.nbacks          = [];
    dat.trials.nback    = [];
    dat.trials.resp         = [];
    dat.trials.respTime     = [];
    dat.trials.isCorrect    = [];
        
    end
    
    dat.nbacks= unique(nbacks);

    
    dat.test_type = tmp.dat.test_type;

    
end