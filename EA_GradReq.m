%% 毕业要求达成度计算
%
% 功能说明：
% （1）基于db_Curriculum中的课程矩阵，按毕业要求整理为列出相应的必修课程
% （2）导入相应课程对应的指标点达成度分析结果
% （3）以“某课程的学分/该指标点全部课程的总学分”为权重
% （4）计算各指标点的加权平均值
%
% by Dr. Guan Guoqiang @ SCUT on 2020-07-08

%% 初始化
% 检查当前工作空间中存在所需的数据
if ~exist('QE_Courses','var') % 课程目标达成度数据
    load('QE_Courses.mat','QE_Courses')
end
if ~exist('db_Curriculum','var') % 课程列表
    load('database.mat','db_Curriculum')
end
if ~exist('db_Indicators','var') % 课程列表
    load('database.mat','db_Indicators')
end
% 初始化输出变量
tout = cell(sum(sum(db_Curriculum.ReqMatrix)),6);

iRow = 1;

%% 获得指定年级的已完成达成度分析的课程列表
% 输入年级
Class = input('输入进行毕业要求达成度计算年级', 's');
% 筛选指定年级的已完成达成度分析的课程列表
QE_Courses1 = QE_Courses(strcmp({QE_Courses.Class},Class));

%% 功能（1）
% 获得完整毕业要求
ReqLists = EA_DefGR;
for iReq = 1:length(ReqLists)
    tout{iRow,1} = ReqLists(iReq).Brief;
    NumIdt = length(ReqLists(iReq).Indicators);
    for iIdt = 1:NumIdt
        tout{iRow,2} = ReqLists(iReq).Indicators(iIdt).Spec;
        UniNum = ReqLists(iReq).Indicators(iIdt).UniNum;
        idxs = strcmp(db_Indicators.UniNum,UniNum);
        if sum(idxs) == 1
            idx_Courses = db_Curriculum.ReqMatrix(:,idxs);
            CourseLists = db_Curriculum.Name(logical(idx_Courses));
            CreditLists = cell(size(CourseLists));
            ResultLists = cell(size(CourseLists));
            % 载入课程达成度结果
            for iCourse = 1:length(ResultLists)
                CreditLists{iCourse} = db_Curriculum.Credit(strcmp(db_Curriculum.Name,CourseLists(iCourse)));
                idx_QECourses = strcmp({QE_Courses1.Name}, CourseLists(iCourse));
                if any(idx_QECourses)
                    % 根据IdxUniNum获得UniNum
                    UniNumLists = db_Indicators.UniNum([QE_Courses1(idx_QECourses).Requirements.IdxUniNum]);
                    idx_Req = strcmp(UniNumLists,UniNum);
                    if any(idx_Req)
                        ResultLists{iCourse} = QE_Courses1(idx_QECourses).Requirements(idx_Req).Result;
                    else
                        fprintf('【错误】指标点不匹配！\n');
                    end
                else
                    fprintf('【警告】已完成达成度分析的课程中没有“%s”！\n',CourseLists{iCourse})
                end

            end
        end
        iRowEnd = iRow+length(CourseLists)-1;
        tout(iRow:iRowEnd,3) = CourseLists;
        tout(iRow:iRowEnd,4) = CreditLists;
        tout(iRow:iRowEnd,5) = ResultLists;
        iRow = iRowEnd+1;
    end
end