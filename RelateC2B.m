function [B] = RelateC2B(C, idx_UniNum)
%% Relate matrix C to B
% input arguments
% C          - (real matrix) size(C) = [M,N]
% idx_UniNum - (int vector) 
%
% by Dr. GUAN Guoqiang @ SCUT on 2019/9/14
%
%%
%  Check size
M = size(C, 1);
M1 = length(idx_UniNum);
if M ~= M1
    fprintf('Error: length(idx_UniNum) = %d not %d', M1, M);
    return;
end
%  Initialize
B = zeros(36, M);
%  Get B
for i = 1:M
    B(idx_UniNum(i), i) = 1;
end
%
end