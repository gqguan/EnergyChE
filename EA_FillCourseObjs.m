%% 将Objectives和Analysis中的字段分别写入QE_Course中的课程目标和达成度分析
%
% by Dr. Guan Guoqiang @ SCUT on 2020/6/29
%
function [QE_Course] = EA_FillCourseObjs(QE_Course,Objectives)
%% 初始化
nObj = 1;
iRow = 1;
NReq = length(QE_Course.Requirements);

%% 依次填入课程支撑各条毕业要求的教学目标
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
