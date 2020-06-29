%% 将Objectives和Analysis中的字段分别写入QE_Course中的课程目标和达成度分析
%
% by Dr. Guan Guoqiang @ SCUT on 2020/6/29
%
function [QE_Course] = EA_FillText(QE_Course,Objectives,Analysis)
%% 初始化
% 缺省输入参数
switch nargin
    case 2
        Analysis = '';
end
nObj = 1;
iRow = 1;
NReq = length(QE_Course.Requirements);
for iReq = 1:NReq
    Requirement = QE_Course.Requirements(iReq);
    NObj = length(Requirement.Objectives);
    for iObj = 1:NObj
        QE_Course.Output{iRow,2} = Objectives(nObj);
        if nObj <= length(Objectives)
            Requirement.Objectives(iObj).Description = Objectives(nObj);
        else
            fprintf('【警告】输入参数Objectives尺寸小于QE_Course设定，后续第%d个教学目标用空字符填充!',nObj)
            Requirement.Objectives(iObj).Description = '';
        end
        nObj = nObj+1;
        EvalTypes = Requirement.Objectives(iObj).EvalTypes;
        for iType = 1:length(EvalTypes)
            EvalWays = EvalTypes(iType).EvalWays;
            for iWay = 1:length(EvalWays)
                iRow = iRow+1;
            end
        end
    end
    QE_Course.Requirements(iReq) = Requirement;
end
% 在原有字段内容后添加Analysis
QE_Course.Analysis = strcat(QE_Course.Analysis,Analysis);
