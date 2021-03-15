%% 毕业要求达成度计算主程序
%
% by Dr. Guan Guoqiang @ SCUT on 2020/07/12
%
% 程序调用结构
% main_EA2
%   EA_GetReqMatrix() 导入课程支撑矩阵
%   EA_ImportQECourses() 导入课程成绩单
%   EA_GradReq() 毕业要求达成度计算
%     EA_DefGR()
%   Tab2Word() 在MS-WORD文档中表格输出

%% 初始化
clear;

%% 主程序
% 从对话框选取包含支撑矩阵的EXCEL文件，并与database.mat中的db_Curriculum.ReqMatrix比较
% 若两者不同可以选择A更新工作空间中指标点的课程支撑矩阵
db_Curriculum = EA_GetReqMatrix(); 
% 导入手工输入的课程达成度结果
QE_Courses = EA_ImportQECourses();
% 计算毕业要求达成度
output = EA_GradReq(QE_Courses,db_Curriculum);
% 显示未完成课程达成度计算的课程列表及负责教师
idxes_ZeroValue = strcmp(output(1).Contents(:,6),'0.000');
Course = categorical(output(1).Contents(idxes_ZeroValue,3));
Teacher = output(2).Contents(idxes_ZeroValue,6);
tabout = table(Course, Teacher);
catCourse = categories(Course);
idxes_Select = zeros(numel(catCourse),1);
for iCourse = 1:numel(catCourse)
    idxes_Select(iCourse) = find(tabout.Course == catCourse(iCourse),1);
end
if any(idxes_Select)
    fprintf('下列课程尚未提交“课程目标达成度结果”\n');
    disp(tabout(idxes_Select,:))
end
% 在MS-Word中制表输出（1）毕业要求达成度计算结果、（2）毕业要求评价依据表
flag = input('是否在MS-Word中制表输出结果[Y/N]','s');
switch flag
    case('Y')
        cprintf('Comments','在MS-Word中制表输出（1）毕业要求达成度计算结果、（2）毕业要求评价依据表。\n')
        for iTab = 1:numel(output)
            Tab2Word(output(iTab).Contents, ...
                     output(iTab).Heads, ...
                     output(iTab).TableType, ...
                     output(iTab).TableName);
        end
    case('N')
end