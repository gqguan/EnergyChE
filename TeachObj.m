function [X, Y] = TeachObj(B, C, D, E, U)
%% 计算课程的教学目标达成度
% Input arguments
% B - (real matrix) 用于构建Y矩阵
% C - (real matrix) 教学目标与支持指标点间的关系矩阵
% D - (real matrix) 教学内容与目标的关系矩阵
% E - (real vector) 各教学内容考核的权重向量
% Output arguments
% X - (real vector) 课程支撑的指标点完成度向量，length(X) = M
% Y - (real vector) 课程支撑的指标点完成度向量，length(Y) = 36
%
% by Dr. GUAN Guoqiang @ SCUT on 2019/9/13
%
%% 输入参数尺寸检查
[I, M] = size(B);
if I ~= 36
    fprintf('Error: size(B,1) = %d not 36 \n', I);
    return;
end
if size(C, 1) ~= M 
    fprintf('Error: size(C, 1) = %d not %d \n', size(C, 1), M);
    return;
end
N = size(C, 2);
L = size(D, 2);
J = size(E);
if size(U, 1) ~= L && size(U, 2) ~= J
    fprintf('Incorrect dimension of input argment U \n');
    return;
end
%% 教学内容完成度
V = U*E;
%% 教学目标达成度
W = D*V;
%% 支撑指标点达成度
X = C*W;
Y = B*X;
%
end