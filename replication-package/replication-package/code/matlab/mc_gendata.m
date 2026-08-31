function Ysim = mc_gendata(bet, lam, Fb, Xb, borderid, params)
  [T2,N] = size(Xb); Nborder = max(borderid);
  rhoeps=params.rhoeps; sdeps=params.sdeps;
  rhoceps=params.rhoceps; sdceps=params.sdceps;
  errc=zeros(T2,N); erri=zeros(T2,N);
  tmp = sdceps*randn(1,Nborder)/sqrt(1-rhoceps^2);   errc(1,:)=tmp(borderid);
  erri(1,:) = sdeps/sqrt(1-rhoeps^2)*randn(1,N);
  for t=2:T2, erri(t,:) = rhoeps*erri(t-1,:) + sdeps*randn(1,N); end
  for t=2:T2, tmp=sdceps*randn(1,Nborder); errc(t,:)=rhoceps*errc(t-1,:)+tmp(borderid); end
  Ysim = bet*Xb + Fb*lam' + (errc+erri);
end
