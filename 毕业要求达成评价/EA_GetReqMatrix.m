%% 导入电子表格中的“课程矩阵”数据并与存盘数据比较
% 用于从以下电子表格导入数据的脚本:
%
%    工作簿: C:\Users\gqgua\Documents\WXWork\1688853243457453\WeDrive\华南理工大学\能源化学工程专业\达成度分析小组\课程一览表.xlsx
%    工作表: 2014
%
% 要扩展代码以供其他选定数据或其他电子表格使用，请生成函数来代替脚本。

% 由 MATLAB 自动生成于 2020/07/09 10:09:46

function db_Curriculum = EA_GetReqMatrix(pathFile,worksheet,areaLoc)
if ~exist('pathFile','var')
    pathFile = 'C:\Users\gqgua\Documents\WXWork\1688853243457453\WeDrive\华南理工大学\能源化学工程专业\达成度分析小组\课程一览表.xlsx';
    worksheet = '2014';
    areaLoc = 'G4:AP59';
end
%% 导入“课程矩阵”
% 在微盘缺省目录位置读入指定的excel文件
[~, ~, raw] = xlsread(pathFile,worksheet,areaLoc);
ReqMatrix = reshape([raw{:}],size(raw));
% 清除临时变量
clearvars raw;

%% 导入存盘的“课程矩阵”数据
if exist('db_Curriculum','var')
    fprintf('【提示】采用工作空间中的db_Curriculum变量。\n')
else
    fprintf('【提示】从文件database.mat中导入db_Curriculum变量。\n')
    load('database.mat', 'db_Curriculum')
end

load('database.mat', 'db_Indicators')

%% 若需要可用导入数据更新存盘数据
% 比较课程矩阵尺寸
if isequal(size(ReqMatrix),size(db_Curriculum.ReqMatrix))
    fprintf('【提示】课程矩阵尺寸一致。\n')
else
    cprintf('err', '【错误】课程矩阵尺寸不一致！\n')
    return
end
% 按课程列表顺序比较指标点支撑关系是否与电子表格一致
NumCourse = height(db_Curriculum);
idxs_Updating = false(NumCourse,1);
for idx = 1:NumCourse
    if ~isequal(db_Curriculum.ReqMatrix(idx,:),ReqMatrix(idx,:))
        idxs_Updating(idx) = true;
        prompt1 = sprintf('课程%02d“%s”支撑指标点：', idx, db_Curriculum.Name{idx});
        cprintf('Comments', prompt1)
        idxs = find(db_Curriculum.ReqMatrix(idx,:)-ReqMatrix(idx,:));
        UniNums = db_Indicators.UniNum(idxs);
        prompt2 = '';
        for iUN = 1:length(UniNums)
            prompt2 = sprintf('%s%s、', prompt2, UniNums{iUN});
        end
        prompt2 = [prompt2(1:end-1) '未更新！\n'];
        cprintf('Text',prompt2)
    end
end
% 用户确认是否更新db_Curriculum中的课程矩阵
if any(idxs_Updating)
    flag1 = input('确认是否更新db_Curriculum中的课程矩阵[Y/N/A]','s');
    switch flag1
        case('Y')
            fprintf('逐个更新上述未更新课程\n')
            idxs_Updating = find(idxs_Updating);
            for idx = 1:length(idxs_Updating)
                iCourse = idxs_Updating(idx);
                prompt1 = sprintf('确认是否将课程%02d“%s”支撑指标点：', iCourse, db_Curriculum.Name{iCourse});
                cprintf('Comments', prompt1)
                UniNums_Old = db_Indicators.UniNum(logical(db_Curriculum.ReqMatrix(iCourse,:)));
                prompt2 = '';
                for iUN = 1:length(UniNums_Old)
                    prompt2 = sprintf('%s%s、', prompt2, UniNums_Old{iUN});
                end
                prompt2 = [prompt2(1:end-1) '更新为'];
                UniNums_New = db_Indicators.UniNum(logical(ReqMatrix(iCourse,:)));
                for iUN = 1:length(UniNums_New)
                    prompt2 = sprintf('%s%s、', prompt2, UniNums_New{iUN});
                end
                prompt2 = [prompt2(1:end-1) '[Y/N]'];
                flag2 = input(prompt2,'s');
                switch flag2
                    case('Y')
                        fprintf('已更新课程。\n')
                        db_Curriculum.ReqMatrix(iCourse,:) = ReqMatrix(iCourse,:);
                    case('N')
                        fprintf('不更新该课程。\n')
                end
            end
        case('N')
            fprintf('暂不更新上述未更新课程\n')
        case('A')
            fprintf('全部更新上述未更新课程\n')
            db_Curriculum.ReqMatrix(idxs_Updating,:) = ReqMatrix(idxs_Updating,:);
    end
else
    cprintf('Comments', 'database.mat中db_Curriculum的课程矩阵与Excel工作表一致。\n')
end
