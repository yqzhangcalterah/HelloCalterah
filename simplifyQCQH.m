%-------------------------------------------------------------------------------
  %
  %  Filename       : simplify.m
  %  Author         : Huang Lei Lei
  %  Created        : 2019-01-16
  %  Description    : simplify correlation and svd calculation
  %
%-------------------------------------------------------------------------------

format compact;

clear;
clc;
syms x00 x01 x02 x03;
syms x10 x11 x12 x13;
syms x20 x21 x22 x23;
syms x30 x31 x32 x33;


fprintf('*** Q¡ÁC¡ÁQH ***\n');
fprintf('--- when subset size is 2 ---\n');
C = [real(x00)      x01 
          x01' real(x11)]
Q = genQ(2)
QCQH = simplify(real(Q*C*Q'))

fprintf('\n');
fprintf('--- when subset size is 3 ---\n');
C = [real(x00)      x01        x02
          x01' real(x11)       x12
          x02'      x12'  real(x22)]
Q = genQ(3)
QCQH = simplify(real(Q*C*Q'))

fprintf('\n');
fprintf('--- when subset size is 4 ---\n');
C = [real(x00)      x01        x02       x03
          x01' real(x11)       x12       x13
          x02'      x12'  real(x22)      x23
          x03'      x13'       x23' real(x33)]
Q = genQ(4)
QCQH = simplify(real(Q*C*Q'))

%{
fprintf('\n');
fprintf('\n');
fprintf('\n');
fprintf('*** C¡Áconj(Q) ***\n');
fprintf('--- when subset size is 2 ---\n');
C = [real(x_0_0) real(b)
     real(c) real(d)];
Q = [1  1
     1i -1i]
QCQH_real = simplify(real(C*conj(Q)))
QCQH_imag = simplify(imag(C*conj(Q)))

fprintf('\n');
fprintf('--- when subset size is 3 ---\n');
C = [real(x_0_0) real(b) real(c)
     real(d) real(e) real(f)
     real(g) real(h) real(i)]
Q = [1  0     1
     0  2^0.5 0
     1i 0     -1i]
QCQH_real = simplify(real(C*conj(Q)))
QCQH_imag = simplify(imag(C*conj(Q)))
%}