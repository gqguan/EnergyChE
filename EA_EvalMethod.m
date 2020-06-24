%% ���ݽ�ѧĿ���뿼�����ݵĹ�ϵ�����쿼�˷���
%
% by Dr. Guan Guoqiang @ SCUT on 2020/6/22

function QE_Course = EA_EvalMethod(QE_Course)
%% ��ʼ��
Requirements = QE_Course.Requirements;
NumReq = length(Requirements);
Obj2Content = QE_Course.RelMatrix.Obj2Content;
Spec = QE_Course.Transcript.Definition.Spec;
Def_EvalTypes = QE_Course.Transcript.Definition.EvalTypes;
% ��ȡ���˷�ʽ��������
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

%% ����ɼ����и����˷�ʽ��ƽ���÷�
Transcript = QE_Course.Transcript.Detail;
% ���б�����ѡ������
VarNames = Transcript.Properties.VariableNames;
Indices_SelectedCols = false(size(VarNames));
for iWayCode = 1:length(WayCodes)
    Indices_CurrentCols = strcmp(WayCodes{iWayCode},VarNames);
    Indices_SelectedCols = Indices_SelectedCols|Indices_CurrentCols;
end
% ����ƽ��ֵ
Scores = Transcript{:,Indices_SelectedCols};
switch class(Scores)
    case('cell')
        AvgTable = array2table(mean(cell2mat(Scores)), ...
                               'VariableNames', VarNames(Indices_SelectedCols));
    case('double')
        AvgTable = array2table(mean(Scores), ...
                               'VariableNames', VarNames(Indices_SelectedCols));
end
%% ˳�ζԸ�ָ��㹹�쿼�˷��������д�ɶȼ���
for iReq = 1:NumReq
    Objectives = Requirements(iReq).Objectives;
    NumObj = length(Objectives);
    Sum_Credit = zeros(1,NumObj);
    Sum_FullCredit = zeros(1,NumObj);
    for iObj = 1:NumObj
        EvalTypes = Objectives(iObj).EvalTypes;           
        % ��øý�ѧĿ��Ŀ��˷�ʽ����
        Indices = Obj2Content(iReq,:);
        % ��Spec��ȡ���࿼�˵���ط�ʽ
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
        % ���������˷�ʽ��Ȩ��ֵ
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
                % �ӳɼ����л�ȡ����˷�ʽ�ĵ÷�
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
        Objectives(iObj).Weight = 1; % һ����ѧĿ���Ӧ��һ����ҵҪ��ָ���
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
