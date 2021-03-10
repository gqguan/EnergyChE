%% 在MS-WORD中输出“各毕业要求的指标点列表”（自评报告表3-1）
%
% by Dr. Guan Guoqiang @ SCUT on 2021-03-10

% 载入数据
fprintf('[信息] 载入毕业要求列表！\n')
if exist('db_GradRequires','var')
    fprintf('使用当前工作空间中的db_GradRequires\n')
else
    fprintf('使用存储空间变量中的db_GradRequires\n')
    load('database.mat', 'db_GradRequires')
end
fprintf('[信息] 载入毕业要求指标点列表！\n')
if exist('db_Indicators','var')
    fprintf('使用当前工作空间中的db_Indicators\n')
else
    fprintf('使用存储空间变量中的db_Indicators\n')
    load('database.mat', 'db_Indicators')
end
% 初始化
output = cell(36,2);
NumIndicators = [4 4 3 4 3 2 2 3 3 3 3 2]; % 各毕业要求中的指标点数目
% 将毕业要求及相应的指标点文本填入胞矩阵
iRow = 1;
for iGR = 1:12
    output{iRow,1} = sprintf('№%d（%s）%s',iGR,db_GradRequires{iGR,1},db_GradRequires{iGR,2});
    for iIndicator = 1:NumIndicators(iGR)
        output{iRow,2} = sprintf('%s %s',db_Indicators{iRow,1}{:},db_Indicators{iRow,2}{:});
        iRow = iRow+1;
    end
end
% 将胞矩阵输出到MS-WORD中表格
Tab2Word(output, {'毕业要求' '指标点'}, '毕业要求指标点')