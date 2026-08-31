% ==========================================================================
% config.m  --  single path configuration for the MATLAB stages.
% EDIT `root` below to this archive's location, then call `config` at the top
% of any front-end (run from the code/matlab directory). Defines the paths the
% factor-model front-ends use: InputBaseDir (per-pair QBLS, written by the Stata
% exporters) and SaveDir (result CSVs that make_tables.py reads).
% ==========================================================================

root        = fullfile(getenv('HOME'), 'JPE-replications', 'JPE-Mitman-2016256', 'replication-package', 'replication-package');
code        = fullfile(root,'code');
rawdata     = fullfile(root,'data','raw');
processed   = fullfile(root,'data','processed');
output      = fullfile(root,'output');
factor_inputs = fullfile(output,'factor_inputs');     % per-pair QBLS handoff (from exporters)
factor_csv  = fullfile(output,'factor_results');      % result CSVs (make_tables.py reads)
figures     = fullfile(output,'figures');             % figure PDFs (the paper's \graphicspath)
synthetic = fullfile(root,'synthetic-data');

% the front-ends consume these two:
InputBaseDir = [factor_inputs filesep];
SaveDir      = [factor_csv filesep];

% make the model/factor code findable
addpath(fullfile(code,'matlab'));
addpath(fullfile(code,'model'));
