function outfile = output_setup(subjectname, filename)
%
% open xls file for writing results

% make directory to store session data
if ~exist(['../data/' subjectname],'dir');
    mkdir(['../data/' subjectname]);
end

outputname  = strrep(['../data/' subjectname '/' filename],'mat','csv');

outfile     = fopen(outputname, 'w');

fprintf(outfile,'Trial,RT,Duration\r\n');

%fprintf(outfile,'Trial,Sound,Response,RT (seconds)\r\n');