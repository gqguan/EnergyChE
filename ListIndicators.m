%% 在课程列表后生成所支撑的毕业要求指标编号栏
%
% by Dr. Guan Guoqiang @ SCUT on 2021/4/26

%% 初始化
clear
cCourseList = 'db_Curriculum2021a';
sCourseList = 'db_Curriculum2021b';
% 载入必修和选修课程
load('database.mat',cCourseList)
load('database.mat',sCourseList)
% 载入指标点
load('database.mat','db_Indicators2021')
db_Indicators = db_Indicators2021;

%% 按必修课表列出相应支撑的指标点编号
supportIndicator = string;
for iCourse = 1:height(eval(cCourseList))
    idx = logical(eval(cCourseList).ReqMatrix(iCourse,:));
    UniNums = db_Indicators.UniNum(idx);
    content = string;
    for i = 1:length(UniNums)
        if i == 1
            content = sprintf('%s %s', content, UniNums{i});
        else
            content = sprintf('%s, %s', content, UniNums{i});
        end
    end
    supportIndicator(iCourse,1) = content;
end
cList1 = eval(cCourseList);
cList1 = [cList1(:,2:3),table(supportIndicator)];

%% 按选修课表列出相应支撑的指标点编号
supportIndicator = string;
for iCourse = 1:height(eval(sCourseList))
    idx = logical(eval(sCourseList).ReqMatrix(iCourse,:));
    UniNums = db_Indicators.UniNum(idx);
    content = string;
    for i = 1:length(UniNums)
        if i == 1
            content = sprintf('%s %s', content, UniNums{i});
        else
            content = sprintf('%s, %s', content, UniNums{i});
        end
    end
    supportIndicator(iCourse,1) = content;
end
cList2 = eval(sCourseList);
cList2 = [cList2(:,2:3),table(supportIndicator)];

%% 合并必修和选修课表结果
cList = [cList1;cList2];
