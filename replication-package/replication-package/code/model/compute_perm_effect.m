function [val val2]=compute_perm_effect(xi,b,h,chi,z)
bet = .99^(1/12);     % discount factor
k=0.584;
del=0.0081;

ebase=26;
einc=10;
eps=1/ebase;
options=optimset('TolFun',1e-12,'Display','off');

%First Compute Permanent Effect
%z=1;

yp=fsolve(@(x) eq_resid_with_ypd_ss(x,xi,h,chi,eps,b,z),[1.5 0.02],options);
y(1)=yp(1);
q(1)=k./(bet*(1-xi)*y(1));
t(1)=qinv(q(1),chi);
f(1)=t(1).*q(1);
u(1)=1-f(1)/(f(1)+del);
v(1)=u(1)*t(1);
J(1)=(1-xi)*y(1);
w(1)=z+(bet*(1-del)-1)*J(1);
p(1)=z-w(1);
D(1)=del*(1-eps)*(1-u(1))/(1-(1-f(1))*(1-eps));
phi(1)=yp(2);

eps=1/(ebase+einc);

yp=fsolve(@(x) eq_resid_with_ypd_ss(x,xi,h,chi,eps,b,z),yp,options);
y(2)=yp(1);
q(2)=k./(bet*(1-xi)*y(2));
t(2)=qinv(q(2),chi);
f(2)=t(2).*q(2);
u(2)=1-f(2)/(f(2)+del);
v(2)=u(2)*t(2);
J(2)=(1-xi)*y(2);
w(2)=z+(bet*(1-del)-1)*J(2);
p(2)=z-w(2);
D(2)=del*(1-eps)*(1-u(2))/(1-(1-f(2))*(1-eps));
phi(2)=yp(2);




zzz=1;

val=[diff(log(u)) diff(log(t)) diff(log(v)) diff(log(1./q)) diff(log(w)) diff(log(p))];



