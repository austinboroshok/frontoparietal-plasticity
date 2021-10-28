function dat = load_and_combine_files(files,path,type)
%
%

dat.coherences = [];
dat.directions = [];
dat.trials.coherence = [];
dat.trials.direction = [];
dat.trials.resp = [];
dat.trials.isCorrect = [];

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
        
        dat.coherences          = [dat.coherences tmp.dat.coherences];
        dat.directions          = [dat.directions tmp.dat.directions];
        dat.trials.coherence    = [dat.trials.coherence tmp.dat.trials.coherence];
        dat.trials.direction    = [dat.trials.direction tmp.dat.trials.direction];
        dat.trials.resp         = [dat.trials.resp tmp.dat.trials.resp];
        dat.trials.isCorrect    = [dat.trials.isCorrect tmp.dat.trials.isCorrect];
        
    end
    
    dat.coherences = unique(dat.coherences);
    dat.directions = unique(dat.directions);
    
    dat.test_type = tmp.dat.test_type;
    dat.main_direction = tmp.dat.main_direction;
    
end

