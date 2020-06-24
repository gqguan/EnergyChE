%% 根据教学目标与考核内容的关系矩阵构造考核方法
%
% by Dr. Guan Guoqiang @ SCUT on 2020/6/22

function QE_Course = EA_EvalMethod(QE_Course)
%% 初始化
Requirements = QE_Course.Requirements;
NumReq = length(Requirements);
Obj2Content = QE_Course.RelMatrix.Obj2Content;
Spec = QE_Course.Transcript.Definition.Spec;
Def_EvalTypes = QE_Course.Transcript.Definition.EvalTypes;
% 获取考核方式代码向量
TypeCodes = cell(1,length(Def_EvalTypes));
WayCodes = cell(1,size(Obj2Content,2));
iWayCode = 1;
for iType = 1:length(Def_EvalTypes)
    TypeCodes(iType) = {Def_EvalTypes(iType).Code};
    for iWay = 1:length(Def_EvalTypes(iType).EvalWays)
        WayCodes(iWayCode) = {[Def_EvalTypes(iType).Code,num2str(iWay)]};
        iWayCode = iWayCode+1;
    end
end

%% 计算成绩单中各考核方式的平均得分
Transcript = QE_Course.Transcript.Detail;
% 按列变量名选择数据
VarNames = Transcript.Properties.VariableNames;
Indices_SelectedCols = false(size(VarNames));
for iWayCode = 1:length(WayCodes)
    Indices_CurrentCols = strcmp(WayCodes{iWayCode},VarNames);
    Indices_SelectedCols = Indices_SelectedCols|Indices_CurrentCols;
end
% 计算平均值
Scores = Transcript{:,Indices_SelectedCols};
switch class(Scores)
    case('cell')
        AvgTable = array2table(mean(cell2mat(Scores)), ...
                               'VariableNames', VarNames(Indices_SelectedCols));
    case('double')
        AvgTable = array2table(mean(Scores), ...
                               'VariableNames', VarNames(Indices_SelectedCols));
end
%% 顺次对各指标点构造考核方法并进行达成度计算
for iReq = 1:NumReq
    Objectives = Requirements(iReq).Objectives;
    NumObj = length(Objectives);
    Sum_Credit = zeros(1,NumObj);
    Sum_FullCredit = zeros(1,NumObj);
    for iObj = 1:NumObj
        EvalTypes = Objectives(iObj).EvalTypes;           
        % 获得该教学目标的考核方式代码
        Indices = Obj2Content(iReq,:);
        % 按Spec截取各类考核的相关方式
        Spec1 = cell(1,length(Spec));
        Indices_DeleteType = false(1,length(EvalTypes));
        for iType = 1:length(Spec)
            Spec1(iType) = {Indices(1:Spec(iType))};
            if sum(Spec1{iType}) == 0
                Indices_DeleteType(iType) = true;
            else
                EvalTypes(iType).EvalWays = EvalTypes(iType).EvalWays(Spec1{iType});
            end
            Indices = Indices(Spec(iType)+1:end);
        end
        EvalTypes(Indices_DeleteType) = [];
        Objectives(iObj).EvalTypes = EvalTypes;
        % 修正各考核方式的权重值
        Subsum_Credit = zeros(1,length(EvalTypes));
        Subsum_FullCredit = zeros(1,length(EvalTypes));
        for iType = 1:length(EvalTypes)
            CorrectCredit = zeros(1,length(EvalTypes(iType).EvalWays));
            CorrectFullCredit = zeros(1,length(EvalTypes(iType).EvalWays));
            Weight_Type = Objectives(iObj).EvalTypes(iType).Weight;
            for iWay = 1:length(EvalTypes(iType).EvalWays)
                Weight_Way = Objectives(iObj).EvalTypes(iType).EvalWays(iWay).Weight;
                Weight = Weight_Type*Weight_Way;
                Objectives(iObj).EvalTypes(iType).EvalWays(iWay).Weight = Weight;
                % 从成绩表中获取该项考核方式的得分
                Credit = AvgTable.(Objectives(iObj).EvalTypes(iType).EvalWays(iWay).Code);
                Objectives(iObj).EvalTypes(iType).EvalWays(iWay).Credit = Credit;
                FullCredit = Objectives(iObj).EvalTypes(iType).EvalWays(iWay).FullCredit;
                Objectives(iObj).EvalTypes(iType).EvalWays(iWay).Result = Credit/FullCredit;
                CorrectCredit(iWay) = Credit*Weight;
                Objectives(iObj).EvalTypes(iType).EvalWays(iWay).Correction.Credit = Credit*Weight;
                CorrectFullCredit(iWay) = FullCredit*Weight;
                Objectives(iObj).EvalTypes(iType).EvalWays(iWay).Correction.FullCredit = FullCredit*Weight;
            end
            Subsum_Credit(iType) = sum(CorrectCredit);
            Objectives(iObj).EvalTypes(iType).Subsum.Credit = sum(CorrectCredit);
            Subsum_FullCredit(iType) = sum(CorrectFullCredit);
            Objectives(iObj).EvalTypes(iType).Subsum.FullCredit = sum(CorrectFullCredit);
        end
        Objectives(iObj).Weight = 1; % 一个教学目标对应于一个毕业要求指标点
        Sum_Credit(iObj) = sum(Subsum_Credit);
        Objectives(iObj).Sum.Credit = sum(Subsum_Credit);
        Sum_FullCredit(iObj) = sum(Subsum_FullCredit);
        Objectives(iObj).Sum.FullCredit = sum(Subsum_FullCredit);
        Objectives(iObj).Result = Objectives(iObj).Sum.Credit/Objectives(iObj).Sum.FullCredit;
    end
    Requirements(iReq).Objectives = Objectives;
    Requirements(iReq).Weight = sum(Sum_FullCredit)/100;
    Requirements(iReq).Result = sum(Sum_Credit)/sum(Sum_FullCredit);
end
QE_Course.Requirements = Requirements;
QE_Course.Result = dot(cell2mat({Requirements.Weight}),cell2mat({Requirements.Result}));
QE_Course.Analysis = EA_TextMaker(QE_Course);

end
