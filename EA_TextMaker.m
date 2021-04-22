%% ��ɶȷ����ı�ģ��
%
% by Dr. Guan Guoqiang @ SCUT on 2020-06-24

function txtout = EA_TextMaker(QE_Course)
%% ��ʼ��
Name = QE_Course.Name;
NumReq = length(QE_Course.Requirements);
Class = QE_Course.Class;
QEValue = QE_Course.Result;

%% ����ģ���ı�
% ȷ���γ̶�רҵ�˲����������������ֶ�
if NumReq < 3
    FeatureClass = '����';
elseif NumReq < 6
    FeatureClass = '��Ҫ';
else
    FeatureClass = 'ʮ����Ҫ';
end       

% ȷ���γ̽�ѧ���������ֶ�
if QEValue < 0.6
    QELevel = '������';
elseif QEValue < 0.7
    QELevel = 'һ��';
elseif QEValue < 0.8
    QELevel = '����';
elseif QEValue < 0.9
    QELevel = '�Ϻ�';
else
    QELevel = '����';
end   

% �γ�ñ��
Head = sprintf('%s����Դ����רҵ�ı��޿Ρ�', Name);
% �γ̶�רҵ�˲�����������
Feature = sprintf('���γ�֧����%d��ָ��㣬�Ա�רҵ�˲���������%s�����á�', ...
                  NumReq, FeatureClass);
% �γ̽��
Result = sprintf('���ϱ����У�%s����Դ����רҵ��ͬѧ�ڱ��γ��е��ܴ�ɶ�Ϊ%.3f��', ...
                  Class, QEValue);
Result = [Result, sprintf('�ɴ�˵�����γ̽�ѧ������%s��', QELevel)];
if NumReq >= 3
    ReqEAValues = [QE_Course.Requirements.Result];
    % �Ϻõķ���
    [BestEAValue,BestReqIdx] = max(ReqEAValues);
    Result = [Result, sprintf('������ָ��㡰%s���Ĵ�ɶ�Ϊ��ߵ�%.3f��', ...
                              QE_Course.Requirements(BestReqIdx).Description, BestEAValue)];
    Result = [Result, sprintf('˵����ѧĿ�ꡰ%s����ɵýϺã�', ...
                              QE_Course.Requirements(BestReqIdx).Objectives.Description)];
    % �ϲ�ķ���
    [WorstEAValue,WorstReqIdx] = min(ReqEAValues);
    Result = [Result, sprintf('��ָ��㡰%s���Ĵ�ɶȵ÷�Ϊ�ϵ͵�%.3f��', ...
                             QE_Course.Requirements(WorstReqIdx).Description, WorstEAValue)];
    Result = [Result, sprintf('��ӳ�˽�ѧĿ�ꡰ%s����Ҫ��һ����ǿ', ...
                              QE_Course.Requirements(WorstReqIdx).Objectives.Description)];
end

% �����Ľ���ʩ
Improvement = sprintf('��ͨ���μ��̸���Ժ�����������γ̽�ѧӦ����ǿ�����С��̸ġ�');

%% ����ϳ��ֶ�
txtout = [Head, Feature, Result, Improvement]; 

end