function [output, db_Curriculum, db_GradRequire] = GetData()
%% Check the completion of importing all courses in three years
% Initialize
clear detail BlankRecord;
load('database.mat')
BlankRecord_idx = 1;
detail = struct([]);
BlankRecord = struct([]);
output = struct([]);
% Build a table to show the completion of file imported
Years = {'class2013', 'class2014', 'class2015'};
% Import all transcripts if dataset is not existed
if ~exist('dataset', 'var')
    [dataset, ~] = ImportTranscripts();
end
% Get all transcripts of given course according to the course ID
for i = 1:height(db_Curriculum)
    detail(i).ID = db_Curriculum.ID(i);
    detail(i).Name = db_Curriculum.Name(i);
    detail(i).Credit = db_Curriculum.Credit(i);
    getTranscript = dataset(strcmp({dataset.CourseID}, db_Curriculum.ID(i)));
    if ~isempty(getTranscript)
        % Combine all students data into one table
        AllStudents = getTranscript(1).StudentScore;
        if length(getTranscript) >= 2
            for j = 2:length(getTranscript)
                AllStudents = [AllStudents; getTranscript(j).StudentScore];
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
% Recheck the empty ones with IDv2018
for BlankRecord_idx = 1:length(BlankRecord)
    i = BlankRecord(BlankRecord_idx).idx;
    getTranscript = dataset(strcmp({dataset.CourseID}, db_Curriculum.IDv2018(i)));
    if ~isempty(getTranscript)
        % Combine all students data into one table
        AllStudents = getTranscript(1).StudentScore;
        if length(getTranscript) >= 2
            for j = 2:length(getTranscript)
                AllStudents = [AllStudents; getTranscript(j).StudentScore];
            end
        end
        % Get the given year
        fieldname = BlankRecord(BlankRecord_idx).class; 
        fieldname = [fieldname{:}]; year = fieldname((end-3):end);
        detail(i).(fieldname) = AllStudents(strcmp(AllStudents.Year, year),:); 
    end
end
% Output
for course_sn = 1:length(detail)
    output(course_sn).ID = detail(course_sn).ID;
    output(course_sn).Name = detail(course_sn).Name;
    output(course_sn).Credit = detail(course_sn).Credit;
    for year_sn = 1:length(Years)
        year = Years(year_sn); year = year{:};
        output(course_sn).(year) = detail(course_sn).(year);        
    end
end