clear; format short;


%%
config;   % sets InputBaseDir, SaveDir, paths (run from code/matlab)
FactorModelCodeDir=pwd;


seed=15; %Set the seed
drop=60;		% 0 to start in 2002, increase forward from then
trunc=0;   %number of observations to cut off the end


quarterly=1;		% 1 for quarterly, 0 for monthly

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
drop = 0;
trunc = 0;
placebo=0;
fixedloadings=0;
inc_constant = 0;
exo_var_1=1;
exo_var_2=1;
exo_var_3=1;
exo_var_4=1;
exo_var_5=1;
exorange=1;

%% Loop over the 200 scrambled-pair samples.
% Table 1 Col 3 (baseline scrambled) = mean of column 1 of scramble_coefs.
% Table 1 Col 4 (scrambled + State GDP per Worker control) = mean of column 2.
% Column 3 holds the coefficient on the State-GDP control itself.
%
% No per-scramble bootstrap: the distribution across scrambles is itself the
% inference object. Each scramble's RunFactorModel point estimate is collected.
%
% QBLS column contract per scramble (set in OutputDataSetsUIMacro_Scrambles.do):
%   col 4  diff_logmeanwks
%   col 5  qdk1_logunemp_rate_laus  (LHS, var_ind=5)
%   col 6  diff_logprod_priv
%   col 7  diff_logprod_all         ("State GDP per Worker" control for Col 4,
%                                    matching the Bench pairing's Col 2 setup)
nscrambles = 200;
scramble_coefs = zeros(nscrambles, 3);
% Per-scramble [N.factors, Obs, R^2] for Col 3 (baseline) and Col 4 (+prod), so the
% table can report the MEDIAN of each across scrambles:
%   cols 1-3 = Col 3 [nfac, nobs, R^2];  cols 4-6 = Col 4 [nfac, nobs, R^2]
scramble_meta = zeros(nscrambles, 6);

for iiii=1:nscrambles
    SepMethod = ['Scramble' int2str(iiii)];
    N = importdata([InputBaseDir SepMethod '/N.txt']);

    % Col 3: baseline (qdk1_logunemp_rate_laus on diff_logmeanwks, no controls)
    p=1;
    exorange=1;
    varoi=['qd1_unemp_Scramble_' int2str(iiii)]; %#ok<*NASGU>
    var_ind=5;
    T=100;
    drop=60;
    trunc=8;
    RunFactorModel;
    scramble_coefs(iiii,1) = beta_est(optfac,1);
    scramble_meta(iiii,1) = factors_to_run(optfac);
    scramble_meta(iiii,2) = Nobs;
    scramble_meta(iiii,3) = 1 - ssr/ssy;

    % Col 4: + State GDP per Worker (diff_logprod_all at QBLS col 7,
    % matching the Bench pairing's Col 2 control)
    p=2;
    exorange=7;
    varoi=['qd1_unemp_ScrambleProd_' int2str(iiii)]; %#ok<*NASGU>
    var_ind=5;
    T=100;
    drop=60;
    trunc=8;
    RunFactorModel;
    scramble_coefs(iiii,2) = beta_est(optfac,1);
    scramble_coefs(iiii,3) = beta_est(optfac,2);
    scramble_meta(iiii,4) = factors_to_run(optfac);
    scramble_meta(iiii,5) = Nobs;
    scramble_meta(iiii,6) = 1 - ssr/ssy;

    disp(['Scramble ' int2str(iiii) ' of ' int2str(nscrambles) ' done; beta_b=' num2str(scramble_coefs(iiii,1)) ', beta_b_w_prod=' num2str(scramble_coefs(iiii,2))]);
end

%% Save the full distribution and a summary
% scramble_coefs columns: [Col 3 benefits, Col 4 benefits, Col 4 prod control]
cd(SaveDir)
dlmwrite('Scrambles_coefs.csv', scramble_coefs);
dlmwrite('Scrambles_meta.csv', scramble_meta);
% Scrambles_meta.csv: 200 rows; cols [Col3 nfac, Col3 obs, Col3 R^2, Col4 nfac,
% Col4 obs, Col4 R^2]. make_tables.py reports the median of each across scrambles.

scramble_summary = [
    mean(scramble_coefs);
    median(scramble_coefs);
    std(scramble_coefs);
    min(scramble_coefs);
    max(scramble_coefs);
    prctile(scramble_coefs, 2.5);
    prctile(scramble_coefs, 97.5)
];
dlmwrite('Scrambles_summary.csv', scramble_summary);
% Rows of Scrambles_summary.csv: [mean; median; std; min; max; 2.5 pct; 97.5 pct]
% Cols:                          [Col 3 benefits; Col 4 benefits; Col 4 prod control]

cd(FactorModelCodeDir)
