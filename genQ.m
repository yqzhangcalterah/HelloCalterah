%-------------------------------------------------------------------------------
  %
  %  Filename       : genQ.m
  %  Author         : Huang Lei Lei
  %  Created        : 2019-07-19
  %  Description    : generate Q
  %
%-------------------------------------------------------------------------------

function Q = genQ(size)

     Q = zeros(size, size);
     for i = 0:floor(size/2)-1
          Q(i            +1, i            +1) =  1   ;
          Q(i            +1, size-1-i     +1) =  1   ;
          Q(size-1-i     +1, size-1-i     +1) = -1i  ;
          Q(size-1-i     +1, i            +1) =  1i  ;
     end
     if mod(size, 2)
          Q(floor(size/2)+1, floor(size/2)+1) = 2^0.5;
     end
