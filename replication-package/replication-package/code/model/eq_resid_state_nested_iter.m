function [yt pt]=eq_resid_state_nested_iter(yy,pphi,xi,h,chi,tau,eps,b,Pi,znum,z,PiA,A,anum,unum,U,up,Arho)

%del = 0.0081;         % Exogenous separation rate
bet = .99^(1/12);     % discount factor
k=.584;
del=0.0081;
muu=0.5;
yt=zeros(znum,anum,unum);
pt=yt;
%Arho=1;
for uu=1:unum
    for aa=1:anum
        upp=up(aa,uu);
        [inds vals]=basefun(upp,U,unum);
        
        y=squeeze(yy(:,aa,uu));
        Phi=squeeze(pphi(:,aa,uu));
        yp=Pi*(squeeze(yy(:,:,inds(1)))*vals(1)+squeeze(yy(:,:,inds(2)))*vals(2))*PiA(aa,:)';
        Phip=Pi*(squeeze(pphi(:,:,inds(1)))*vals(1)+squeeze(pphi(:,:,inds(2)))*vals(2))*PiA(aa,:)';
        q=k./(bet*(1-xi)*yp);
%         Den Hann        
         t=qinv(max(min(q,0.99),0.01),chi);
        
        f=t.*q;
        yt(:,aa,uu)=(exp((1-Arho)*log(z)+Arho*log(A(aa)))-h-b-tau+bet*(1-del-xi*f).*yp+bet*(1-f).*eps(uu).*Phip);
        pt(:,aa,uu)=(b+bet*(1-f).*(1-eps(uu)).*Phip);

    
    end
end
