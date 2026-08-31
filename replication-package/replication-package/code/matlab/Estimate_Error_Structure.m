clear; format short;

%%
% §monte_carlo (~L1547): the residual error-structure inputs that feed the Monte-Carlo
% robustness experiments (tab:Monte-Carlo-Results). Estimated from the residuals
% epsilon_pt of the BENCHMARK interactive-fixed-effects regression (Table 1 Col 1:
% quasi-diff unemployment on benefits, r=2 factors, drop=60/trunc=8 = 2005q1-2012q4):
%   overall unconditional time-series variance of epsilon  (paper 0.0008641)
%   serial (AR1) correlation rho^t                          (paper 0.08, s.e. 0.02)
%   spatial correlation rho^s                               (paper 0.56, s.e. 0.005)
% where epsilon_pt = sqrt(rho^s) eps^b_pt + sqrt(1-rho^s) eps^i_pt (eps^b common to a
% state-border segment, eps^i idiosyncratic), each AR(1) in rho^t.
%
% Condensed from the original Monte Carlo error-structure estimation (the
% FrontEnd_..._ObtainFactorsResids residual dump + analyze_output.do moment estimation).
% Runs the kit's standard RunFactorModel with factors_to_run_base=[2] so the loop ends
% at r=2 and `residual`/`M` hold the benchmark r=2 residual; then computes the moments.
%
% This script computes three moments from the benchmark r=2 residual: the overall
% time-series variance of epsilon, the pooled AR(1) serial correlation rho^t, and the
% within-segment cross-pair spatial correlation rho^s. The published Monte-Carlo error
% structure uses variance 0.008641, rho^t 0.08, and rho^s 0.56.
%
% Output SaveDir/MonteCarlo_Inputs.csv: rows [label,value,published].

config;   % sets InputBaseDir, SaveDir, paths (run from code/matlab)
FactorModelCodeDir=pwd;

seed=15; quarterly=1; factors_to_run_base=[2]; perfect_foresight=0;
rand('seed',seed) %#ok<RAND>
T=100; p=1; splitwks=0; nowks=0; placebo=0; fixedloadings=0; inc_constant=0;
exo_var_1=1; exo_var_2=1; exo_var_3=1; exo_var_4=1; exo_var_5=1; exorange=1;

SepMethod='Bench';
N = importdata([InputBaseDir SepMethod '/N.txt']);
var_ind=5; drop=60; trunc=8; T=100; varoi='mc_resid';
RunFactorModel;                       % residual / M now hold the r=2 benchmark fit

R = residual; Mm = M; [T2,Ncol] = size(R);
ok = (Mm==0);
v  = R(ok);

% (1) overall variance
variance = var(v);

% (2) serial correlation rho^t: pooled AR(1) slope, regress R(t,i) on R(t-1,i)
x=[]; y=[];
for i=1:Ncol
    for t=2:T2
        if ok(t,i) && ok(t-1,i)
            y(end+1,1)=R(t,i); x(end+1,1)=R(t-1,i); %#ok<AGROW>
        end
    end
end
rho_t = sum((x-mean(x)).*(y-mean(y)))/sum((x-mean(x)).^2);

% (3) spatial correlation rho^s: pairs -> border segments, within-segment cross-pair corr
bc = importdata([InputBaseDir SepMethod '/bordersegment_cluster.txt']);
seg = zeros(Ncol,1);
for r=1:size(bc,1)
    if bc(r,2)<=Ncol, seg(bc(r,2))=bc(r,1); end
end
segs = unique(seg(seg>0));
cc=[];
for k=1:numel(segs)
    idx=find(seg==segs(k));
    for a=1:numel(idx)
        for b=a+1:numel(idx)
            m=ok(:,idx(a))&ok(:,idx(b));
            if sum(m)>=8, cc(end+1,1)=corr(R(m,idx(a)),R(m,idx(b))); end %#ok<AGROW>
        end
    end
end
rho_s = mean(cc);

fprintf('\n== Monte-Carlo error-structure inputs (benchmark r=2 residual) ==\n');
fprintf('  variance = %.7f   (published 0.008641)\n', variance);
fprintf('  rho^t    = %.4f    (published 0.08)\n', rho_t);
fprintf('  rho^s    = %.4f    (published 0.56)\n', rho_s);

cd(SaveDir)
fid=fopen('MonteCarlo_Inputs.csv','w');
fprintf(fid,'label,value,published\n');
fprintf(fid,'variance,%.8f,0.008641\n', variance);
fprintf(fid,'rho_t,%.5f,0.08\n', rho_t);
fprintf(fid,'rho_s,%.5f,0.56\n', rho_s);
fclose(fid);
cd(FactorModelCodeDir)
