function [X, Y] = TeachObj(B, C, D, E, U)
%% ����γ̵Ľ�ѧĿ���ɶ�
% Input arguments
% B - (real matrix) ���ڹ���Y����
% C - (real matrix) ��ѧĿ����֧��ָ����Ĺ�ϵ����
% D - (real matrix) ��ѧ������Ŀ��Ĺ�ϵ����
% E - (real vector) ����ѧ���ݿ��˵�Ȩ������
% Output arguments
% X - (real vector) �γ�֧�ŵ�ָ�����ɶ�������length(X) = M
% Y - (real vector) �γ�֧�ŵ�ָ�����ɶ�������length(Y) = 36
%
% by Dr. GUAN Guoqiang @ SCUT on 2019/9/13
%
%% ��������ߴ���
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
%% ��ѧ������ɶ�
V = U*E;
%% ��ѧĿ���ɶ�
W = D*V;
%% ֧��ָ����ɶ�
X = C*W;
Y = B*X;
%
end