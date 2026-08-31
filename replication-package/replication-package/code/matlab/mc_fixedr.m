function b = mc_fixedr(X, Y, r, M, binit)
% Fixed-r interactive-fixed-effects estimator, p=1. M = missing mask (1=missing).
% No-missing -> fully vectorized; missing cells filled with lambda*F' each EM step
% (matches RunFactorModel_fixedr). X assumed fully observed; missingness is in Y.
  [T2,N] = size(X);
  if nargin<4 || isempty(M), M = isnan(Y) | isnan(X); end
  Xo = X; Xo(M)=0; Yo = Y; Yo(M)=0;
  sx2 = sum(Xo(:).^2);
  if nargin<5 || isempty(binit), b = sum(Xo(:).*Yo(:))/sx2; else, b = binit; end
  F = zeros(T2,r); lam = zeros(N,r);
  for it=1:500
    W = Yo - b*Xo;                 % observed cells = Y-bX; missing cells = 0 ...
    if it>1, FL = F*lam'; W(M) = FL(M); end   % ... then filled with model prediction
    [V,~] = eig((W*W')/(N*T2));
    F = sqrt(T2)*V(:, T2-r+1:T2);
    lam = (W'*F)/T2;
    R = Y - F*lam'; R(M)=0;
    bnew = sum(Xo(:).*R(:))/sx2;
    if abs(bnew-b) < 1e-11, b = bnew; break; end
    b = bnew;
  end
end
