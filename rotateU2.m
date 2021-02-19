function corr_out=rotateU2(corr_in,dim)
    sqrt2 = 1.4142135623730951;
    if (dim == 2) 
	corr_out(0+1, 0+1) = real(corr_in(0+1, 0+1)) + real(corr_in(1+1, 1+1)) + 2 * real(corr_in(0+1, 1+1));
	corr_out(0+1, 1+1) = -2 * imag(corr_in(0+1, 1+1));
	corr_out(1+1, 0+1) = corr_out(0+1, 1+1);
	corr_out(1+1, 1+1) = real(corr_in(0+1, 0+1)) + real(corr_in(1+1, 1+1)) - 2 * real(corr_in(0+1, 1+1));
    elseif (dim == 3) 
	corr_out(0+1, 0+1) = real(corr_in(0+1, 0+1)) + real(corr_in(2+1, 2+1)) + 2 * real(corr_in(0+1, 2+1));
	corr_out(0+1, 2+1) = -2 * imag(corr_in(0+1, 2+1));
	corr_out(2+1, 0+1) = corr_out(0+1, 2+1);
	corr_out(2+1, 2+1) = real(corr_in(0+1, 0+1)) + real(corr_in(2+1, 2+1)) - 2 * real(corr_in(0+1, 2+1));
	corr_out(1+1, 1+1) = 2 * real(corr_in(1+1, 1+1));
	corr_out(0+1, 1+1) = sqrt2 * (real(corr_in(0+1, 1+1)) + real(corr_in(1+1, 2+1)));
	corr_out(1+1, 0+1) = corr_out(0+1, 1+1);
	corr_out(1+1, 2+1) = - sqrt2 * (imag(corr_in(0+1, 1+1)) + imag(corr_in(1+1, 2+1)));
	corr_out(2+1, 1+1) = corr_out(1+1, 2+1);
    elseif (dim == 4)
     corr_out(0+1, 0+1) = real(corr_in(0+1, 0+1)) + real(corr_in(3+1, 3+1)) + 2 * real(corr_in(0+1, 3+1));
	 corr_out(1+1, 1+1) = real(corr_in(1+1, 1+1)) + real(corr_in(2+1, 2+1)) + real(2 * corr_in(1+1, 2+1));
     corr_out(2+1, 2+1) = real(corr_in(1+1, 1+1)) + real(corr_in(2+1, 2+1)) - real(2 * corr_in(1+1, 2+1));
	corr_out(3+1, 3+1) = real(corr_in(0+1, 0+1)) + real(corr_in(3+1, 3+1)) - real(2 * corr_in(0+1, 3+1));	
	corr_out(0+1, 1+1) = real(corr_in(0+1, 1+1)) + real(corr_in(0+1, 2+1)) + real(corr_in(3+1, 1+1)) + real(corr_in(3+1, 2+1));
    corr_out(0+1, 2+1) = -1*(imag(corr_in(0+1, 2+1)) + imag(corr_in(3+1, 2+1)) - imag(corr_in(0+1, 1+1)) - imag(corr_in(3+1, 1+1)));
	corr_out(0+1, 3+1) = -1*(imag(corr_in(0+1, 3+1)) + imag(corr_in(3+1, 3+1)) - imag(corr_in(0+1, 0+1)) - imag(corr_in(3+1, 0+1)));
    corr_out(1+1, 2+1) = -1*(imag(corr_in(1+1, 2+1)) + imag(corr_in(2+1, 2+1)) - imag(corr_in(1+1, 1+1)) - imag(corr_in(2+1, 1+1)));
	corr_out(1+1, 3+1) = -1*(imag(corr_in(1+1, 3+1)) + imag(corr_in(2+1, 3+1)) - imag(corr_in(1+1, 0+1)) - imag(corr_in(2+1, 0+1)));
	corr_out(2+1, 3+1) =  real(corr_in(1+1, 0+1)) - real(corr_in(2+1, 0+1)) - real(corr_in(1+1, 3+1)) + real(corr_in(2+1, 3+1));
    corr_out(1+1, 0+1) = corr_out(0+1, 1+1); 
	corr_out(2+1, 0+1) = corr_out(0+1, 2+1);
    corr_out(2+1, 1+1) = corr_out(1+1, 2+1);
    corr_out(3+1, 0+1) = corr_out(0+1, 3+1);
	corr_out(3+1, 1+1) = corr_out(1+1, 3+1);
    corr_out(3+1, 2+1) = corr_out(2+1, 3+1);
    else
	fprintf('rotaionU2 doesnot support dim = %d\n',dim);
    end
    end