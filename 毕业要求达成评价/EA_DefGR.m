function Requirements = EA_DefGR()
%% 定义毕业要求数据结构
%
% by Dr. Guan Guoqiang @ SCUT on 2020-07-08

load('database.mat', 'db_GradRequires', 'db_Indicators')

Indicator = struct('UniNum', '№1.1', ...
                   'Spec', '能……');
Requirement = struct('UniNum', '№1', ...
                     'Brief', '工程知识', ...
                     'Spec', '能巴拉巴拉');

NumIdts = [4 4 3 4 3 2 2 3 3 3 3 2];

for iReq = 1:12
    Requirement.UniNum = sprintf('№%d', iReq);
    Requirement.Brief = db_GradRequires.Brief{iReq};
    Requirement.Spec = db_GradRequires.Spec{iReq};
    NumIdt = NumIdts(iReq);
    Indicators(1:NumIdt) = Indicator; % 该毕业要求的指标点初始化
    for iIdt = 1:NumIdt
        Indicator.UniNum = sprintf('№%d.%d', iReq, iIdt);
        idxs = strcmp(db_Indicators.UniNum,Indicator.UniNum);
        if any(idxs)
            Indicator.Spec = db_Indicators.Spec{idxs};
        else
            fprintf('【错误】通过UniNum在db_Indicators中找不到匹配的内容！\n');
            return
        end
        Indicators(iIdt) = Indicator;
    end
    Requirement.Indicators = Indicators;
    Requirements(iReq) = Requirement;
    clear Indicators
end
