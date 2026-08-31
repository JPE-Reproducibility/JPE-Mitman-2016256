function [yyt pphit upt]=eq_resid_state_ben_iter(yy,pphi,up,xi,h,chi,tau,eps,b,PiA,A,anum,unum,U)

%del = 0.0081;         % Exogenous separation rate
bet = .99^(1/12);     % discount factor
k=.584;
del=0.0081;
yyt=zeros(anum,unum);
upt=yyt;
pphit=yyt;
for uu=1:unum
    l=1-U(uu);
    for aa=1:anum
        upp=up(aa,uu);
        [inds vals]=basefun(upp,U,unum);
        yp=squeeze(PiA(aa,:)*(squeeze(yy(:,inds(1)))*vals(1)+squeeze(yy(:,inds(2)))*vals(2)));
        
        Phip=squeeze(PiA(aa,:)*(squeeze(pphi(:,inds(1)))*vals(1)+squeeze(pphi(:,inds(2)))*vals(2)));
        q=k./(bet*(1-xi)*yp);
        t=qinv(max(min(q,0.99),0.01),chi);
        f=t.*q;
        yyt(aa,uu)=A(aa)-h-b-tau+bet*(1-del-xi*f).*yp+bet*(1-del-f).*eps(uu).*Phip;
        pphit(aa,uu)=b+bet*(1-f).*(1-eps(uu)).*Phip;

        lp=(1-del)*l+f*U(uu);
        uupt=1-lp;
        upt(aa,uu)=uupt;
    end
end
