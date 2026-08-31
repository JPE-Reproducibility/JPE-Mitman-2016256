function [inds vals]=basefun(x,grid_x,len)

jl=1;    
ju=len;	

while(ju-jl>1)
    jm=floor((ju+jl)/2);
    if(x>=grid_x(jm))
		jl=jm;
	else
		ju=jm;
    end
end

i=jl+1;
vals(2)=( x-grid_x(i-1) )/(grid_x(i)-grid_x(i-1));
vals(2)=min(vals(2),1);
vals(1)=1-vals(2);
inds(2)=i;
inds(1)=i-1;