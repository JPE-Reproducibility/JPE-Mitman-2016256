clear; format short;


%%
% QWIW / wage front-end. Produces paper tab:Benefits_on_Wages (main text,
% All-Workers columns) and tab:app_Benefits_on_Wages (Job Stayers / New Hires /
% All Workers, each raw and with the UI payroll-tax adjustment).
%
% Counterpart Stata exporter: code/exporters/OutputDataSetsUIMacro_QWIW.do.
% Single balanced QBLS set; each wage LHS recovers its own observation count
% from RunFactorModel's NaN mask. The benefit regressor (double-differenced
% weeks, ben_1) sits at col 4; the six wage LHS at cols 5..10. Spec is p=1
% (benefit only, no extra control) so each column reports a single coefficient,
% matching the published tables.
%
% QBLS column mapping (set in OutputDataSetsUIMacro_QWIW.do):
%   col 4   ben_1                  (double-differenced benefit weeks; RHS)
%   col 5   did_logqwi_wage2f_0    Job Stayers, raw
%   col 6   did_logqwi_wage2f_t_0  Job Stayers, with tax
%   col 7   kqwinew                New Hires, raw
%   col 8   kqwinew_t              New Hires, with tax
%   col 9   kqwitot                All Workers, raw
%   col 10  kqwitot_t              All Workers, with tax
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

%% Loop over the six wage columns.
SepMethod = 'QWIW';
N = importdata([InputBaseDir SepMethod '/N.txt']);

% Column order matches tab:app_Benefits_on_Wages:
%   1 Stayers raw | 2 Stayers tax | 3 New raw | 4 New tax | 5 All raw | 6 All tax
col_var_ind = [5 6 7 8];
col_label   = {'newhire_raw','newhire_tax','all_raw','all_tax'};

wage_results = zeros(length(col_var_ind), 8);

for c=1:length(col_var_ind)
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
    wage_results(c,:) = [
        beta_est(1,1), ...
        sum(sbeta_est(:,1)>0)/nrun*100, ...
        sbeta_est(round(0.025*nrun),1), ...
        sbeta_est(round(0.975*nrun),1), ...
        std(sbeta_est(:,1)), ...
        numfactors, ...
        (1-ssr/ssy), ...
        Nobs ];

    disp(['QWIW ' col_label{c} ' done; beta_b=' num2str(beta_est(1,1)) ...
          ', numfactors=' num2str(numfactors) ', Nobs=' num2str(Nobs)]);
end

%% Save: one row per column, eight statistics each.
cd(SaveDir)
dlmwrite('Benefits_on_Wages.csv', wage_results);
cd(FactorModelCodeDir)
