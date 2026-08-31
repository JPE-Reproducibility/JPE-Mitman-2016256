function out = impute_border_search(d)
% impute_border_search  Border-segment search-allocation imputation.
%
% Re-implementation (from the paper's model) of the routine that produces the
% imputed labor-market variables behind tab:Imputed_Results. For ONE border
% segment it solves for
%       gamma                  -- the Cobb-Douglas matching elasticity (one per
%                                 segment; output column alpha_c)
%       mu(t)   t=1..T          -- time-varying (effective) matching efficiency
%                                 mu_tilde (output column mu_t)
%       xA(t), xB(t)  t=1..T    -- fraction of each state's unemployed searching
%                                 in their OWN state (output column x)
% to fit the three observed relations, per period t:
%   (JFR A, paper eq. for phi^A)   phiA = xA*fA - (1-xA)*fB
%   (JFR B)                        phiB = xB*fB - (1-xB)*fA
%   (vacancy-filling-rate ratio)   qA/qB = (thetaB/thetaA)^gamma
% where, with observed (online) vacancies vA,vB and imputed searchers uA,uB,
%       thetaA = vA/uA,  thetaB = vB/uB,            (imputed tightness)
%       fA = mu*thetaA^(1-gamma),  fB = mu*thetaB^(1-gamma),   (job-finding)
% and the imputed number searching in each state is (paper eq:utilde):
%       uA = (utA + zeta*(pA-nA)).*xA + (1-xB).*(utB + zeta*(pB-nB))
%       uB = (utB + zeta*(pB-nB)).*xB + (1-xA).*(utA + zeta*(pA-nA))
% with ut* = observed unemployed by residence, n* = labor force, p* = population,
% zeta = 5/27 (Hall 2013; ratio of non-participant to unemployed job-finding).
% phiA, phiB and the qA/qB ratio are computed upstream from observed data
% (paper eq:JFR_Data for phi; q = 1-(v_{t+1}-v^new_{t+1})/v_t).
%
% NESTED ALGORITHM.  The within-period system is just-identified: 3 equations
% (phiA, phiB, q-ratio) in the 3 per-period unknowns (mu_t, xA_t, xB_t) for a
% GIVEN gamma. Crucially, gamma is NOT identified by adding the vacancy-filling
% LEVELS qA, qB as extra equations -- since f = q*theta identically, (qA,qB) are
% linearly dependent on (fA,fB) given the tightnesses, so they do not raise the
% rank of the system. Instead gamma is identified through the BOUNDS: we solve
%   OUTER:  minimize over gamma in [0.2, 0.8]  (Petrongolo-Pissarides range)
%   INNER:  given gamma, lsqnonlin for {mu_t, xA_t, xB_t} subject to
%           mu in (0,5], x in [0.5,0.99]
% For different gamma, different periods push x or mu against their bounds,
% leaving a residual that varies with gamma -- so the outer 1-D search pins an
% interior gamma (matching the historical alpha_c support [0.20,0.80]). The
% inner problem is square (3T residuals, 3T unknowns) with box bounds, so
% lsqnonlin uses trust-region-reflective and the bounds are respected; x>=0.5
% together with the positive search base s>0 guarantees uA,uB>0 (real tightness).
%
% INPUT struct d, all T-by-1 column vectors for the segment (sorted by time):
%   d.utA d.utB   observed unemployed by residence (counts)
%   d.nA  d.nB    labor force (counts)
%   d.pA  d.pB    population (counts; total population popestimate)
%   d.vA  d.vB    observed (online) vacancies
%   d.phiA d.phiB observed job-finding rates (eq:JFR_Data)
%   d.qratio      observed qA/qB (vacancy-filling-rate ratio)
%   d.zeta        optional scalar; default 5/27
%
% OUTPUT struct out: gamma (->alpha_c), mu (->mu_t), xA/xB (->x), uA/uB
%   (->utilde), thetaA/thetaB (->thet_corr), fA/fB (->f), resnorm (->val).
%
% The driver (loop over border segments, assemble inputs, write the per-segment
% output in the ImputedDataBorder schema) and validation are handled separately.

if ~isfield(d,'zeta') || isempty(d.zeta)
    d.zeta = 5/27;
end
T = numel(d.utA);

% Searchers available in each state (the "+zeta*(p-n)" non-participant margin).
sA = d.utA + d.zeta*(d.pA - d.nA);
sB = d.utB + d.zeta*(d.pB - d.nB);

% Inner-problem packing/bounds: th = [mu(1..T); xA(1..T); xB(1..T)].
imu = 1:T;
ixA = T + (1:T);
ixB = 2*T + (1:T);
th0 = [ones(T,1); 0.75*ones(T,1); 0.75*ones(T,1)];
lb  = [1e-6*ones(T,1); 0.50*ones(T,1); 0.50*ones(T,1)];
ub  = [5*ones(T,1);    0.99*ones(T,1); 0.99*ones(T,1)];

% Serial finite differences: the residual is cheap (vector ops over T~26), so a
% parpool's IPC dwarfs the compute. Square + bounded -> trust-region-reflective.
inneropts = optimoptions('lsqnonlin','Display','off','UseParallel',false, ...
                    'MaxFunctionEvaluations',1e4,'MaxIterations',500, ...
                    'FunctionTolerance',1e-12,'StepTolerance',1e-12);

% OUTER: 1-D search for gamma over the Petrongolo-Pissarides range.
outeropts = optimset('Display','off','TolX',1e-5);
gamma = fminbnd(@(g) inner_resnorm(g), 0.2, 0.8, outeropts);

% Re-solve the inner problem at the optimal gamma and unpack.
[resnorm, th] = inner_solve(gamma);
[g, mu, xA, xB, uA, uB, thA, thB, fA, fB] = unpack(th, gamma);
out = struct('gamma',g,'mu',mu,'xA',xA,'xB',xB,'uA',uA,'uB',uB, ...
             'thetaA',thA,'thetaB',thB,'fA',fA,'fB',fB,'resnorm',resnorm);

    function rn = inner_resnorm(g)
        [rn, ~] = inner_solve(g);
    end

    function [rn, th] = inner_solve(g)
        [th, rn] = lsqnonlin(@(t) resid(t, g), th0, lb, ub, inneropts);
    end

    function r = resid(th, g)
        mu = th(imu);
        xA = th(ixA);
        xB = th(ixB);
        uA = sA.*xA + (1-xB).*sB;
        uB = sB.*xB + (1-xA).*sA;
        thA = d.vA ./ uA;
        thB = d.vB ./ uB;
        fA  = mu .* thA.^(1-g);
        fB  = mu .* thB.^(1-g);
        r1 = d.phiA - (xA.*fA - (1-xA).*fB);
        r2 = d.phiB - (xB.*fB - (1-xB).*fA);
        r3 = d.qratio - (thB./thA).^g;
        r  = [r1; r2; r3];
    end

    function [g, mu, xA, xB, uA, uB, thA, thB, fA, fB] = unpack(th, g)
        mu = th(imu);
        xA = th(ixA);
        xB = th(ixB);
        uA = sA.*xA + (1-xB).*sB;
        uB = sB.*xB + (1-xA).*sA;
        thA = d.vA ./ uA;
        thB = d.vB ./ uB;
        fA  = mu .* thA.^(1-g);
        fB  = mu .* thB.^(1-g);
    end
end
