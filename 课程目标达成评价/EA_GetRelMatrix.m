%% 根据教学内容和考核的关系（C2W）及教学目标和内容的关系（O2C）确定教学目标和考核的关系（O2W）
%
% by Dr. Guan Guanqiang @ SCUT on 2020-08-25

function O2W = EA_GetRelMatrix(O2C, C2W)

% 检查输入参数
[NumObj,NumContent] = size(O2C);
if size(C2W,1) == NumContent
    NumWay = size(C2W,2);
else
    cprintf('err','【错误】第一输入参数的列数不等于第二输入参数的行数！\n')
    return
end
% 初始化输出结果
O2W = false(NumObj,NumWay);

for iObj = 1:NumObj
    O2W(iObj,:) = logical(sum(C2W(logical(O2C(iObj,:)),:)));
end