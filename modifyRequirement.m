function CourseArray = modifyRequirement(db_Curriculum,CourseArray)
%% 按db_Curriculum.ReqMatrix修改CourseArray中的指标点
% by Dr. Guan Guoqiang @ SCUT on 2021-3-16

% 检查输入参数
if ~exist('db_Curriculum','var')
    fprintf('[注意] 调用EA_GetReqMatrix()导入db_Curriculum！\n')
    db_Curriculum = EA_GetReqMatrix();
end
if ~exist('CourseArray','var')
    fprintf('[注意] 从存盘QE_Courses.mat中导入CourseArray！\n')
    load('QE_Courses.mat','CourseArray')
end

% 检查CourseArray中课程及支撑指标数与db_Curriculum一致
ok = checkCourses(db_Curriculum,CourseArray);

% 遴选修改CourseArray中支撑的指标点
if ok
    for iCourse = 1:length(CourseArray)
        idx = strcmp(db_Curriculum.ID,CourseArray(iCourse).ID);
        UniNums = find(db_Curriculum.ReqMatrix(idx,:));
        for j = 1:length(UniNums)
            CourseArray(iCourse).Requirements(j).IdxUniNum = UniNums(j);
        end
    end
else
    fprintf('[错误] 输入CourseArray存在课程支撑指标点数目与db_Curriculum中说明不符！\n')
    fprintf('[注意] 输出变量CourseArray与输入相等\n')
end