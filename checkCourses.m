function [ok,details] = checkCourses(db_Curriculum,CourseArray)
%% 检查课程矩阵
% 这是由于课程支撑矩阵在后期进行了修改，需要检查王老师生成的变量CourseArray中各门
% 课程支撑的指标点数目是否与db_Curriculum中所列的一致
% by Dr. Guan Guoqiang @ SCUT on 2021-3-16

% 输入参数检查
if ~exist('db_Curriculum','var')
    fprintf('[注意] 调用EA_GetReqMatrix()导入db_Curriculum！\n')
    db_Curriculum = EA_GetReqMatrix();
end
if ~exist('CourseArray','var')
    fprintf('[注意] 从存盘QE_Courses.mat中导入CourseArray！\n')
    load('QE_Courses.mat','CourseArray')
end

% 检查CourseArray所列课程是否与db_Curriculum中的一致
nameCheck = arrayfun(@(x)any(strcmp(db_Curriculum.Name,x.Name)),CourseArray);
idCheck = arrayfun(@(x)any(strcmp(db_Curriculum.ID,x.ID)),CourseArray);

% 检查db_Curriculum所列课程的支撑指标点数目是否与CourseArray中的一致
numCheck = arrayfun(@(x)length(x.Requirements)==sum(db_Curriculum.ReqMatrix(strcmp(db_Curriculum.ID,x.ID),:)),CourseArray);

% 输出
ok = (all(nameCheck)|all(idCheck))&all(numCheck);
details.courseList = arrayfun(@(x)string(x.Name),CourseArray);
details.nameCheck = nameCheck;
details.idCheck = idCheck;
details.numCheck = numCheck;