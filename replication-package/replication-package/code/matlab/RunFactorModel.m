tol1=10^-6;  tol2=10^-6;
maxiter1=50; maxiter2=20;
% tol1=10^-8;  tol2=10^-8;
% maxiter1=100; maxiter2=40;
format short

filename=['3_Factors_p8_' varoi '_Select_' SepMethod '_drop_' num2str(drop) '_trunc_' num2str(trunc) '_nowks_' num2str(nowks) '_p_' num2str(p) '_seed_' num2str(seed)]; 

T2=T-drop-trunc;

cd(InputBaseDir);
disp(filename)

disp(['Solving ' varoi])
disp(['Seed: ', num2str(seed)])
% kbar=min(7*round((min(N,T2)/100)^0.25));
%kbar=min(8*round((min(N,T2)/100)^0.25));
kbar=7;
factors_to_run=[kbar factors_to_run_base];
%kbar=5;
%factors_to_run=[kbar];

beta_guess=zeros(p,1);
clear Xdata Ydata exo1 exo2 exo3 exo4 exo5 exovars

disp('Reading In Data')
j=0;
for i=1:N
	j=j+1;

	temp = importdata([InputBaseDir SepMethod '/QBLS' num2str(i) '.txt']);

	% Split the data by county within the pair
	lenbls=length(temp(:,1));
	if(i==1)
		year=zeros(lenbls,N);
		quarter=zeros(lenbls,N);
		LHSdata=zeros(lenbls,N);
		logwks=zeros(lenbls,N);
		pair_id=zeros(lenbls,N);
	end
	pair_id(:,j)=temp(1:lenbls,1);
	year(:,j)=temp(1:lenbls,2); %#ok<*SAGROW>
	quarter(:,j)=temp(1:lenbls,3);
	LHSdata(:,j)=temp(1:lenbls,var_ind);
	logwks(:,j)=temp(1:lenbls,4);
    exovars(:,:,j)=temp(1:lenbls,exorange);
	exo1(:,j)=temp(1:lenbls,exo_var_1);

% 	fweeks(:,1:12)=temp(1:lenbls,exo_var_5);
end
exovars = permute(exovars,[1 3 2]);

% Choose LHS and RHS variables
Xdata=zeros(T2,N,p);
if(nowks==0)
    Xdata(:,:,1) = logwks(drop+1:end-trunc,:);

    if(inc_constant)
        Xdata(:,:,2) = ones(T2,N);
        if(p>2)
            Xdata(:,:,3:p) = exovars(drop+1:end-trunc,:,:);
        end

    else
        if(p>1)
            Xdata(:,:,2:p) = exovars(drop+1:end-trunc,:,:);
        end
    end
else
    Xdata(:,:,1) = exo1(drop+1:end-trunc,:);

    if(inc_constant)
        Xdata(:,:,2) = ones(T2,N);
        if(p>2)
            Xdata(:,:,3:p) = exovars(drop+1:end-trunc,:,:);
        end

    else
        if(p>1)
            Xdata(:,:,2:p) = exovars(drop+1:end-trunc,:,:);
        end
    end        
end

%keyboard
Ydata = LHSdata(drop+1:end-trunc,:);
%Ydata(:,(Xdata(T2-4,:,2)==0))=NaN;
% Record the missing data
M=isnan(reshape(Xdata(:,:,1),[T2 N]));
if(p>1)
    for l=2:p
        M=max(M,isnan(reshape(Xdata(:,:,l),[T2 N])));
    end
end

M=max(max(M,isnan(Ydata)),isinf(Ydata));
%keyboard
%[bb bbi]=sort(Xdata(T2-3,:,2));

X=Xdata;
Y=Ydata;
%X(:,bbi(1:384),2)=-X(:,bbi(1:384),2);
%Y(:,bbi(1:384),:)=-Y(:,bbi(1:384),:);
%X(:,bbi(1:246),2)=-X(:,bbi(1:246),2);
%Y(:,bbi(1:246),:)=-Y(:,bbi(1:246),:);

%%

% First, choose the # of factors:
beta_est=zeros(length(factors_to_run),p);

XPXinv=0;
for t=1:T2
	for i=1:N
		if M(t,i)==0
			XPXinv = XPXinv+reshape(X(t,i,:),[p,1])*reshape(X(t,i,:),[1,p]);
		end
	end
end
XPXinv = inv(XPXinv);

disp('Solving for optimal # of factors')
for r_ind=1:length(factors_to_run)
    r=factors_to_run(r_ind);
	disp(['Solving with # factors: ',num2str(r),' factors: '])

    term=0;
    for t=1:T2
        for i=1:N
            if M(t,i)==0
                term = term + reshape(X(t,i,:),[p 1])*(Y(t,i));
            end
        end
    end
    beta_guess = zeros(p,1);
	beta_hat=beta_guess;
    beta_cur=-10+beta_hat;

	iter1=1;
	Wnew=zeros(T2,N);
	while norm(beta_cur-beta_hat)>tol1 || iter1<5
		beta_cur = beta_hat;
		% given beta, compute F_hat and lambda_hat using EM algorithm
		iter2=1;

		Wold=Wnew+ones(T2,N);
		while norm(Wold-Wnew)>tol2 || iter2<3
			if iter2>1
				Wold=Wnew;
			end
			if iter2>1
				for t=1:T2
					for i=1:N
						if M(t,i)==0
							Wnew(t,i)=Y(t,i)-reshape(X(t,i,:),[1 p])*beta_hat;
						else
							Wnew(t,i)=lambda_hat(i,:)*F_hat(t,:)';
						end
					end
				end
			else
				Wnew=zeros(T2,N);
			end
			WWP=Wnew*Wnew'/(N*T2);
			[V,D] = eig(WWP);
			D = diag(D);
			F_hat = sqrt(T2)*V(:,T2-(r-1):T2);
            if(fixedloadings==0)
    			lambda_hat = Wnew'*F_hat/T2;
            end
% 			if mod(iter2,50)==0
% 					disp(['Inner loop      ',num2str([iter2 norm(Wold-Wnew)])])
% 			end
			if iter1>=0.9*maxiter1
				if iter2==maxiter2
					break
				end
			else
				if iter2==maxiter2
					break
				end
			end
			iter2=iter2+1;
		end
% 		if norm(Wold-Wnew)>0.1
% 			disp(['Inner loop final ',num2str([iter2 norm(Wold-Wnew)])])
% 			disp('')
% 		end

		% given F_hat and lambda_hat, update beta_hat
		term=0;
		for t=1:T2
			for i=1:N
				if M(t,i)==0
					term = term + reshape(X(t,i,:),[p 1])*(Y(t,i)-lambda_hat(i,:)*F_hat(t,:)');
				end
			end
		end
		beta_hat = XPXinv*term;
% 		if mod(iter1,50)==0
% 			disp(['Outer Loop      ',num2str(iter1),'    ',num2str(beta_cur'),'    ',num2str(1000*norm(beta_hat-beta_cur)')])
% 		end
		if iter1==maxiter1
			break
		end
		iter1=iter1+1;
%        fprintf('iter=%d norm=%f\n',iter1,norm(beta_cur-beta_hat))
	end

	beta_est(r_ind,:)=beta_hat;
	% Compute R^2
	for t=1:T2
		for i=1:N
			Yhat(t,i)=reshape(X(t,i,:),[1 p])*beta_hat+lambda_hat(i,:)*F_hat(t,:)';
			residual(t,i)=Y(t,i)-Yhat(t,i);
		end
	end
	ssr(r_ind)=0;
	ssy(r_ind)=0;
	for t=1:T2
		for i=1:N
			if M(t,i)==0
				ssy(r_ind)=ssy(r_ind)+Ydata(t,i)^2;
				ssr(r_ind)=ssr(r_ind)+residual(t,i)^2;
			end
		end
	end

	sigma_hat(r_ind) = ssr(r_ind)/(N*T2);
	if r==kbar
		sigma_bar=sigma_hat(r_ind);
	end
	disp('')
	IC(1,r_ind) = log(sigma_hat(r_ind)) + r*(N+T2)/(N*T2)*log(N*T2/(N+T2));
	IC(2,r_ind) = log(sigma_hat(r_ind)) + r*(N+T2)/(N*T2)*log(min(N,T2));
	IC(3,r_ind) = log(sigma_hat(r_ind)) + r*log(min(N,T2))/min(N,T2);
	IC(4,r_ind) = log(sigma_hat(r_ind)) + (r*(N+T2)-r^2)*log(N*T2)/(N*T2);

	PC(1,r_ind) = sigma_hat(r_ind) + r*sigma_bar*(N+T2)/(N*T2)*log(N*T2/(N+T2));
	PC(2,r_ind) = sigma_hat(r_ind) + r*sigma_bar*(N+T2)/(N*T2)*log(min(N,T2));
	PC(3,r_ind) = sigma_hat(r_ind) + r*sigma_bar*log(min(N,T2))/min(N,T2);
	PC(4,r_ind) = sigma_hat(r_ind) + sigma_bar*(r*(N+T2)-r^2)*log(N*T2)/(N*T2);
	disp([r beta_est(r_ind,:) IC(:,r_ind)' PC(:,r_ind)'])
	disp('')
end
% keyboard
%%
cd(SaveDir);
results=[factors_to_run' beta_est IC' PC' sigma_hat' ssr' ssy' 1-ssr'./ssy' ];
Nobs=size(M,1)*size(M,2)-sum(sum(M));
[minIC, optfac]=min(PC(4,:));
dlmwrite([filename '.csv'],results);
filename2=[SepMethod '_' varoi]; 
dlmwrite([InputBaseDir SepMethod '/' filename2 '_optfac.csv'],kbar-optfac+1);
dlmwrite([filename2 '_coefs.csv'],beta_est(optfac,:));
dlmwrite([filename2 '_Nobs.csv'],Nobs);

% format short;
% disp('Results')
% for r_ind=1:length(factors_to_run)
% 	disp([factors_to_run(r_ind) beta_est(r_ind,:) 1-ssr(r_ind)/ssy(r_ind) IC(:,r_ind)' PC(:,r_ind)'])
% end
cd(FactorModelCodeDir);
