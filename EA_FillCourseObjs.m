%% ��Objectives��Analysis�е��ֶηֱ�д��QE_Course�еĿγ�Ŀ��ʹ�ɶȷ���
%
% by Dr. Guan Guoqiang @ SCUT on 2020/6/29
%
function [QE_Course] = EA_FillCourseObjs(QE_Course,Objectives)
%% ��ʼ��
nObj = 1;
iRow = 1;
NReq = length(QE_Course.Requirements);

%% ��������γ�֧�Ÿ�����ҵҪ��Ľ�ѧĿ��
for iReq = 1:NReq
    Requirement = QE_Course.Requirements(iReq);
    NObj = length(Requirement.Objectives);
    for iObj = 1:NObj
        QE_Course.Output{iRow,2} = Objectives(nObj);
        if nObj <= length(Objectives)
            Requirement.Objectives(iObj).Description = Objectives(nObj);
        else
            fprintf('�����桿�������Objectives�ߴ�С��QE_Course�趨��������%d����ѧĿ���ÿ��ַ����!',nObj)
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
