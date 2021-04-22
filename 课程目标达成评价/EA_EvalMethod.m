%% ���ݽ�ѧĿ���뿼�����ݵĹ�ϵ�����쿼�˷���
%
% by Dr. Guan Guoqiang @ SCUT on 2020/6/22

function QE_Course = EA_EvalMethod(QE_Course)
%% ��ʼ��
Requirements = QE_Course.Requirements;
NumReq = length(Requirements);
Obj2Way = QE_Course.RelMatrix.Obj2Way;
Spec = QE_Course.Transcript.Definition.Spec;
Def_EvalTypes = QE_Course.Transcript.Definition.EvalTypes;
% ��ȡ���˷�ʽ��������
TypeCodes = cell(1,length(Def_EvalTypes));
WayCodes = cell(1,size(Obj2Way,2));
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
if iscell(Scores)
    switch class(Scores{1,1})
        case('char')
    %         AvgTable = array2table(mean(cell2mat(Scores)), ...
    %                                'VariableNames', VarNames(Indices_SelectedCols));
            Scores = cellfun(@(x) str2double(x), Scores);
        case('double')      
    end
end
AvgTable = array2table(mean(Scores), 'VariableNames', VarNames(Indices_SelectedCols));
%% ˳�ζԸ�ָ��㹹�쿼�˷��������д�ɶȼ���
% ���ɼ�������͹�ϵ����Obj2Way�������ݽṹ
NRow = 1;
tdata = {};
for iReq = 1:NumReq
    tdata{NRow,1} = Requirements(iReq).Description;
    Objectives = Requirements(iReq).Objectives;
    NumObj = length(Objectives);
    for iObj = 1:NumObj
        tdata{NRow,2} = Objectives(iObj).Description;
        EvalTypes = Objectives(iObj).EvalTypes;           
        % ��øý�ѧĿ��Ŀ��˷�ʽ����
        Indices = Obj2Way(iReq,:);
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
        for iType = 1:length(EvalTypes)
            tdata{NRow,3} = EvalTypes(iType).Description;
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
                tdata{NRow,4} = EvalTypes(iType).EvalWays(iWay).Description;
                tdata{NRow,5} = Weight;
                tdata{NRow,6} = Credit;
                tdata{NRow,7} = FullCredit;
                tdata{NRow,8} = Credit/FullCredit;
                NRow = NRow+1;
            end
        end
        Objectives(iObj).Weight = 1; % һ����ѧĿ���Ӧ��һ����ҵҪ��ָ���
    end
    Requirements(iReq).Objectives = Objectives;
end
% ���������۷�ʽ�ķ�ֵ
CorrectedFullCredit = cell2mat(tdata(:,5))/sum(cell2mat(tdata(:,5)))*100;
tdata(:,9) = num2cell(CorrectedFullCredit);
tdata(:,10) = num2cell(CorrectedFullCredit.*cell2mat(tdata(:,8)));
% �����ָ���Ĵ�ɶ�
RowIdx = tdata(:,1); % ָ���������
NumRow = length(RowIdx);
RowIdx = find(cellfun(@(x) ischar(x), RowIdx));
RowIdx = [RowIdx;NumRow];
for iRow = 1:(length(RowIdx)-1)
    if RowIdx(iRow) == RowIdx(iRow+1)
        SpanIdx = RowIdx(iRow);
    else
        SpanIdx = RowIdx(iRow):(RowIdx(iRow+1)-1);
    end
    Requirements(iRow).Result = sum(cell2mat(tdata(SpanIdx,10))) ...
                                /sum(cell2mat(tdata(SpanIdx,9)));
    tdata(RowIdx(iRow),11) = {Requirements(iRow).Result};
end

%% ���
% �����۷�ʽ��������ֵ�͵÷�
iRow = 1;
for iReq = 1:NumReq
    Objectives = Requirements(iReq).Objectives;
    NumObj = length(Objectives);
    for iObj = 1:NumObj
        EvalTypes = Objectives(iObj).EvalTypes;
        NumType = length(EvalTypes);
        for iType = 1:NumType
            EvalWays = EvalTypes(iType).EvalWays;
            NumWay = length(EvalWays);
            for iWay = 1:NumWay
                EvalWays(iWay).Correction.FullCredit = tdata{iRow,9};
                EvalWays(iWay).Correction.Credit = tdata{iRow,10};
                iRow = iRow+1;
            end
            EvalTypes(iType).EvalWays = EvalWays;
        end
        Objectives(iObj).EvalTypes = EvalTypes;
    end
    Requirements(iReq).Objectives = Objectives;
end
QE_Course.Requirements = Requirements;
QE_Course.Result = sum(cell2mat(tdata(:,10)))/100;
QE_Course.Analysis = EA_TextMaker(QE_Course);
QE_Course.Output = tdata;

end
