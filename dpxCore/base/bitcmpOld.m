function output = bitcmpOld(x,N)
      if nargin < 2
          output = bitcmp(x);
      else
          maxN = 2^N-1;    % This is the max number you can represent in 4 bits
          fmt  = 'uint32';  % You can change uint8 to uint16 or 32
          out1 = eval(['bitcmp(',fmt,'(x)',',''',fmt,''')']);
          out2 = eval(['bitcmp(',fmt,'(maxN)',',''',fmt,''')']);
          output = out1 - out2;
      end
end