%% Check the completion of importing all courses in three years
% Initialize
clear output;
load('database.mat')
BlankRecord_idx = 1;
% Build a table to show the completion of file imported
Years = {'class2013', 'class2014', 'class2015'};
CourseNum = length(db_Curriculum.ID);
output = table(db_Curriculum.ID, db_Curriculum.Name, ...
               db_Curriculum.Credit, 'VariableNames', {'CourseID', ...
               'CourseName', 'CourseCredit'});
for i = 1:length(Years)
    new_col = table(zeros(CourseNum, 1), 'VariableNames', Years(i));
    output = [output, new_col];
end
% Import all transcripts if dataset is not existed
if ~exist('dataset', 'var')
    [dataset, transcript_num] = GetData();
end
% Get all transcripts of given course according to the course ID
for i = 1:height(db_Curriculum)
    detail(i).ID = db_Curriculum.ID(i);
    detail(i).Name = db_Curriculum.Name(i);
    detail(i).Credit = db_Curriculum.Credit(i);
    getTranscript = dataset(strcmp({dataset.CourseID}, db_Curriculum.ID(i)));
%     if isempty(getTranscript)
%         % Try to get the transcript according to the course ID v2018 if it
%         % existing
%         CourseID_New = db_Curriculum.IDv2018(i); 
%         if ~isempty(CourseID_New{:})
%             getTranscript = dataset(strcmp({dataset.CourseID}, CourseID_New));
%         end
%     end
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
% Recheck the empty ones

% Output