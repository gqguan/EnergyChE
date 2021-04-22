%% �γ��������ۣ���ѧ���ݵ��ۺϿ��˽��
%
% by Dr. Guan Guoqiang @ SCUT on 2020-08-26

function EA_Content = EA_EvalMethod1(QE_Course)

% �������������ڽ�ѧ���ݺͿ��˷����Ĺ�ϵ����C2W
if ~any(strcmp(fieldnames(QE_Course.RelMatrix),'C2W'))
    cprintf('err','����������������Ҳ�����ѧ���ݺͿ��˷����Ĺ�ϵ����C2W��\n')
    return
end
C2W = QE_Course.RelMatrix.C2W;

% ��ʼ��
NumContent = size(C2W,1);
EA_Content = zeros(NumContent,1);

% ��ȡ���˷�ʽ������������ֵ������Ȩ������
Codes = cell(1,sum(QE_Course.Transcript.Definition.Spec));
FullCredits = zeros(size(Codes));
Weights = zeros(size(Codes));
NumType = length(QE_Course.Transcript.Definition.Spec);
iCode_Begin = 1;
for iType = 1:NumType
    iCode_End = iCode_Begin+QE_Course.Transcript.Definition.Spec(iType)-1;
    Codes(iCode_Begin:iCode_End) = {QE_Course.Transcript.Definition.EvalTypes(iType).EvalWays.Code};
    FullCredits(iCode_Begin:iCode_End) = [QE_Course.Transcript.Definition.EvalTypes(iType).EvalWays.FullCredit];
    Weights(iCode_Begin:iCode_End) = [QE_Course.Transcript.Definition.EvalTypes(iType).EvalWays.Weight];
    Weights = Weights*QE_Course.Transcript.Definition.EvalTypes(iType).Weight; % �ÿ�������Ȩ������
    iCode_Begin = iCode_End+1;
end

% ���˵÷���
Credits = mean(QE_Course.Transcript.Detail{:,Codes})./FullCredits;

% �ֱ�Ը���ѧ���ݽ��м�Ȩƽ��
for iContent = 1:NumContent
    idxs = logical(C2W(iContent,:));
    CorrectedWeights = Weights(idxs)./sum(Weights(idxs));
    EA_Content(iContent) = sum(Credits(idxs).*CorrectedWeights);
end