function corr_out=rotateU(corr_in,dim)
u_2 = [1 1;1i -1i];
u_3 =[1 0 1;0 sqrt(2) 0;1i 0 -1i];
u_4 =[1 0 0 1;0 1 1 0;0 1i -1i 0;1i 0 0 -1i];
if dim==2
    U = u_2;
end
if dim==3
    U = u_3;
end
if dim==4
    U = u_4;
end
corr_out=real(U*corr_in*U');
end