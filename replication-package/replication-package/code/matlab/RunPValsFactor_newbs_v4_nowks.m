cd(InputBaseDir);
%cd ./results;
r=numfactors;

tol1=10^-5;
tol2=10^-4;
maxiter1=50;
maxiter2=20;

disp(['Solving ' varoi])
disp(['Seed: ', num2str(seed)])
disp(['New_Estimating ',num2str(nrun),' bootstrap samples with ',num2str(r),' factors'])


  filename2=[SepMethod '_' varoi '_NewEstimate_drop' num2str(drop) 'trunc' num2str(trunc) '_fac' num2str(r) '_placebo' num2str(placebo) '_' num2str(seed)];
disp(filename2)

clear Xdata Ydata exo1 exo2 exo3 exo4 exo5 exovars sbeta_est

disp('Reading In Data')
cluster=importdata([InputBaseDir SepMethod '/bordersegment_cluster.txt']);
maxcluster=max(cluster(:,1));
T2=T-drop-trunc;
T=T2;
clear exovars
%%
% beta_guess=zeros(p,1);

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
%     didwks(:,j)=temp(1:lenbls,28);
    exo1(:,j)=temp(1:lenbls,exo_var_1); 
    exo2(:,j)=temp(1:lenbls,exo_var_2); 
    exovars(:,:,j)=temp(1:lenbls,exorange);


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



Ydata = LHSdata(drop+1:end-trunc,:);

% Record the missing data
M=isnan(reshape(Xdata(:,:,1),[T2 N]));
if(p>1)
    for l=2:p
        M=max(M,isnan(reshape(Xdata(:,:,l),[T2 N])));
    end
end
M=max(max(M,isnan(Ydata)),isinf(Ydata));



X=Xdata;
Y=Ydata;
%[bb bbi]=sort(Xdata(32,:,2));

%X(:,bbi(1:393),2)=-X(:,bbi(1:393),2);
%Y(:,bbi(1:393),:)=-Y(:,bbi(1:393),:);



%%
% Now, estimate with selected # of parameters and estimate
beta_est=zeros(nrun+1,p);
for run=1:nrun+1
	if run>1
		disp(['Bootstrap Run: ',num2str(run-1),' of ',num2str(nrun)])
	else
		disp('Getting the point estimate..')
	end

	% Sampling with replacement
	if run==1
		X=Xdata;
		Y=Ydata;
		N2=N;
	else
		if clusterborder==0
			for i=1:N
				ind=max(ceil(N*rand));
				for j=1:p
					X(:,i,j)=Xdata(:,ind,j);
				end
				Y(:,i)=Ydata(:,ind);
			end
			N2=N;
		else
			perm_order=randperm(N);
			X=Xdata(perm_order);
			loc=0;
			X=Xdata;
			for i=1:maxcluster
				segment=max(ceil(maxcluster*rand));
				temp=min(N,find(cluster(:,1)==segment));
				for i2=1:length(temp)
					for t2=1:T
						if loc+i2<=N
							Y(t2,loc+i2)=reshape(X(t2,loc+i2,:),[1 p])*beta_est(1,:)';
							Y(t2,loc+i2)=Y(t2,loc+i2)+residual2(t2,temp(i2));
						end
					end
				end
				loc=loc+length(temp);
			end
			N2=min(N,loc);
		end
	end
	X=X(:,1:N2,:);
	Y=Y(:,1:N2);
	disp('    Sampling Completed')

	% Record the missing data
    M=isnan(reshape(X(:,:,1),[T N2]));
    if(p>1)
        for l=2:p
            M=max(M,isnan(reshape(X(:,:,l),[T N2])));
        end
    end

	M=max(max(M,isnan(Y)),isinf(Y));

	XPXinv=0;
	for t=1:T
		for i=1:N2
			if M(t,i)==0
				XPXinv = XPXinv+reshape(X(t,i,:),[p,1])*reshape(X(t,i,:),[1,p]);
			end
		end
	end
	XPXinv = inv(XPXinv);
    term=0;
    for t=1:T
        for i=1:N2
            if M(t,i)==0
                term = term + reshape(X(t,i,:),[p 1])*(Y(t,i));
            end
        end
    end
    beta_guess = zeros(p,1);
    beta_hat = beta_guess;
	beta_cur=-10+beta_hat;

	iter1=1;
	Wold=zeros(T,N2);
	Wnew=zeros(T,N2);
	while norm(beta_cur-beta_hat)>tol1
		beta_cur = beta_hat;
		% given beta, compute F_hat and lambda_hat using EM algorithm
		iter2=1;
	% 	disp('Now the EM')
		Wold=Wnew+ones(T,N2);
		while norm(Wold-Wnew)>tol2 || iter2<3
			if iter2>1
				Wold=Wnew;
			end
			if iter2>1
				for t=1:T
					for i=1:N2
						if M(t,i)==0
							Wnew(t,i)=Y(t,i)-reshape(X(t,i,:),[1 p])*beta_hat;
						else
							Wnew(t,i)=lambda_hat(i,:)*F_hat(t,:)';
						end
					end
				end
			else
				Wnew=zeros(T,N2);
			end
			WWP=Wnew*Wnew'/(N2*T);
			[V,D] = eig(WWP);
			D = diag(D);
			F_hat = sqrt(T)*V(:,T-(r-1):T);
			lambda_hat = Wnew'*F_hat/T;

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
	% 	disp([iter2 norm(Wold-Wnew)])

		% given F_hat and lambda_hat, update beta_hat
		term=0;
		for t=1:T
			for i=1:N2
				if M(t,i)==0
					term = term + reshape(X(t,i,:),[p 1])*(Y(t,i)-lambda_hat(i,:)*F_hat(t,:)');
				end
			end
		end
		beta_hat = XPXinv*term; %#ok<*MINV>
% 		if mod(iter1,5)==0
% 			disp(['    ',num2str(iter1),'    ',num2str(beta_cur'),'    ',num2str(1000*norm(beta_hat-beta_cur)')])
% 		end
		if iter1==maxiter1
			break
		end
		iter1=iter1+1;
	end

	if run==1
		% Compute R^2
		for t=1:T
			for i=1:N2
				Yhat(t,i)=reshape(X(t,i,:),[1 p])*beta_hat+lambda_hat(i,:)*F_hat(t,:)';
				residual(t,i)=Y(t,i)-Yhat(t,i);
				residual2(t,i)=Y(t,i)-reshape(X(t,i,:),[1 p])*beta_hat;
			end
		end
		ssr=0;
		ssy=0;
		for t=1:T
			for i=1:N2
				if M(t,i)==0
					ssy=ssy+Ydata(t,i)^2;
					ssr=ssr+residual(t,i)^2;
				end
			end
		end
		SaveFactors = F_hat;
        SaveLoadings = lambda_hat;
		% Compute Durbin-Watson statistic
		dwstat1=0;
		dwstat2=0;
		for i=1:N2
			for t=2:T
				if M(t,i)==0 && M(t-1,i)==0
					dwstat1=dwstat1+(residual(t,i)-residual(t-1,i))^2;
					dwstat2=dwstat2+residual(t,i)^2;
				end
			end
		end
		dwstat=dwstat1/dwstat2;
	end
	disp(['R-squared: ', num2str(1-ssr/ssy)])
	disp(['Durbin-Watson: ', num2str(dwstat)])

	beta_est(run,:)=beta_cur';
	disp([run beta_est(run,:)]);
	disp('');
end
%%
for i=1:p
	sbeta_est(:,i)=sort(beta_est(2:nrun+1,i));
end
cd(SaveDir);
results2=[(1:nrun+1)' [beta_est(1,:);sbeta_est] (1-ssr/ssy)*ones(nrun+1,1)];
dlmwrite([filename2 '.csv'],results2);

disp(['R-squared: ', num2str(1-ssr/ssy)])


  filename2=[SepMethod '_' varoi '_drop' int2str(drop) '_trunc' int2str(trunc)]; 
dlmwrite([filename2 '_se.csv'],[beta_est(1,1); sum(sbeta_est(:,1)>0)/nrun*100; sbeta_est(round(0.025*nrun),1);sbeta_est(round(0.975*nrun),1);std(sbeta_est(:,1));numfactors;(1-ssr/ssy);Nobs]);

filename2=[SepMethod '_' varoi '_Factors']; 
dlmwrite([filename2 '.csv'],SaveFactors);
filename2=[SepMethod '_' varoi '_Loadings']; 
dlmwrite([filename2 '.csv'],SaveLoadings);
cd(FactorModelCodeDir)
