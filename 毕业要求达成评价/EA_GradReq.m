%% 毕业要求达成度计算
%
% 功能说明：
% （1）基于db_Curriculum中的课程矩阵，按毕业要求整理为列出相应的必修课程
% （2）导入相应课程对应的指标点达成度分析结果
% （3）以“某课程的学分/该指标点全部课程的总学分”为权重
% （4）计算各指标点的加权平均值
%
% 结果输出
% output - （结构向量）
%   Contents - （胞元矩阵）内容
%   Heads - （胞元矩阵）表头
% （1）各毕业要求指标点及其支撑课程列表、相应指标的课程达成度、指标点达成度和毕业要求达成度结果
% （2）毕业要求达成情况评价依据表
%
% by Dr. Guan Guoqiang @ SCUT on 2020-07-08

function output = EA_GradReq(QE_Courses,db_Curriculum)
%% 初始化
% 检查当前工作空间中存在所需的数据
if ~exist('QE_Courses','var') % 课程目标达成度数据
    cprintf('Comments','从文件QE_Courses.mat中导入“QE_Courses”变量。\n')
    load('QE_Courses.mat','QE_Courses')
end
if ~exist('db_Curriculum','var') % 课程列表
    cprintf('Comments','从文件database.mat中导入“db_Curriculum”变量。\n')
    load('database.mat','db_Curriculum')
end
if ~exist('db_Indicators','var') % 课程列表
    cprintf('Comments','从文件database.mat中导入“db_Indicators”变量。\n')
    load('database.mat','db_Indicators')
end
% 初始化输出变量
tout1 = cell(sum(sum(db_Curriculum.ReqMatrix)),8);
t1head = {'毕业要求' '毕业要求指标点' '支撑课程' '学分' '权重' '课程目标达成度' '指标点达成度' '毕业要求达成度'};
tout2 = cell(sum(sum(db_Curriculum.ReqMatrix)),7);
t2head = {'毕业要求' '观测点' '用于评价的教学环节' '评价方法' '评价依据' '评价责任人' '形成的记录档案'};

iRow = 1; % tout1和tout2表的行号

%% 获得指定年级的已完成达成度分析的课程列表
% 输入年级
Class = input('输入进行毕业要求达成度计算年级', 's');
% 筛选指定年级的已完成达成度分析的课程列表
QE_Courses1 = QE_Courses(strcmp({QE_Courses.Class},Class));

%% 功能（1）
% 获得完整毕业要求
ReqLists = EA_DefGR;
for iReq = 1:length(ReqLists)
    iRowGR = iRow; % 表tout2中的毕业要求行
    Content1 = sprintf('%d %s', iReq, ReqLists(iReq).Brief);
    tout1{iRow,1} = Content1;
    tout2{iRow,1} = tout1{iRow,1};
    NumIdt = length(ReqLists(iReq).Indicators);
    QEIndicators = zeros(NumIdt,1);
    for iIdt = 1:NumIdt
        Content2 = sprintf('%s %s', ReqLists(iReq).Indicators(iIdt).UniNum, ReqLists(iReq).Indicators(iIdt).Spec);
        tout1{iRow,2} = Content2;
        tout2{iRow,2} = tout1{iRow,2};
        UniNum = ReqLists(iReq).Indicators(iIdt).UniNum;
        idxs = strcmp(db_Indicators.UniNum,UniNum);
        if sum(idxs) == 1
            idx_Courses = db_Curriculum.ReqMatrix(:,idxs);
            Courses = db_Curriculum.Name(logical(idx_Courses)); % 列出该指标点的全部支撑课程名称（胞列向量）
            IDs = db_Curriculum.ID(logical(idx_Courses)); % 列出该指标点的全部支撑课程代码（胞列向量）
            Credits = db_Curriculum.Credit(logical(idx_Courses)); % 列出该指标点的全部支撑课程学分（数值列向量）
            CourseWeights = Credits/sum(Credits); % 计算该指标点的全部支撑课程权重（数值列向量）
            QECourses = zeros(size(Courses)); % 初始化各支撑课程的教学目标达成结果
            EvalMethods = cell(size(Courses)); % 初始化tout2中各支撑课程（即评价的教学环节）的评价方法
            EvalBasises = cell(size(Courses)); % 初始化tout2中各评价环节的依据
            Teachers = cell(size(Courses)); % 初始化tout2中各评价环节的责任人
            Documents = cell(size(Courses)); % 初始化tout2中各评价环节的形成记录档案
            % 载入课程达成度结果
            for iCourse = 1:length(QECourses)
%                 Credits{iCourse} = db_Curriculum.Credit(strcmp(db_Curriculum.Name,Courses(iCourse)));
                EvalMethods{iCourse} = '成绩分析法';
                EvalBasises{iCourse} = '课程目标达成度';
                Teachers{iCourse} = db_Curriculum.Teacher(strcmp(db_Curriculum.Name,Courses(iCourse)));
                Documents = {'课程目标达成度报告'};
                idx_QECourses = strcmp({QE_Courses1.Name}, Courses(iCourse))|...
                                strcmp({QE_Courses1.ID}, IDs(iCourse));
                if any(idx_QECourses)
                    % 根据IdxUniNum获得UniNum
                    UniNumLists = db_Indicators.UniNum([QE_Courses1(idx_QECourses).Requirements.IdxUniNum]);
                    idx_Req = strcmp(UniNumLists,UniNum);
                    if any(idx_Req)
                        QECourses(iCourse) = QE_Courses1(idx_QECourses).Requirements(idx_Req).Result;
                    else
                        cprintf('err','【错误】课程“%s”指标点不匹配！\n',Courses{iCourse});
                    end
                else
                    fprintf('【警告】已完成达成度分析的课程中没有“%s”！\n',Courses{iCourse})
                end
            end
        end
        QEIndicators(iIdt) = CourseWeights'*QECourses;
        iRowEnd = iRow+length(Courses)-1;
        tout1(iRow:iRowEnd,3) = Courses;
        tout1(iRow:iRowEnd,4) = num2cell(Credits);
        tout1(iRow:iRowEnd,5) = cellfun(@(x) sprintf('%.3f',x), num2cell(CourseWeights), 'UniformOutput', false);
        tout1(iRow:iRowEnd,6) = cellfun(@(x) sprintf('%.3f',x), num2cell(QECourses), 'UniformOutput', false);
        tout1(iRow,7) = cellfun(@(x) sprintf('%.3f',x), num2cell(QEIndicators(iIdt)), 'UniformOutput', false);
        tout2(iRow:iRowEnd,3) = Courses;
        tout2(iRow:iRowEnd,4) = EvalMethods;
        tout2(iRow:iRowEnd,5) = EvalBasises;
        tout2(iRow:iRowEnd,6) = Teachers;
        tout2(iRow:iRowEnd,7) = Documents;
        iRow = iRowEnd+1;
    end
    tout1{iRowGR,8} = sprintf('%.3f',mean(QEIndicators));
end

%% 输出结果
%
output(1).TableName = sprintf('毕业要求达成度结果表_%s',Class);
output(1).TableType = '毕业要求达成度结果表';
output(1).Contents = tout1;
output(1).Heads = t1head;
%
output(2).TableName = sprintf('毕业要求评价依据表_%s',Class);
output(2).TableType = '毕业要求评价依据表';
output(2).Contents = tout2;
output(2).Heads = t2head;