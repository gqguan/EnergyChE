%% 生成全部课程的达成度分析Excel模板
%
% by Dr. Guan Guoqiang @ SCUT on 2020/6/10
%

%% 初始化
% 读取课程列表
clear;
Years = {'class2015'}; % 该值为进行毕业要求达成度计算的学生年级
% Get data for processing
year = Years{:};
msg_str = sprintf('从保存工作区database.mat中导入 %s 数据', year);
Setlog(msg_str, 3);
[db_Outcome, db_Curriculum, db_GradRequire] = GetData(Years);

%% 构建课程目标说明表
% 列出对每门课程的毕业要求指标点
NumCourse = length(db_Outcome);
for course_sn = 1:NumCourse
    idx_UniNum = find(db_Curriculum.ReqMatrix(course_sn,:)); % 课程支撑指标点编号向量
    M = length(idx_UniNum); % 课程支撑的指标点数目
    % 假定通过考试和平时两个环节考核，各环节权重分别为0.7和0.3
    EvalMethod.Name = {'Exam','Regular'};
    EvalMethod.Weight = ones(M,1)*[0.7,0.3];
    % 构建课程目标说明表：毕业要求指标点，教学目标，考试和平时两个考核环节的权重
    CO_description = [db_GradRequire(idx_UniNum,:),...
                      cell2table(cell(M,1),'VariableNames',{'Objective'}),...
                      array2table(EvalMethod.Weight,'VariableNames',EvalMethod.Name)];
end

%% 构建各考核环节的学生成绩单

%% 构建达成度分析表