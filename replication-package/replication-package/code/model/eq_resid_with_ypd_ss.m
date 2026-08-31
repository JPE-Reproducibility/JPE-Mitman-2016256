function resid=eq_resid_with_ypd_ss(tp,xi,h,chi,eps,b,z)

%del = 0.0081;         % Exogenous separation rate
bet = .99^(1/12);     % discount factor
k=.584;
del=0.0081;
y=tp(1);
Phi=tp(2);
q=k./(bet*(1-xi)*y);
t=qinv(max(min(q,0.999),0.001),chi);
f=t.*q;
resid(1)=y-(z-h-b+bet*(1-del-xi*f)*y+bet*(1-del-f).*eps.*Phi);
resid(2)=Phi-b/(1-bet*(1-f).*(1-eps));
