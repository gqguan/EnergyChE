%% ���ݽ�ѧ���ݺͿ��˵Ĺ�ϵ��C2W������ѧĿ������ݵĹ�ϵ��O2C��ȷ����ѧĿ��Ϳ��˵Ĺ�ϵ��O2W��
%
% by Dr. Guan Guanqiang @ SCUT on 2020-08-25

function O2W = EA_GetRelMatrix(O2C, C2W)

% ����������
[NumObj,NumContent] = size(O2C);
if size(C2W,1) == NumContent
    NumWay = size(C2W,2);
else
    cprintf('err','�����󡿵�һ������������������ڵڶ����������������\n')
    return
end
% ��ʼ��������
O2W = false(NumObj,NumWay);

for iObj = 1:NumObj
    O2W(iObj,:) = logical(sum(C2W(logical(O2C(iObj,:)),:)));
end