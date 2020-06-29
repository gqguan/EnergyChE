%% 将QE_Course存入变量QE_Courses中
%
% by Dr. Guan Guoqiang @ SCUT on 2020/6/29
%
function [QE_Courses,QE_Courses_original,QE_Courses_MultiRepeated] = EA_SaveQE(QE_Course)
%
if ~exist('QE_Courses', 'var')
    load('QE_Courses.mat', 'QE_Courses')
end
QE_Courses_original = QE_Courses;
% 通过检查QE_Course字段ID、Name和Class是否与QE_Courses中重复
idxRepeated = strcmp({QE_Courses.ID},QE_Course.ID) & ...
              strcmp({QE_Courses.Name},QE_Course.Name) & ...
              strcmp({QE_Courses.Class},QE_Course.Class);
% 用QE_Course替换QE_Courses中的重复项
if any(idxRepeated)
    fprintf('【警告】替换%s级课程“%s”达成度分析结果！\n',QE_Course.Class,QE_Course.Name)
    QE_Courses(idxRepeated) = QE_Course;
    % 当存在多个重复项时
    if sum(idxRepeated) > 1
        fprintf('【警告】发现%s级课程“%s”存在多个达成度分析结果，替换并删除重复项！\n',QE_Course.Class,QE_Course.Name)
        QE_Courses_MultiRepeated = QE_Courses;
        iRepeated = find(idxRepeated);
        iRepeated(1) = false;
        QE_Courses(iRepeated) = [];
    else
        QE_Courses_MultiRepeated = [];
    end
else
    fprintf('添加%s级课程“%s”达成度分析结果。\n',QE_Course.Class,QE_Course.Name)
    QE_Courses = [QE_Courses,QE_Course];
end

end