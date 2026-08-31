clear; format short;


%%
config;   % sets InputBaseDir, SaveDir, paths (run from code/matlab)
FactorModelCodeDir=pwd;


seed=15; %Set the seed
drop=60;		% 0 to start in 2002, increase forward from then
trunc=0;   %number of observations to cut off the end


SepMethod='Industry';	% Pick differencing method
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
counteri=1;

%%
N = importdata([InputBaseDir SepMethod '/N.txt']);

%% Col 6: industry<=.0440707 subsample (similar industrial composition)
p=1;
varoi='qd1_unemp'; %#ok<*NASGU>
var_ind=5;
T=100;
drop=60;
trunc=8;
RunFactorModel;

numfactors=factors_to_run(optfac);
nrun=200;			%number of bootstrap replications
clusterborder=1;
T=100;
RunPValsFactor_newbs_v4_nowks;
distresults(:,counteri)=[beta_est(1,1); sum(sbeta_est(:,1)>0)/nrun*100; sbeta_est(round(0.025*nrun),1);sbeta_est(round(0.975*nrun),1);std(sbeta_est(:,1));numfactors;(1-ssr/ssy);Nobs];
counteri=counteri+1;

cd(SaveDir)
dlmwrite('SenseResultsIndustry.csv',distresults);
cd(FactorModelCodeDir)
