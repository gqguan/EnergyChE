%% 在MS-Word中制表输出“毕业要求指标点支撑课程”
%
% by Dr. Guan Guoqiang @ SCUT on 2021/4/22

%% 初始化
clear
% 载入必修和选修课程表
load('database.mat','db_Curriculum2021a','db_Curriculum2021b','db_Indicators2021')

%% 整理列出
% 从database.mat中载入db_Indicators
outTab = SupportCourses(db_Curriculum2021a,db_Curriculum2021b,db_Indicators2021);

%% 制表输出结果
% 表头
TabHead = {'毕业要求观测点','支撑必修课','支撑选修课'};
% 表类型
TabType = '指标点支撑课程列表';
% 输出文件名
TabFilename = '2021年能源化工专业毕业要求指标点支撑课程表';
% 输出MS-Word文件
Tab2Word(outTab,TabHead,TabType,TabFilename)