%% ����γ̳ɼ���˵��
%
%  by Dr. GUAN Guoqiang @ SCUT on 2020/06/21

function Definition = ImportSpecification(FileName)
%% ��������趨
if nargin == 0 
    [FileName, PathName] = uigetfile('*.*', 'ѡȡ�ɼ�������Excel�ļ� ...', 'Multiselect', 'off');
else
    PathName = '�ɼ�������\';
end
% Note:
% When only one file is selected, uigetfile() will return the char variable
% and lead to the error in [FullPath{:}]. Use cellstr() to ensure the
% variable be as cell objects.
FileName = cellstr(FileName);
PathName = cellstr(PathName);

% �������Def_EvalTypes��Def_EvalWays
EA_Definition

%% ����ɼ���˵��
FullPath = strcat(PathName, FileName);

if exist(FullPath{:}, 'file') ~= 2
    % ���Խ��ļ���չ���޸�Ϊxlsx
    if FullPath{:}(end-2:end) == 'xls'
        FullPath = {[FullPath{:}(1:end-3),'xlsx']};
        if exist(FullPath{:}, 'file') ~= 2
            disp('������ȱʡλ���Ҳ�����Ӧ�ĳɼ�������')
            return
        end
    end
end

[~, ~, raw] = xlsread([FullPath{:}],'Sheet1');
raw(cellfun(@(x) ~isempty(x) && isnumeric(x) && isnan(x),raw)) = {''};
% HeadTitles = raw(1,:);
raw = raw(2:end,:);
indices_type = cell2mat(cellfun(@(x) ~isempty(x), raw(:,1), 'UniformOutput', false));
% �����������ݵÿ��˷�ʽ��������
Spec = zeros(1,sum(indices_type));
iSpec = 0;
for iIdx = 1:length(indices_type)
    if indices_type(iIdx) == 1
        iSpec = iSpec+1;
        NumWays = 0;
    end
    NumWays = NumWays+1;
    Spec(iSpec) = NumWays;
end
% �ɼ�������
TypeDescriptions = raw(indices_type,1);
TypeCodes = {'A' 'B' 'C' 'D' 'E' 'F' 'G' 'H'};
TypeWeights = raw(indices_type,2);
EvalTypes = Def_EvalTypes;
BeginRow = 1;
for iType = 1:length(Spec)
    EvalTypes(iType).Description = TypeDescriptions{iType};
    EvalTypes(iType).Code = TypeCodes{iType};
    EvalTypes(iType).Weight = TypeWeights{iType};
    EvalWays = Def_EvalWays;
    EndRow = BeginRow+Spec(iType)-1;
    WayDescriptions = raw(BeginRow:EndRow,3);
    WayWeights = raw(BeginRow:EndRow,4);
    WayFullCredits = raw(BeginRow:EndRow,5);
    for iWay = 1:Spec(iType)
        EvalWays(iWay).Description = WayDescriptions{iWay};
        EvalWays(iWay).Weight = WayWeights{iWay};
        EvalWays(iWay).Code = [TypeCodes{iType},num2str(iWay)];
        EvalWays(iWay).FullCredit = WayFullCredits{iWay};
    end
    BeginRow = EndRow+1;
    EvalTypes(iType).EvalWays = EvalWays;
end
Definition.EvalTypes = EvalTypes;
Definition.Spec = Spec;

end
