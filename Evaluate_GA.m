%% Evaluate the graduation achievement
%
% by Dr. GUAN Guoqiang @ SCUT on 2019/9/21
%
% Initialize
clear;
Years = {'class2013'};
% Get data for processing
[db_Outcome, db_Curriculum, db_GradRequire] = GetData(Years);
%
%% Build the default matrices for evaluating the teaching objectives of each
% course listed in db_Curriculum
CorrelateMatrix = struct([]);
NumCourse = length(db_Outcome);
for course_sn = 1:NumCourse
    % Number of supported indicators in this course
    idx_UniNum = find(db_Curriculum.ReqMatrix(course_sn,:));
    M = length(idx_UniNum);
    % Number of teaching objectives in this course, default N = M
    N = M;
    % Relation matrix of supported indicators and teaching objectives
    C = eye(M,N);
    %  Build the matrices of C and B
    B = RelateC2B(C, idx_UniNum);
    % Number of teaching contents, default L = 2, i.e., only regular grade
    % and score of final exam are used in teaching evaluation
    L = 2;
    % Relation matrix of teaching contents and objectives
    D = zeros(N, L);
    D(:,1) = 0.3; % default 0.3: regular grade contributes 30 %
    D(:,2) = 0.7; % default 0.7: regular grade contributes 70 %
    % Number of evaluation, default J = 1: only one transcript is used
    J = 1;
    % Weight array of each evaluation
    E(1:J,1) = 1/J;
    % Outcome of teaching content evaluation
    U = zeros(L, J);
    % Pack in structure
    CorrelateMatrix(course_sn).B = B;
    CorrelateMatrix(course_sn).C = C;
    CorrelateMatrix(course_sn).D = D;
    CorrelateMatrix(course_sn).E = E;
    CorrelateMatrix(course_sn).U = U;
end
%
%% Evaluate the completeness of teaching objectives in each course
for course_sn = 1:NumCourse
    year = Years{:};
    detail = db_Outcome(course_sn).(year);
    outcome = mean([detail.RegGrade, detail.FinalExam, detail.Overall], 'omitnan')';
    if sum(~isnan(outcome)) == 3
        CorrelateMatrix(course_sn).U = outcome(1:2);
    else
        CorrelateMatrix(course_sn).U = outcome(3);
        % Rebuild the matrix D due to only the overall score existed in the
        % transcript
        N = size(CorrelateMatrix(course_sn).D, 1);
        CorrelateMatrix(course_sn).D = ones(N, 1);
    end
    % Evaluate the completeness of teaching objectives
    B = CorrelateMatrix(course_sn).B;
    C = CorrelateMatrix(course_sn).C;
    D = CorrelateMatrix(course_sn).D;
    E = CorrelateMatrix(course_sn).E;
    U = CorrelateMatrix(course_sn).U;
    [X, Y] = TeachObj(B, C, D, E, U);
    db_Outcome(course_sn).X = X;
    db_Outcome(course_sn).Y = Y;
end
%
%% List the supported courses for each indicator of graduation requirement
NumIndicator = size(db_Curriculum.ReqMatrix, 2);
output = struct([]);
row = 0;
for indicator_sn = 1:NumIndicator  
    course_idx = find(db_Curriculum.ReqMatrix(:,indicator_sn));   
    course_num = length(course_idx);
    CourseWeight = db_Curriculum.Credit(course_idx) / ...
                   sum(db_Curriculum.Credit(course_idx));
    CourseOutcome = [db_Outcome(course_idx).Y]';
    CourseOutcome = CourseOutcome(:,indicator_sn);
    Achievement = CourseWeight'*CourseOutcome;
    CourseList = [db_Curriculum(course_idx, 'Name'), ...
                  db_Curriculum(course_idx, 'Credit'), ...
                  table(CourseWeight), table(CourseOutcome)];
    output(indicator_sn).Indicator = db_GradRequire(indicator_sn, :);
    output(indicator_sn).CourseList = CourseList;
    output(indicator_sn).Achievement = Achievement;
    row = row+course_num;
end
%
%% Save the results 
% Rebuild the table to export
output_table = cell(row, 7);
row1 = 1;
for indicator_sn = 1:NumIndicator
    output_table(row1, 1:2) = table2cell(output(indicator_sn).Indicator);
    courses = table2cell(output(indicator_sn).CourseList);
    [height, width] = size(courses);
    row2 = row1+height;
    output_table(row1:(row2-1), 3:(2+width)) = courses;
    output_table(row1,7) = {output(indicator_sn).Achievement};
    row1 = row2;
end
% Export results
output_table = cell2table(output_table);
filename = strcat(year, '.xlsx');
writetable(output_table, filename, 'Sheet', 1)