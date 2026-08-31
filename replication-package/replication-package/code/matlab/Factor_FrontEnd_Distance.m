clear; format short;


%%
% Effect_of_Distance front-end. Reads 8 subdirs of output/factor_inputs/ produced
% by OutputDataSetsUIMacro_Distance.do, runs the baseline qdk1 IFE for each,
% collects benefits coef + bootstrap p-value + # factors + # pairs + R^2 per
% column. Produces paper tab:Effect_of_Distance (8 numbered cols mapping to
% Dist20Lt / Dist20Gt / Dist30Lt / Dist30Gt / Dist40Lt / Dist40Gt / Dist50Lt /
% Dist50Gt).
config;   % sets InputBaseDir, SaveDir, paths (run from code/matlab)
FactorModelCodeDir=pwd;


seed=15; %Set the seed
drop=60;		% 0 to start in 2002, increase forward from then
trunc=0;   %number of observations to cut off the end


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
counteri=1;

% Paper column order for tab:Effect_of_Distance:
%   (1) dist<20  (2) dist>20  (3) dist<30  (4) dist>30
%   (5) dist<40  (6) dist>40  (7) dist<50  (8) dist>50
sep_methods = {'Dist20Lt','Dist20Gt','Dist30Lt','Dist30Gt','Dist40Lt','Dist40Gt','Dist50Lt','Dist50Gt'};

% Standard 8-row layout per column + an extra row 9 = pair count (from N.txt),
% which the paper reports as "N. of pairs" (not total observations).
distresults = zeros(9, length(sep_methods));

for iiii=1:length(sep_methods)
    SepMethod = sep_methods{iiii};
    N = importdata([InputBaseDir SepMethod '/N.txt']);
    npairs = N;

    p=1;
    exorange=1;
    varoi=['qd1_unemp_' SepMethod]; %#ok<*NASGU>
    var_ind=5;
    T=100;
    drop=60;
    trunc=8;
    RunFactorModel;

    numfactors=factors_to_run(optfac);
    nrun=200;
    clusterborder=1;
    T=100;
    RunPValsFactor_newbs_v4_nowks;

    distresults(:,iiii) = [
        beta_est(1,1);
        sum(sbeta_est(:,1)>0)/nrun*100;
        sbeta_est(round(0.025*nrun),1);
        sbeta_est(round(0.975*nrun),1);
        std(sbeta_est(:,1));
        numfactors;
        (1-ssr/ssy);
        Nobs;
        npairs ];

    disp(['Distance ' SepMethod ' done; beta=' num2str(beta_est(1,1)) ', npairs=' num2str(npairs) ', numfactors=' num2str(numfactors)]);
end

cd(SaveDir)
dlmwrite('SenseResultsDistance.csv', distresults);
cd(FactorModelCodeDir)
