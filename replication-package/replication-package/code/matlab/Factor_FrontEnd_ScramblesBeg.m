clear; format short;


%%
% ScramblesBeg is the qdsbk1 counterpart of Factor_FrontEnd_Scrambles.m.
% Reads the same output/factor_inputs/Scramble{1..200}/ QBLS files (the exporter
% was extended to compute qdsbk1_logunemp_rate_laus per scramble and write
% it as col 8) and produces paper tab:Benefits_on_unemp_beg Cols 3 (baseline
% scrambled) and 4 (scrambled + State GDP per Worker).
%
% No per-scramble bootstrap; the dispersion across the 200 scrambles is the
% inference object, matching the qdk1 Scrambles convention.
%
% QBLS column contract per scramble (set in OutputDataSetsUIMacro_Scrambles.do):
%   col 4  diff_logmeanwks
%   col 5  qdk1_logunemp_rate_laus
%   col 6  diff_logprod_priv
%   col 7  diff_logprod_all              (Col 4 State-GDP control)
%   col 8  qdsbk1_logunemp_rate_laus     (LHS for the Beg variant)
config;   % sets InputBaseDir, SaveDir, paths (run from code/matlab)
FactorModelCodeDir=pwd;


seed=15; %Set the seed
drop=60;
trunc=0;


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
nscrambles = 200;
scramble_coefs = zeros(nscrambles, 3);

for iiii=1:nscrambles
    SepMethod = ['Scramble' int2str(iiii)];
    N = importdata([InputBaseDir SepMethod '/N.txt']);

    % Col 3: baseline (qdsbk1_logunemp_rate_laus on diff_logmeanwks, no controls)
    p=1;
    exorange=1;
    varoi=['qdsbk1_unemp_Scramble_' int2str(iiii)]; %#ok<*NASGU>
    var_ind=8;
    T=100;
    drop=60;
    trunc=8;
    RunFactorModel;
    scramble_coefs(iiii,1) = beta_est(optfac,1);

    % Col 4: + State GDP per Worker (diff_logprod_all at QBLS col 7)
    p=2;
    exorange=7;
    varoi=['qdsbk1_unemp_ScrambleProd_' int2str(iiii)]; %#ok<*NASGU>
    var_ind=8;
    T=100;
    drop=60;
    trunc=8;
    RunFactorModel;
    scramble_coefs(iiii,2) = beta_est(optfac,1);
    scramble_coefs(iiii,3) = beta_est(optfac,2);

    disp(['Scramble Beg ' int2str(iiii) ' of ' int2str(nscrambles) ' done; beta_b=' num2str(scramble_coefs(iiii,1)) ', beta_b_w_prod=' num2str(scramble_coefs(iiii,2))]);
end

%% Save the full distribution and a summary.
% scramble_coefs columns: [Col 3 benefits, Col 4 benefits, Col 4 prod control]
cd(SaveDir)
dlmwrite('Scrambles_Beg_coefs.csv', scramble_coefs);

scramble_summary = [
    mean(scramble_coefs);
    median(scramble_coefs);
    std(scramble_coefs);
    min(scramble_coefs);
    max(scramble_coefs);
    prctile(scramble_coefs, 2.5);
    prctile(scramble_coefs, 97.5)
];
dlmwrite('Scrambles_Beg_summary.csv', scramble_summary);
% Rows: [mean; median; std; min; max; 2.5 pct; 97.5 pct]
% Cols: [Col 3 benefits; Col 4 benefits; Col 4 prod control]

cd(FactorModelCodeDir)
