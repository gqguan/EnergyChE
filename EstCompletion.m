%% Check the completion of importing all courses in three years
% Initialize
clear output;
load('database.mat')
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
% Import all transcripts
[dataset, transcript_num] = GetData();
% Get all transcripts of given class
for i = 1:length(Years)
    idx = find(strcmp([dataset.Class], Years(i)));
    if ~isempty(idx)
        for j = 1:length(idx)
            fi = find(strcmp(output.CourseID, dataset(idx(j)).CourseID));
            if ~isempty(fi)
                class = Years(i);
                output.(class{:})(fi) = 1;
            end
        end
    end
end
% Output
for i = 1:length(Years)
    class = Years(i); 
    class = class{:};
    fprintf('Import %.2f %% transcripts of %s \n', ...
            sum(output.(class))/CourseNum*100, class);
end