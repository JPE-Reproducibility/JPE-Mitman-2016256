function [coef1,avgt,avgf,avgv,avgu,coefw]=nested_state_county_simulate(Yvec,Yvec2,Avec,Avec2,cnum,A,PiA,U,anum,unum,up,eps_base,yp,pp,Pi,Z,znum,xi,h,chi,b,Arho,yp_state,outname,skip)
ynum=length(Yvec(1,:));
k=.584;
bet=.99^(1/12);
del=0.0081;
tau=0;
z=Z;
yy=yp;
pphi=pp;
%Arho=1;
muu=0.5;

ybase=zeros(znum,anum,unum);
qbase=zeros(znum,anum,unum);
tbase=zeros(znum,anum,unum);
fbase=zeros(znum,anum,unum);
wbase=zeros(znum,anum,unum);
pbase=zeros(znum,anum,unum);




for uu=1:unum
    for aa=1:anum

        upp=up(aa,uu);
        [inds vals]=basefun(upp,U,unum);
        yp_s=squeeze(PiA(aa,:)*(squeeze(yp_state(:,inds(1)))*vals(1)+squeeze(yp_state(:,inds(2)))*vals(2)));
        q_s=k./(bet*(1-xi)*yp_s);
        t_s=qinv(max(min(q_s,0.99),0.01),chi);
        
        v_s(aa,uu)=t_s*U(uu);
        
        y=squeeze(yy(:,aa,uu));
        yp=Pi*(squeeze(yy(:,:,inds(1)))*vals(1)+squeeze(yy(:,:,inds(2)))*vals(2))*PiA(aa,:)';
        
        
        q=k./(bet*(1-xi)*yp);
        t=qinv(q,chi);
        %t=(q/muu).^(1/(chi-1));

        
        f=t.*q;
        JJ=(1-xi)*y;
        w=exp((1-Arho)*log(z)+Arho*log(A(aa)))-tau+bet*(1-del)*(1-xi)*yp-JJ;


        ybase(:,aa,uu)=y;
        qbase(:,aa,uu)=q;
        tbase(:,aa,uu)=t;
        fbase(:,aa,uu)=f;
        wbase(:,aa,uu)=w;
        pbase(:,aa,uu)=squeeze(pphi(:,aa,uu));

    end
end
%ynum2=ynum;
%ynum=ynum-12;
% Avec2(13:end)=Avec(1:end-12);
% Avec2(1:end)=21;
q=qbase;
t=tbase;
f=fbase;
w=wbase;
phi=pbase;
eps=eps_base;
% skip=1;
% timelength=length(Yvec(1,:))/4-(skip-1)/4;
timelength=length(Yvec(1,:))/12-(skip-1)/12;
% keyboard
LvecA=zeros(ynum,1)';
tvecA=zeros(ynum,1)';
zvecA=zeros(ynum,1)';
fvecA=zeros(ynum,1)';
evecA=zeros(ynum,1)';
wvecA=zeros(ynum,1)';
JvecA=zeros(ynum,1)';
JvecB=zeros(ynum,1)';
UvecA=zeros(ynum,1)';
UvecB=zeros(ynum,1)';
AvecA=zeros(ynum,1)';
AvecB=zeros(ynum,1)';
Dvec=zeros(ynum,1)';
pvec=zeros(ynum,1)';
qvecA=zeros(ynum,1)';
qvecB=zeros(ynum,1)';
VvecA=zeros(ynum,1)';
VvecB=zeros(ynum,1)';


tmA=zeros(cnum,timelength);
tmB=zeros(cnum,timelength);
fmA=zeros(cnum,timelength);
fmB=zeros(cnum,timelength);
zmA=zeros(cnum,timelength);
zmB=zeros(cnum,timelength);
umA=zeros(cnum,timelength);
umB=zeros(cnum,timelength);
emA=zeros(cnum,timelength);
emB=zeros(cnum,timelength);
vmA=zeros(cnum,timelength);
vmB=zeros(cnum,timelength);
JmA=zeros(cnum,timelength);
JmB=zeros(cnum,timelength);
UmA=zeros(cnum,timelength);
UmB=zeros(cnum,timelength);
AmA=zeros(cnum,timelength);
AmB=zeros(cnum,timelength);
piA=zeros(cnum,timelength);
piB=zeros(cnum,timelength);
pmA=zeros(cnum,timelength);
pmB=zeros(cnum,timelength);
dmA=zeros(cnum,timelength);
dmB=zeros(cnum,timelength);
qmA=zeros(cnum,timelength);
qmB=zeros(cnum,timelength);

VmA=zeros(cnum,timelength);
VmB=zeros(cnum,timelength);

pairid=zeros(cnum,timelength);
time=zeros(cnum,timelength);



for counties=1:cnum
    yseq=Yvec(counties,:);
    aseq=Avec(counties,:);
    %aseq=4*ones(1,500);
    L0=.942;
    D0=(1-L0);
    Lpr=L0;
    Dpr=D0;
    U0=exp(-2.75);
    Upr=U0;
    %welfare=0;
    for N=1:ynum
        L0=Lpr;
        D0=Dpr;
        U0=Upr;
        LvecA(N)=Lpr;
        zz=yseq(N);
        aa=aseq(N);
        [inds vals]=basefun(U0,U,unum);
        VvecA(N)=v_s(aa,inds)*vals';

        
        Upr=up(aa,inds)*vals';
        
        [inds vals]=basefun(Upr,U,unum);
        
        
        
        tt=vals(1)*t(zz,aa,inds(1))+vals(2)*t(zz,aa,inds(2));
        ff=vals(1)*f(zz,aa,inds(1))+vals(2)*f(zz,aa,inds(2));
        qq=ff/tt;
        ww=vals(1)*w(zz,aa,inds(1))+vals(2)*w(zz,aa,inds(2));
        Dvec(N)=Dpr;
        pvec(N)=phi(zz,aa,inds(1))+vals(2)*t(zz,aa,inds(2));
        qvecA(N)=qq;

        Lpr=(1-del)*L0+ff*(1-L0);
        
        Dpr=del*L0+(1-ff)*D0;

        UvecA(N)=Upr;
        AvecA(N)=A(aa);

        zvecA(N)=z(zz);
        tvecA(N)=tt;
        fvecA(N)=ff;

        if(U0>=0.08)
            evecA(N)=1/46;
        elseif(U0>=0.06)
            evecA(N)=1/39;
        else
            evecA(N)=1/26;
        end
        
        
        wvecA(N)=ww;
        JvecA(N)=k/qq;
    end
    
    JmA(counties,:)=weektoquarter12(JvecA(skip:end));
    vvecA=tvecA.*(1-LvecA);

    tmA(counties,:)=weektoquarter12(tvecA(skip:end));
    fmA(counties,:)=weektoquarter12(fvecA(skip:end));
    vmA(counties,:)=weektoquarter12(vvecA(skip:end));
    emA(counties,:)=weektoquarter12(evecA(skip:end));
    umA(counties,:)=1-weektoquarter12(LvecA(skip:end));
    pairid(counties,:)=counties*ones(1,timelength);
    time(counties,:)=1:timelength;
    zmA(counties,:)=weektoquarter12(zvecA(skip:end));
    UmA(counties,:)=weektoquarter12(UvecA(skip:end));
    AmA(counties,:)=weektoquarter12(AvecA(skip:end));
    
    piA(counties,:)=weektoquarter12(zvecA(skip:end)-wvecA(skip:end));
    dmA(counties,:)=weektoquarter12(Dvec(skip:end));
    pmA(counties,:)=weektoquarter12(pvec(skip:end));
    qmA(counties,:)=weektoquarter12(qvecA(skip:end));
    VmA(counties,:)=weektoquarter12(VvecA(skip:end));
    
    

end




%Treatment


LvecB=zeros(ynum,1)';
tvecB=zeros(ynum,1)';
zvecB=zeros(ynum,1)';
fvecB=zeros(ynum,1)';
evecB=zeros(ynum,1)';
wvecB=zeros(ynum,1)';

for counties=1:cnum
    yseq=Yvec(counties,:);
    aseq=Avec2(counties,:);

    q=qbase;
    t=tbase;
    f=fbase;
    w=wbase;
    phi=pbase;
    eps=eps_base;

    
    
    L0=.942;
    D0=(1-L0);
    Lpr=L0;
    Dpr=D0;
    U0=exp(-2.75);
    Upr=U0;

    %welfare=0;
    zxtra=0;
    for N=1:ynum
      
        L0=Lpr;
        D0=Dpr;
        U0=Upr;
        LvecB(N)=Lpr;
        if(N>12)
            zz=yseq(N-12);
        else
            zz=21;
        end
        aa=aseq(N);
        [inds vals]=basefun(U0,U,unum);
        VvecB(N)=v_s(aa,inds)*vals';

        
        Upr=up(aa,inds)*vals';
        [inds vals]=basefun(Upr,U,unum);
        
         if(U0>=0.08)
            evecB(N)=1/46;
        elseif(U0>=0.06)
            evecB(N)=1/39;
        else
            evecB(N)=1/26;
        end
%    evecB(N)=eps_base(aa);

%         if(U0>=0.065)
%             evecB(N)=1/39;
%         else
%             evecB(N)=1/26;
%         end
        
        
        tt=vals(1)*t(zz,aa,inds(1))+vals(2)*t(zz,aa,inds(2));
        ff=vals(1)*f(zz,aa,inds(1))+vals(2)*f(zz,aa,inds(2));
        qq=ff/tt;
        ww=vals(1)*w(zz,aa,inds(1))+vals(2)*w(zz,aa,inds(2));
        Dvec(N)=Dpr;
        pvec(N)=phi(zz,aa,inds(1))+vals(2)*t(zz,aa,inds(2));
        qvecB(N)=qq;

        Lpr=(1-del)*L0+ff*(1-L0);
        %Lpr = 1 - (-0.5*log(evecB(N))-0.3*log(z(zz)));

        Dpr=del*L0+(1-ff)*D0;

        UvecB(N)=Upr;
        AvecB(N)=A(aa);
        zvecB(N)=z(zz);
        tvecB(N)=tt;
        fvecB(N)=ff;
        wvecB(N)=ww;
        JvecB(N)=k/qq;
    end
    JmB(counties,:)=weektoquarter12(JvecB(skip:end));
    vvecB=tvecB.*(1-LvecB);
    tmB(counties,:)=weektoquarter12(tvecB(skip:end));
    fmB(counties,:)=weektoquarter12(fvecB(skip:end));
    vmB(counties,:)=weektoquarter12(vvecB(skip:end));
    emB(counties,:)=weektoquarter12(evecB(skip:end));
    umB(counties,:)=1-weektoquarter12(LvecB(skip:end));
    zmB(counties,:)=weektoquarter12(zvecB(skip:end));
    UmB(counties,:)=weektoquarter12(UvecB(skip:end));
    AmB(counties,:)=weektoquarter12(AvecB(skip:end));
    
    piB(counties,:)=weektoquarter12(zvecB(skip:end)-wvecB(skip:end));
    dmB(counties,:)=weektoquarter12(Dvec(skip:end));
    pmB(counties,:)=weektoquarter12(pvec(skip:end));
    qmB(counties,:)=weektoquarter12(qvecB(skip:end));
    VmB(counties,:)=weektoquarter12(VvecB(skip:end));
    
    
    
end
%keyboard
Tout=[reshape(tmA',timelength*cnum,1);reshape(tmB',timelength*cnum,1)];
Fout=[reshape(fmA',timelength*cnum,1);reshape(fmB',timelength*cnum,1)];
Vout=[reshape(vmA',timelength*cnum,1);reshape(vmB',timelength*cnum,1)];
Eout=round(1./[reshape(emA',timelength*cnum,1);reshape(emB',timelength*cnum,1)]);
Uout=[reshape(umA',timelength*cnum,1);reshape(umB',timelength*cnum,1)];
Time=[reshape(time',timelength*cnum,1);reshape(time',timelength*cnum,1)];
Jout=[reshape(JmA',timelength*cnum,1);reshape(JmB',timelength*cnum,1)];
Zout=[reshape(zmA',timelength*cnum,1);reshape(zmB',timelength*cnum,1)];
AUout=[reshape(UmA',timelength*cnum,1);reshape(UmB',timelength*cnum,1)];
Aout=[reshape(AmA',timelength*cnum,1);reshape(AmB',timelength*cnum,1)];
Qout=[reshape(qmA',timelength*cnum,1);reshape(qmB',timelength*cnum,1)];
Pout=[reshape(piA',timelength*cnum,1);reshape(piB',timelength*cnum,1)];
Phiout=[reshape(pmA',timelength*cnum,1);reshape(pmB',timelength*cnum,1)];
Dout=[reshape(dmA',timelength*cnum,1);reshape(dmB',timelength*cnum,1)];
VVout=[reshape(VmA',timelength*cnum,1);reshape(VmB',timelength*cnum,1)];

%keyboard
county=[ones(timelength*cnum,1);2*ones(timelength*cnum,1)];
Pairid=[reshape(pairid',timelength*cnum,1);reshape(pairid',timelength*cnum,1)];
%keyboard
% dlmwrite('ModelResults-Nested-2-31Jul15.txt',[Pairid county Time Fout Tout Vout Eout Uout Jout Zout AUout Aout Qout Pout Phiout Dout VVout]);
dlmwrite(outname,[Pairid county Time Fout Tout Vout Eout Uout Jout Zout AUout Aout Qout Pout Phiout Dout VVout]);


% tvec=Uout;
% qvec=Vout;
avgt=mean(Tout);
avgf=mean(Fout);
avgv=mean(Vout);
avgu=mean(Uout);

diffu=log(umA')-log(umB');
diffw=log(emB')-log(emA');
% diffwages=
qdu=diffu(1:timelength-1,:)-0.9*.99*diffu(2:timelength,:);

% bb=regress(qdu,[ones(size(qdu)), diffw(1:timelength-1,1)]);
coef1=0; %bb(2);



% difft=log(tmA')-log(tmB');
% qdt=difft(1:timelength-1)-0.9*.99*difft(2:timelength);
% bb=regress(qdt,[ones(timelength-1,1), diffw(1:timelength-1,1)]);
% 
% diffv=log(vmA')-log(vmB');
% qdv=diffv(1:timelength-1)-0.9*.99*diffv(2:timelength);
% bb=regress(qdv,[ones(timelength-1,1), diffw(1:timelength-1,1)]);








