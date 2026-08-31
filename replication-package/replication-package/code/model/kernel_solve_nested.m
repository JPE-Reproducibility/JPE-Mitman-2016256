%% Solve for nested solution
% Solve for state level economy
unum=16;
U=linspace(0.04,0.12,unum);

rho3 = .9895;      % AR(1) paramter
sigma3 = .0034;    % standard deviation of shocks
lambda3 = 2;     % Tauchen coverage parameter
z_mu3 = 0;       % Mean shock value
anum = 21;      % Number of discrete tauchen values
[A PiA] = tauchen(z_mu3,sigma3,rho3,lambda3,anum);
A=exp(A);
% xi=0.0982;
% h=0.6124;
% chi=0.4012;
b=0.4;
k=.584;
bet=.99^(1/12);
del=0.0081;
tau=0;
% Benefit-duration schedule (weeks of eligibility, as 1/weeks), triggered by the
% state unemployment rate U: 26 wks normally, 39 wks when u>6%, 46 wks when u>8%.
% (The 39-wk trigger is set at 6.0% here, the value that reproduces the published
%  calibration moments.)
% A PERMANENT extension of the whole schedule by `benefit_offset` weeks (e.g. +10 for
% the Table-valid true-permanent-effect experiment) is applied by setting the variable
% `benefit_offset` in the workspace before calling this script. Default 0 (baseline).
if ~exist('benefit_offset','var'); benefit_offset=0; end
eps_base = ones(unum,1)/(26+benefit_offset);
for i=1:unum
    if U(i)>0.08
        eps_base(i)=1/(46+benefit_offset);
    elseif U(i)>0.06
        eps_base(i)=1/(39+benefit_offset);
    end
end


yyt=2*repmat(linspace(0.8,1.2,anum)',1,unum);
pphit=3*repmat(linspace(0.8,1.2,anum)',1,unum);
upt=repmat(U,anum,1);

err=1;
upsilon=0.85;

% load IniGuess
% 
% yyt=yg1;
% pphit=pg1;
% upt=ug1;
% A=zval;
% PiA=zprob;



while(err > 1e-6)
    
   [yp pp up]=eq_resid_state_ben_iter(yyt,pphit,upt,xi,h,chi,tau,eps_base,b,PiA,A,anum,unum,U);
   yerr=squeeze(max(max(abs(yp-yyt)))); 
   perr=squeeze(max(max(abs(pp-pphit))));
   uerr=squeeze(max(max(abs(up-upt))));
%    disp([max(max(yp)) min(min0.(yp))]) 
%    disp([yerr perr uerr])
    err=max(yerr(1),max(perr(1),uerr(1)));
   yyt=upsilon*yp+(1-upsilon)*yyt;
   pphit=upsilon*pp+(1-upsilon)*pphit;
   upt=upsilon*up+(1-upsilon)*upt;
    
end
yp_state = yp;
%%

rho = .9895;      % AR(1) paramter
sigma = .0034;    % standard deviation of shocks
lambda = 2;     % Tauchen coverage parameter
z_mu = 0;       % Mean shock value
znum = 21;      % Number of discrete tauchen values
[Z Pi] = tauchen(z_mu,sigma,rho,lambda,znum);
%[Z Pi] = tauchenhussey(znum,z_mu,rho,sigma,sigma/sqrt(1-rho^2));
P2 = (Pi'-eye(znum));
P2(znum,:)=ones(1,znum);
Pi0 = P2^(-1) * [zeros(znum-1,1); 1];
Z=exp(Z);


yyt=reshape(repmat(1.5*linspace(0.9,1.1,znum)',unum*anum,1),znum,anum,unum);
pphit=reshape(repmat(3*linspace(1.1,0.9,znum)',anum*unum,1),znum,anum,unum);
options=optimset('Display','iter');

upsilon=0.85;
err=1;



while(err > 1e-6)

    [yp pp]=eq_resid_state_nested_iter(yyt,pphit,xi,h,chi,tau,eps_base,b,Pi,znum,Z,PiA,A,anum,unum,U,up,Arho);

    yerr=squeeze(max(max(max(abs(yp-yyt))))); 
    perr=squeeze(max(max(max(abs(pp-pphit)))));
%     disp([yerr perr]);
    err=max(yerr(1),perr(1));
    yyt=upsilon*yp+(1-upsilon)*yyt;
    pphit=upsilon*pp+(1-upsilon)*pphit;

end






