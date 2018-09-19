%%%%µ¹ÐòÊý
%IN
%N=g^x
%out J is g???????????¨°?¨®????????
function [J] = REVERSAL_ORDER_IDX_hy(N,g)
if(N>g(1)) 
    J(1)=N/g(1);   %?????¨°g??????????????????????????????¡Á???????1???????????¨°????????????
    for I=2:N-2    %1st and the last don't need computing
    K1=(g(1)-1)*N/g(1);  %K1??¡Á???????g-1?????¨¤????0
    K2=K1/(g(1)-1);  %K2??¡Á???????1?????¨¤????0
    temp = J(I-1);
    count = 1;
%     temp = 9;  %test
    mul = g(1);
    while temp>=K1  %?¨¨???¨°??????  
        count=count+1;  %store right shift time
        J(I)=temp-K1;
        temp = J(I);
        %update K1 K2
        mul = mul*g(count);
        K1=(g(count)-1)*(N/mul);
        K2=K1/(g(count)-1);
%         K1=floor(K1/g(count));    %right shift 1bit
%         K2=floor(K1/(g(count)-1));
    end
        J(I)=temp+K2;
    
    end
    J=[0 J N-1];  
elseif(N==g)
    J=0:N-1;
else
    J=0;
end
end
 



 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [out] = Hybrid_BF2(A,radix)
j=sqrt(-1);
col=length(A(1,:));
W1=cos(2*pi/3)-j*sin(2*pi/3);
W2=W1^2;
W1_r5=cos(2*pi/5)-j*sin(2*pi/5);
W2_r5=W1_r5^2;
W3_r5=conj(W2_r5);
W4_r5 = conj(W1_r5);
    if 2==radix
%         disp('?¨´2');
        for ll=1:col
     data = A(:,ll);
     x1= data(1)+data(2);
     x2= data(1)-data(2);
     out(ll)=x1;
     out(col+ll)=x2;
        end
     
     elseif 3==radix
%          disp('?¨´3');
        for ll=1:col
     data = A(:,ll);
     t1 = data(2)+data(3);
     t2 = data(3)-data(2);
     m0 = data(1) + t1;
     m1 = t1*(cos(2*pi/3)-1);
     m2 = 1i*t2*sin(2*pi/3);
     s1 = m0 + m1;
     x1 = m0;
     x2 = s1+m2;
     x3 = s1-m2;
     out(ll)=x1;
     out(col+ll)=x2;
     out(col*2+ll)=x3;
        end
      elseif 4==radix
%            disp('?¨´4');
           for ll=1:col
               data = A(:,ll);          
           x1=data(1)+data(2)+data(3)+data(4);
           x2=data(1)-data(3)-j*(data(2)-data(4));
           x3=data(1)+data(3)-(data(2)+data(4));
           x4=data(1)-data(3)+j*(data(2)-data(4));
            out(ll)=x1;
            out(col+ll)=x2;
            out(col*2+ll)=x3;
           out(col*3+ll)=x4;
           end
elseif 5==radix
%     disp('?¨´5');
    for ll=1:col
       data = A(:,ll);
       c0 = (cos(2*pi/5)+cos(4*pi/5))/2-1;
       c1 = (cos(2*pi/5)-cos(4*pi/5))/2;
       c2 = sin(2*pi/5)+sin(4*pi/5);
       c3 = sin(2*pi/5);
       c4 = sin(2*pi/5)-sin(4*pi/5);
       t1 = data(2)+data(5);
       t2 = data(3)+data(4);
       t3 = data(2)-data(5);
       t4 = data(4)-data(3);
       t5 = t1 + t2;
       m0 = t5 + data(1); 
       m1 = t5/4+t5;%-1*t5*c0;
       m2 = (t1-t2)*c1;
       m3 = 1i*(t3+t4)*c3;
       m4 = 1i*t4*c2;
       m5 = 1i*t3*c4;
       s1 = m0-m1;
       s2 = s1+m2;
       s3 = m4 - m3;
       s4 = s1 - m2;
       s5 = m5 - m3;
       x1 = m0;
       x2 = s2+s3;
       x3 = s4+s5;
       x4 = s4-s5;
       x5 = s2-s3;
        out(ll)=x1;
            out(col+ll)=x2;
            out(col*2+ll)=x3;
           out(col*3+ll)=x4;
         out(col*4+ll)=x5;
    end
else
    fprintf('wrong radix,only support R-2,3,4,5 Butterfly');
end
end
 
 