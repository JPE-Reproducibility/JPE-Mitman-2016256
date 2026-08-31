clear; format short;


%%
% QWIWStayers / Job Stayers wage front-end. Standalone counterpart to
% Factor_FrontEnd_QWIW.m (New Hires / All Workers), kept separate so the
% stayers sample never affects those regressions.
%
% Counterpart Stata exporter: code/exporters/OutputDataSetsUIMacro_QWIWStayers.do.
% Reproduces the Sept-2018 stayers recipe (decoded from the QWIWages2 run that
% produced the published numbers -- see the exporter header):
%   LHS = did_logqwi_wage2f_3 (raw) / did_logqwi_wage2f_t_3 (with tax) -- the
%   THREE-quarter-accumulated stayer-wage double difference -- regressed on the
%   THREE-quarter-accumulated benefit ben_3, p=1, drop=60, trunc=8, seed 15.
%
% Published stayers result: raw 0.023187, tax 0.023711, both 4 factors,
% R^2=0.521, N=25,940 (tab:app_Benefits_on_Wages).
%
% QBLS column mapping (set in OutputDataSetsUIMacro_QWIWStayers.do):
%   col 4   ben_3                  (3-qtr accumulated benefit; RHS at p=1)
%   col 5   did_logqwi_wage2f_3    Job Stayers, raw
%   col 6   did_logqwi_wage2f_t_3  Job Stayers, with tax
%   col 7   ben_2  | col 8 Lben1 | col 9 Lben2 | col 10 kweeks
%       (extra RHS candidates -- set nowks=1/exo_var_1 or p>1/exorange to try)
config;   % sets InputBaseDir, SaveDir, paths (run from code/matlab)
FactorModelCodeDir=pwd;


seed=15; %Set the seed

quarterly=1;

factors_to_run_base=[6 5 4 3 2 1];

nowks=0;
perfect_foresight=0;

%%

rand('seed',seed) %#ok<RAND>

if(quarterly==1)
    T=100;
else
    T=276;
end

p = 1;
splitwks = 0;
nowks = 0;
drop = 60;
trunc = 8;
placebo=0;
fixedloadings=0;
inc_constant = 0;
exo_var_1=1;
exo_var_2=1;
exo_var_3=1;
exo_var_4=1;
exo_var_5=1;
exorange=4;   % harmless placeholder (never consumed because p=1)

%% Loop over the two stayers columns.
SepMethod = 'QWIWStayers';
N = importdata([InputBaseDir SepMethod '/N.txt']);

% var_ind 5 = wage2f_3 (raw), 6 = wage2f_t_3 (tax); RHS = col 4 = ben_3.
col_var_ind = [5 6];
col_label   = {'stayers_raw','stayers_tax'};

stayers_results = zeros(2, 8);

for c=1:2
    var_ind = col_var_ind(c);
    varoi   = ['qwiw_' col_label{c}]; %#ok<*NASGU>
    p=1;
    nowks=0;
    drop=60;
    trunc=8;
    T=100;

    RunFactorModel;

    numfactors=factors_to_run(optfac);
    nrun=200;          %number of bootstrap replications
    clusterborder=1;
    T=100;
    RunPValsFactor_newbs_v4_nowks;

    % Standard 8-row _se layout for the benefit coefficient:
    %   coef | %>0 | 2.5pct | 97.5pct | std | N.factors | R^2 | Nobs
    stayers_results(c,:) = [
        beta_est(1,1), ...
        sum(sbeta_est(:,1)>0)/nrun*100, ...
        sbeta_est(round(0.025*nrun),1), ...
        sbeta_est(round(0.975*nrun),1), ...
        std(sbeta_est(:,1)), ...
        numfactors, ...
        (1-ssr/ssy), ...
        Nobs ];

    disp(['QWIWStayers ' col_label{c} ' done; beta_b=' num2str(beta_est(1,1)) ...
          ', numfactors=' num2str(numfactors) ', Nobs=' num2str(Nobs)]);
end

%% Save: row 1 = stayers raw, row 2 = stayers with tax; eight statistics each.
cd(SaveDir)
dlmwrite('Benefits_on_Wages_Stayers.csv', stayers_results);
cd(FactorModelCodeDir)
