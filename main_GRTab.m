%% ��MS-WORD�����������ҵҪ���ָ����б������������3-1��
%
% by Dr. Guan Guoqiang @ SCUT on 2021-03-10

% ��������
fprintf('[��Ϣ] �����ҵҪ���б�\n')
if exist('db_GradRequires','var')
    fprintf('ʹ�õ�ǰ�����ռ��е�db_GradRequires\n')
else
    fprintf('ʹ�ô洢�ռ�����е�db_GradRequires\n')
    load('database.mat', 'db_GradRequires')
end
fprintf('[��Ϣ] �����ҵҪ��ָ����б�\n')
if exist('db_Indicators','var')
    fprintf('ʹ�õ�ǰ�����ռ��е�db_Indicators\n')
else
    fprintf('ʹ�ô洢�ռ�����е�db_Indicators\n')
    load('database.mat', 'db_Indicators')
end
% ��ʼ��
output = cell(36,2);
NumIndicators = [4 4 3 4 3 2 2 3 3 3 3 2]; % ����ҵҪ���е�ָ�����Ŀ
% ����ҵҪ����Ӧ��ָ����ı����������
iRow = 1;
for iGR = 1:12
    output{iRow,1} = sprintf('��%d��%s��%s',iGR,db_GradRequires{iGR,1},db_GradRequires{iGR,2});
    for iIndicator = 1:NumIndicators(iGR)
        output{iRow,2} = sprintf('%s %s',db_Indicators{iRow,1}{:},db_Indicators{iRow,2}{:});
        iRow = iRow+1;
    end
end
% �������������MS-WORD�б��
Tab2Word(output, {'��ҵҪ��' 'ָ���'}, '��ҵҪ��ָ���')