%% 生成本年度应提交课程评价原始材料的课程列表
%
% by Dr. Guan Guoqiang @ SCUT on 2023/11/22

function [courseList,log] = ListCourses(currentYear,filePath)
    % 输入参数检查；将输入变量currentYear转为数值
    if ~exist('currentYear','var')
        currentYear = "2023"; % 缺省值为2022-2023学年
    end
    if ~exist('filePath','var')
        filePath = 'D:\Repo';
    end
    switch class(currentYear)
        case({'string','char'})
            currentYear = str2num(currentYear);
            courseList = "";
        otherwise
            error('输入参数类型应为字符或字符串！')
    end
    classList = string([currentYear-4:currentYear-1]);
    classYear = strcat(num2str(currentYear-1),'-',num2str(currentYear),'学年'); % 学年字段
    % 初始化表变量courseList
    load('database.mat','db_Curriculum2021');
    courseList = db_Curriculum2021(:,[1:5,8]); courseList(:,:) = []; % 注意2021年培养方案课程表变量中第8列（Remark）存有是否需要提交备案标记
    courseList.Indicator = cell(height(courseList),1);
    courseList.Class = string([]);
    % 在courseList中存入各年级上、下学期的课程
    for i = 1:length(classList)
        switch classList{i}
            case({'2017','2018'})
                curriculumYear = '2017';
            case({'2019','2020'})
                curriculumYear = '2019';
            case({'2021','2022'})
                curriculumYear = '2021';
            case({'2023','2034'})
                curriculumYear = '2023';
            otherwise
                error('database.mat中无%s年级学生相应的培养方案数据！',classList{i})
        end
        curriculumName = sprintf('db_Curriculum%s',curriculumYear);
        indicatorName = sprintf('db_Indicators%s',curriculumYear);
        load('database.mat',curriculumName,indicatorName)
        log = sprintf('从%s中载入%s年课程表%s及指标点列表%s',...
            which('database.mat'),classList{i},curriculumName,indicatorName);
        curriculum = eval(curriculumName);
        indicators = eval(indicatorName);
        % 2019年培养方案的课程表用字段TypeID标识课程类型、没有字段Email且指标点数目不同于2021年
        if strcmp(curriculumYear,'2019')
            curriculum.TypeID = arrayfun(@(x)Type2ID(x),db_Curriculum2019.TypeID);
            curriculum = renamevars(curriculum,"TypeID","Type");
        end
        idx1 = strcmp(curriculum.Semester,string((5-i)*2-1))|...
            strcmp(curriculum.Semester,string((5-i)*2)); % 例如胞向量classList第1个分量为4年级，对应为第7、8学期
        reqMatrix = curriculum.ReqMatrix; reqMatrix = reqMatrix(idx1,:);
        idxMat = mat2cell(reqMatrix,ones(size(reqMatrix,1),1));
        Indicator = cellfun(@(x)table2cell(indicators(logical(x),1:2)),idxMat,'UniformOutput',false);
        Indicator = cellfun(@(x)CombineRow(x),Indicator);
        Class = arrayfun(@(x)strcat(classList{i},"级"),(1:size(reqMatrix,1))');
        courseList = [courseList;[curriculum(idx1,[1:5,end]),table(Indicator)],table(Class)];
        courseList = courseList(contains(courseList.Remark,"提交备案"),:);
    end    
    % 在courseList中添加“课程负责人”列
    courseList.Teacher = arrayfun(@(x)string,(1:height(courseList))');
    % 输出excel文件供教务通知给相应课程负责人
    filename1 = fullfile(filePath,sprintf('%s能化专业报备课程列表.xlsx',classYear));
    courseList = courseList(:,[9 8 3 1 2 4 5 7 6]); % 调整输出表格各列顺序
    writetable(courseList,filename1)
    % 生成CollectMaterial.mlapp所需的FileListXXXX.xlsx
    FileList = cellstr(courseList.Class+"《"+courseList.Name+"》");
    FileList(:,2:6) = {"-"};
    filename2 = fullfile(filePath,sprintf('FileList%d.xlsx',currentYear));
    writecell(FileList,filename2)