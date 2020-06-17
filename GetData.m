function [output, db_Curriculum, db_GradRequire] = GetData(Years)
%% �ӹ����ռ��е�dataset��������ȡָ���꼶�ĸ��γ�ȫ��ѧ���ɼ���
%
% ����˵����
% ��1���ɲ������������������ȱʡֵ����
% ��2���γ̰�db_Curriculum�еĿγ�����ͨ��ƥ�Կγ̱��CourseIDʶ��
% ��3������db_Curriculum��CourseID�Ҳ����κογ̳ɼ������ٰ�IDv2018ƥ��
%
% ����˵����
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
    detail(i).ID = db_Curriculum.ID(i);
    detail(i).Name = db_Curriculum.Name(i);
    detail(i).Credit = db_Curriculum.Credit(i);
    getTranscript = dataset(strcmp({dataset.CourseID}, db_Curriculum.ID(i)));
    if ~isempty(getTranscript)
        % ���ӽ�ʦ��ѡ�δ���
        clear Teacher CourseCode
        Teacher(1:height(getTranscript(1).StudentScore),1) = {getTranscript(1).Teacher};
        CourseCode(1:height(getTranscript(1).StudentScore),1) = {getTranscript(1).CourseCode};
        AllStudents = [getTranscript(1).StudentScore, table(Teacher), table(CourseCode)];
        % ��ͬһ�ſγ��ж��ųɼ���ʱ���ѳɼ����ϵ�ѧ���б�ϲ�
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
        if ~ismember(fieldnames(detail(i)), fieldname{:})
            BlankRecord(BlankRecord_idx).idx = i;
            BlankRecord(BlankRecord_idx).Name = db_Curriculum.Name(i);
            BlankRecord(BlankRecord_idx).ID = db_Curriculum.ID(i);
            BlankRecord(BlankRecord_idx).IDv2018 = db_Curriculum.IDv2018(i);
            BlankRecord(BlankRecord_idx).class = fieldname;
            BlankRecord_idx = BlankRecord_idx+1;
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