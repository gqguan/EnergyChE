%% 达成度分析脚本
%
% by Dr. Guan Guoqiang @ SCUT on 2020/6/29

%% 导入课程详细成绩单
% 批量导入
dataset_New = ImportTranscripts(1);
dataset_Updated = dataset_New;
% 提取导入成绩单的年级
Years = cellfun(@(x) ['class',x], categories(categorical({dataset_New.Class})), ...
                'UniformOutput', false);
% 添加到database.mat中的dataset1
load('database.mat', 'dataset1')
% 删除与数据库中一致的成绩单
idxFound = false(1,length(dataset1));
for iCourse = 1:length(dataset_New)    
    idxFound = idxFound|arrayfun(@(x) isequal(dataset_New(iCourse),x), dataset1);
    if any(idxFound)
        fprintf('【警告】发现dataset1中已有%s级课程“%s”成绩单！\n', ...
                dataset_New(iCourse).Class,dataset_New(iCourse).Course)
        dataset_Updated(1) = [];
    end
end
if ~isempty(dataset_Updated)
    dataset1 = [dataset1,dataset_Updated];
    save('database.mat', '-append', 'dataset1')
else
    fprintf('没有导入新的成绩单。\n')
    opt = input('是否使用database.mat中的dataset1变量进行达成度计算[输入1（继续）/其他数字（终止）]？');
    switch opt
        case(1)
            fprintf('继续进行达成度计算。\n')
        otherwise
            fprintf('终止程序！\n')
            return
    end
end

%% 按课程表整理数据
% db_Outcome1 = GetData(Years,1);

%% 进行达成度计算
for iCourse = 1:length(dataset_New)
    CourseName = dataset_New(iCourse).Course;
    Class = ['class',dataset_New(iCourse).Class];
    fprintf('正在进行%s级课程“%s”达成度计算...\n',Class(6:end),CourseName)
    % 计算达成度
    QE_Course = EA_Course(CourseName, Class);
    % 填入从db_Course变量中找到的与课程名称匹配的教学目标和分析文本
    if ~exist('db_Course', 'var')
        load('database.mat', 'db_Course')
    end
    idxFound = strcmp({db_Course.Name}, CourseName);
    if any(idxFound)
        fprintf('从课程信息库中载入“教学目标”和“分析文本”。\n')
        Objectives = db_Course(idxFound).Objectives;
        Analysis = db_Course(idxFound).(Class).Analysis;
        QE_Course = EA_FillText(QE_Course, Objectives, Analysis);
    end
    % 存入已进行达成度分析的课程库
    [QE_Courses,QE_Courses_original,QE_Courses_MultiRepeated] = EA_SaveQE(QE_Course);
end
% 更新QE_Courses
fprintf('更新QE_Courses.mat。\n')
save('QE_Courses.mat', '-append', 'QE_Courses')