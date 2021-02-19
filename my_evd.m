function [VV,DD]=my_evd(A,sub_array_size)
if sub_array_size==2
    a=A(1,1);
    b=A(2,2);
    c=A(1,2);
    x=a-b;
    y=2*c;
    if((x<0)&&(y~=0))
        tmpx = -x;
        tmpy =-y;
    else
        tmpx = x;
        tmpy =y;
    end
    theta = atan2(tmpy,tmpx)/pi;
    r = theta/2;
    if(x<0)
        r = r-0.5;
    end
    so=sin(r*pi);
    co = cos(r*pi);
    rot_mat = [co so;-so co];
    tempA(:,1)=rot_mat*A(1,:).';  %%rot_mat is 2*2
    tempA(:,2)=rot_mat*A(2,:).';
    A(1,1)=tempA(1,1);
    A(1,2)=tempA(2,1);
    A(2,1)=tempA(1,2);
    A(2,2)=tempA(2,2);
    
    %%index wrap
    tempA(:,1)=rot_mat*A(:,1);
    tempA(:,2)=rot_mat*A(:,2);
     A(1,1)=tempA(1,1);
    A(2,1)=tempA(2,1);
    A(1,2)=tempA(1,2);
    A(2,2)=tempA(2,2);
    A(1,2)=0;
    A(2,1)=0;
    DD = A;   %end computing diagonal
    temp_v =eye(2);   %it's U
    tempA(:,1)=rot_mat*temp_v(1,:).';
    tempA(:,2)=rot_mat*temp_v(2,:).';
    VV(1,1)=tempA(1,1);
    VV(1,2)=tempA(2,1);
    VV(2,1)=tempA(1,2);
    VV(2,2)=tempA(2,2); 
elseif ((sub_array_size==3)||(sub_array_size==4))
    if (sub_array_size==3)
    sequence =[0 1;0 2;1 2];
    iter = 8;
    else
%        sequence =[0 1;0 2;0 3;1 2;1 3;2 3];
         sequence =[0 1;2 3;0 3;1 2;1 3;0 2]; 
       iter = 17; 
    end
    temp_v =eye(sub_array_size);
    for ni = 1:iter
        fprintf('iter_num=%d\n',ni);
%         gg = mod(ni,sub_array_size);
         gg = mod(ni,length(sequence(:,1)));
        if(gg==0)
            gg=length(sequence(:,1));
        end
        deal_row = sequence(gg,:)
        idx1 = deal_row(1)+1;
        idx2 = deal_row(2)+1;
        %%compute rot start
        rot_mat = my_rotmat(A(idx1,idx1),A(idx2,idx2),A(idx1,idx2));
        %%compute rot end
        %%  row deal start
        tempA(:,1)=rot_mat*[A(idx1,idx1);A(idx1,idx2)];  %%rot_mat is 2*2
        tempA(:,2)=rot_mat*[A(idx2,idx1);A(idx2,idx2)];
    A(idx1,idx1)=tempA(1,1);
    A(idx1,idx2)=tempA(2,1);
    A(idx2,idx1)=tempA(1,2);
    A(idx2,idx2)=tempA(2,2);
    A
        %%row deal end
        %%column deal start
        tempA(:,1)=rot_mat*[A(idx1,idx1);A(idx2,idx1)];  %%rot_mat is 2*2
        tempA(:,2)=rot_mat*[A(idx1,idx2);A(idx2,idx2)];
    A(idx1,idx1)=tempA(1,1);
    A(idx2,idx1)=tempA(2,1);
    A(idx1,idx2)=tempA(1,2);
    A(idx2,idx2)=tempA(2,2);
    A
        %%column deal end
         A(idx1,idx2) = 0;
         A(idx2,idx1) = 0;
        %%the same row other element deal start 
        nue_num = 0;
        for kk=1:sub_array_size
            if ((kk~=idx1)&&(kk~=idx2))
                  nue_num = nue_num+1;
                   new_idx(nue_num) = kk;   
            end
        end
        for tt=1:nue_num
            lal = new_idx(tt);
        tempA(:,1)=rot_mat*[A(idx1,lal);A(idx2,lal)];  %%rot_mat is 2*2 
    A(idx1,lal)=tempA(1,1);
    A(idx2,lal)=tempA(2,1);
    A(lal,idx1)=tempA(1,1);
    A(lal,idx2)=tempA(2,1);
        end
        A
       %%the same row other element deal start
       %%computing v start
       for tt=1:sub_array_size
       tempA(:,1)=rot_mat*[temp_v(idx1,tt);temp_v(idx2,tt)];
       temp_v(idx1,tt)=tempA(1,1);
       temp_v(idx2,tt)=tempA(2,1);
       end
       temp_v
       %%computing v end 
    end
    DD = A;   %end computing diagonal
    VV = temp_v;
else
    fprintf('not support sub_array_size\n');
end


end

function out=my_rotmat(a,b,c)
%  a=A(1,1);
%     b=A(2,2);
%     c=A(1,2);
    x=a-b;
    y=2*c;
    if((x<0)&&(y~=0))
        tmpx = -x;
        tmpy =-y;
    else
        tmpx = x;
        tmpy =y;
    end
    theta = atan2(tmpy,tmpx)/pi;
    r = theta/2;
    if(x<0)
        r = r-0.5;
    end
    so=sin(r*pi);
    co = cos(r*pi);
    rot_mat = [co so;-so co];
    out = rot_mat;
end