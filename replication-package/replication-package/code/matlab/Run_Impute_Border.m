clear; format short;

%%
% Run_Impute_Border  Driver for the border-segment search imputation.
%
% Reads the border-segment input built by code/analysis/Impute_Input.do, solves the
% search-allocation model for each border segment via impute_border_search.m,
% and writes Impute_Results.txt in the ImputedDataBorder column order so that
% code/analysis/Impute_to_Stata.do can insheet + save ImputedDataBorder.dta (the
% input consumed by code/analysis/Imputed_Results.do).
%
% *** VACANCY-GATED *** (the inputs embed the proprietary vacancy data).
% This reproduces the published results with the real data; the synthetic-vacancy
% path replaces Impute_Input.do's vacancy inputs.
%
% Impute_Input.txt columns (set in Impute_Input.do, tab-delimited, no header):
%   1 bordersegment  2 quarter_index  3 st_min(=A fipsstate)  4 st_max(=B fipsstate)
%   5 b_uA  6 b_uB  7 b_lA  8 b_lB  9 b_pA  10 b_pB  11 b_vacA  12 b_vacB
%   13 phiA  14 phiB  15 qratio
%
% Output Impute_Results.txt columns (= ImputedDataBorder schema):
%   bordersegment fipsstate year quarter f x thet_corr phi utilde meanx val mu_t alpha_c
% with two rows per (segment, quarter): the A side (fipsstate=st_min) and the
% B side (fipsstate=st_max).

config; IODir=[factor_csv filesep];

raw = importdata([IODir 'Impute_Input.txt']);
if isstruct(raw), M = raw.data; else, M = raw; end

segs = unique(M(:,1));
out  = [];

for si = 1:numel(segs)
    s   = segs(si);
    Q   = M(M(:,1)==s, :);
    [~, ord] = sort(Q(:,2));   % sort by quarter_index
    Q   = Q(ord, :);
    T   = size(Q,1);
    if T < 3, continue; end     % need a few periods to identify the system

    d = struct();
    d.utA = Q(:,5);  d.utB = Q(:,6);
    d.nA  = Q(:,7);  d.nB  = Q(:,8);
    d.pA  = Q(:,9);  d.pB  = Q(:,10);
    d.vA  = Q(:,11); d.vB  = Q(:,12);
    d.phiA = Q(:,13); d.phiB = Q(:,14);
    d.qratio = Q(:,15);

    r = impute_border_search(d);

    qi      = Q(:,2);
    year    = 2005 + floor((qi-1)/4);     % quarter_index = 4*(year-2005)+quarter
    quarter = mod(qi-1,4) + 1;
    stmin   = Q(1,3);  stmax = Q(1,4);
    meanxA  = mean(r.xA);  meanxB = mean(r.xB);

    % A side (fipsstate = st_min)
    Arows = [repmat(s,T,1), repmat(stmin,T,1), year, quarter, ...
             r.fA, r.xA, r.thetaA, d.phiA, r.uA, ...
             repmat(meanxA,T,1), repmat(r.resnorm,T,1), r.mu, repmat(r.gamma,T,1)];
    % B side (fipsstate = st_max)
    Brows = [repmat(s,T,1), repmat(stmax,T,1), year, quarter, ...
             r.fB, r.xB, r.thetaB, d.phiB, r.uB, ...
             repmat(meanxB,T,1), repmat(r.resnorm,T,1), r.mu, repmat(r.gamma,T,1)];

    out = [out; Arows; Brows]; %#ok<AGROW>

    disp(['segment ' num2str(s) ' (' num2str(si) '/' num2str(numel(segs)) ...
          '): gamma=' num2str(r.gamma) ', resnorm=' num2str(r.resnorm)]);
end

dlmwrite([IODir 'Impute_Results.txt'], out, 'precision', 10);
disp(['Wrote Impute_Results.txt: ' num2str(size(out,1)) ' rows.']);
