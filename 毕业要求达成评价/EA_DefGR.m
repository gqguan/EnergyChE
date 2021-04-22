function Requirements = EA_DefGR()
%% �����ҵҪ�����ݽṹ
%
% by Dr. Guan Guoqiang @ SCUT on 2020-07-08

load('database.mat', 'db_GradRequires', 'db_Indicators')

Indicator = struct('UniNum', '��1.1', ...
                   'Spec', '�ܡ���');
Requirement = struct('UniNum', '��1', ...
                     'Brief', '����֪ʶ', ...
                     'Spec', '�ܰ�������');

NumIdts = [4 4 3 4 3 2 2 3 3 3 3 2];

for iReq = 1:12
    Requirement.UniNum = sprintf('��%d', iReq);
    Requirement.Brief = db_GradRequires.Brief{iReq};
    Requirement.Spec = db_GradRequires.Spec{iReq};
    NumIdt = NumIdts(iReq);
    Indicators(1:NumIdt) = Indicator; % �ñ�ҵҪ���ָ����ʼ��
    for iIdt = 1:NumIdt
        Indicator.UniNum = sprintf('��%d.%d', iReq, iIdt);
        idxs = strcmp(db_Indicators.UniNum,Indicator.UniNum);
        if any(idxs)
            Indicator.Spec = db_Indicators.Spec{idxs};
        else
            fprintf('������ͨ��UniNum��db_Indicators���Ҳ���ƥ������ݣ�\n');
            return
        end
        Indicators(iIdt) = Indicator;
    end
    Requirement.Indicators = Indicators;
    Requirements(iReq) = Requirement;
    clear Indicators
end
