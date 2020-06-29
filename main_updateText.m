%% ���´�ɶȷ�������ı��Ľű�
%
% ������Ҫ���ܣ���db_Course���´�ɶȷ�����������е��ı�
%
% by Dr. Guan Guoqiang @ SCUT on 2020/6/29

%% ��ʼ��
% ����db_Course
if ~exist('db_Course','var')
    load('database.mat','db_Course')
end
% ����QE_Courses
if ~exist('QE_Courses','var')
    load('QE_Courses.mat','QE_Courses')
end

NCourse_Update = length(db_Course);
NQECourse = length(QE_Courses);

for iCourse = 1:NCourse_Update
    Objectives = db_Course(iCourse).Objectives;
    idxFound = strcmp({QE_Courses.Name},db_Course(iCourse).Name);
    QE_Courses_Extracted = QE_Courses(idxFound);   
    QE_Courses(idxFound) = arrayfun(@(x) EA_FillText(x,Objectives, ...
        db_Course(iCourse).(['class',x.Class]).Analysis), QE_Courses_Extracted);    
end