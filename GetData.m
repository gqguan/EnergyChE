function [output, db_Curriculum, db_GradRequire] = GetData(Years)
%% 从工作空间中的dataset变量中提取指定年级的各课程全部学生成绩单
%
% 功能说明：
% （1）可不输入输入参数，程序按缺省值导入
% （2）课程按db_Curriculum中的课程排序，通过匹对课程编号CourseID识别
% （3）若按db_Curriculum中CourseID找不到任何课程成绩单，再按IDv2018匹对
%
% 参数说明：
% input arguments
% Years - (str array) default as {'class2013', 'class2014', 'class2015'}
%
% output arguments
% output - (struct array) outcomes for all courses
% db_Curriculum - (table) preset curriculum
% db_GradRequire - (table) preset graduation requirement
%
% by Dr. GUAN Guoqiang @ SCUT on 2019/9/21

%% Initialize
clear detail BlankRecord;
load('database.mat')
BlankRecord_idx = 1;
detail = struct([]);
BlankRecord = struct([]);
output = struct([]);
% Build a default table to show the completion of file imported
if nargin < 1
    Years = {'class2013', 'class2014', 'class2015'};
end
% Import all transcripts if dataset is not existed
if ~exist('dataset', 'var')
    [dataset, ~] = ImportTranscripts();
end

%% Get all transcripts of given course according to the course ID
for i = 1:height(db_Curriculum)
%     if i == 49
%         disp('debugging')
%     end
    detail(i).ID = db_Curriculum.ID(i);
    detail(i).Name = db_Curriculum.Name(i);
    detail(i).Credit = db_Curriculum.Credit(i);
    getTranscript = dataset(strcmp({dataset.CourseID}, db_Curriculum.ID(i)));
    if ~isempty(getTranscript)
        % 附加教师和选课代码
        clear Teacher CourseCode
        Teacher(1:height(getTranscript(1).StudentScore),1) = {getTranscript(1).Teacher};
        CourseCode(1:height(getTranscript(1).StudentScore),1) = {getTranscript(1).CourseCode};
        AllStudents = [getTranscript(1).StudentScore, table(Teacher), table(CourseCode)];
        % 当同一门课程有多张成绩单时，把成绩单上的学生列表合并
        if length(getTranscript) >= 2
            for j = 2:length(getTranscript)
                clear Teacher CourseCode
                Teacher(1:height(getTranscript(j).StudentScore),1) = {getTranscript(j).Teacher};
                CourseCode(1:height(getTranscript(j).StudentScore),1) = {getTranscript(j).CourseCode};
                AddStudents = [getTranscript(j).StudentScore, table(Teacher), table(CourseCode)];
                AllStudents = [AllStudents; AddStudents];
            end
        end
        % Get the categories according to year
        YearList = categories(categorical(AllStudents.Year));
        for j = 1:length(YearList)
            fieldname = strcat('class', YearList(j)); 
            fieldname = [fieldname{:}];
            detail(i).(fieldname) = AllStudents(strcmp(AllStudents.Year, YearList(j)),:);
        end     
    end
    for j = 1:length(Years)
        fieldname = Years(j);
        if find(ismember(fieldnames(detail(i)), fieldname{:})) ~= 0
            if isempty(detail(i).(fieldname{:}))
                BlankRecord(BlankRecord_idx).idx = i;
                BlankRecord(BlankRecord_idx).Name = db_Curriculum.Name(i);
                BlankRecord(BlankRecord_idx).ID = db_Curriculum.ID(i);
                BlankRecord(BlankRecord_idx).IDv2018 = db_Curriculum.IDv2018(i);
                BlankRecord(BlankRecord_idx).class = fieldname;
                BlankRecord_idx = BlankRecord_idx+1;
            end
        end
    end
end

%% Recheck the empty ones with IDv2018
for BlankRecord_idx = 1:length(BlankRecord)
    i = BlankRecord(BlankRecord_idx).idx;
    getTranscript = dataset(strcmp({dataset.CourseID}, db_Curriculum.IDv2018(i)));
    if ~isempty(getTranscript)
        clear Teacher CourseCode
        Teacher(1:height(getTranscript(1).StudentScore),1) = {getTranscript(1).Teacher};
        CourseCode(1:height(getTranscript(1).StudentScore),1) = {getTranscript(1).CourseCode};
        AllStudents = [getTranscript(1).StudentScore, table(Teacher), table(CourseCode)];
        if length(getTranscript) >= 2
            for j = 2:length(getTranscript)
                clear Teacher CourseCode
                Teacher(1:height(getTranscript(j).StudentScore),1) = {getTranscript(j).Teacher};
                CourseCode(1:height(getTranscript(j).StudentScore),1) = {getTranscript(j).CourseCode};
                AddStudents = [getTranscript(j).StudentScore, table(Teacher), table(CourseCode)];
                AllStudents = [AllStudents; AddStudents];
            end
        end
        % Get the given year
        fieldname = BlankRecord(BlankRecord_idx).class; 
        fieldname = [fieldname{:}]; year = fieldname((end-3):end);
        detail(i).(fieldname) = AllStudents(strcmp(AllStudents.Year, year),:); 
    end
end

%% Output
for course_sn = 1:length(detail)
    output(course_sn).ID = detail(course_sn).ID;
    output(course_sn).Name = detail(course_sn).Name;
    output(course_sn).Credit = detail(course_sn).Credit;
    for year_sn = 1:length(Years)
        year = Years(year_sn); year = year{:};
        output(course_sn).(year) = detail(course_sn).(year);        
    end
end