function [dataset, FileNum] = ImportTranscripts()
%% Import data from selected spreadsheets
%  
%  1) Selected all spreadsheets needed to be imported
%  2) Convert data in each spreadsheet into a table
%  3) Extract all student grades from the main class
%  4) Build the data structure for each course
%
%  by Dr. GUAN Guoqiang @ SCUT on 2019/09/12
%
%% Multi-select files being imported
[FileNames, PathName] = uigetfile('*.*', 'Select files ...', 'Multiselect', 'on');
% Note:
% When only one file is selected, uigetfile() will return the char variable
% and lead to the error in [FullPath{:}]. Use cellstr() to ensure the
% variable be as cell objects.
FileNames = cellstr(FileNames);
PathName = cellstr(PathName);
% Get the number of selected file in the dialog windows
FileNum = length(FileNames);
% Initialize the structure array
dataset = repmat(struct([]), FileNum, 1);
% Set the wait bar
wb_gui = waitbar(0, 'Importing transcripts ...');
%
%% Import the data one by one file
for i = 1:FileNum
    % Read the spreadsheet file
    FullPath = strcat(PathName, FileNames(i));
    [~, ~, raw] = xlsread([FullPath{:}],'Sheet1');
    raw(cellfun(@(x) ~isempty(x) && isnumeric(x) && isnan(x),raw)) = {''};
    cellVectors = raw(:,[1,2,3,4,5,6,7,8,9]);
    % Allocate imported array to column variable names
    VarName1 = cellVectors(:,1);
    VarName2 = cellVectors(:,2);
    VarName3 = cellVectors(:,3);
    VarName4 = cellVectors(:,4);
    VarName5 = cellVectors(:,5);
    VarName6 = cellVectors(:,6);
    VarName7 = cellVectors(:,7);
    VarName8 = cellVectors(:,8);
    VarName9 = cellVectors(:,9);
    % Get the course name in VarName1(3)
    Course = VarName1{3};
    Course = Course(6:end);
    % Get the data info according to the series number in VarName1
    idx = ~isnan(str2double(VarName1)); % indices of number
    NumStudent = sum(idx);
    % Initialize
    j = 1;
    Class = cell(NumStudent, 1);
    SN = cell(NumStudent, 1);
    Name = cell(NumStudent, 1);
    RegGrade = zeros(size(Class));
    MidExam = zeros(size(Class));
    FinalExam = zeros(size(Class));
    ExpGrade = zeros(size(Class));
    Overall = zeros(size(Class));
    % Change scale from 5 points to 100 points
    VarName4 = ConvertScale(VarName4);
    VarName5 = ConvertScale(VarName5);
    VarName6 = ConvertScale(VarName6);
    VarName7 = ConvertScale(VarName7);
    VarName8 = ConvertScale(VarName8);
    % Import data row by row
    for row = 6:length(idx)
        if idx(row) == 0
            ClassName = VarName1(row);
        else
            Class(j) = ClassName;
            SN(j) = VarName2(row);
            Name(j) = VarName3(row);
            RegGrade(j) = str2double(VarName4(row));
            MidExam(j) = str2double(VarName5(row));
            FinalExam(j) = str2double(VarName6(row));
            ExpGrade(j) = str2double(VarName7(row));
            Overall(j) = str2double(VarName8(row));
            j = j+1;
        end
    end
    Year = cellfun(@(x) x(1:4), SN, 'UniformOutput', false);
    % Extract the students of EnergyChE
    idx_ext = cellfun(@(c) ischar(c) && ~isempty(strfind(c, '能源化学')), Class);
    % Extract the students' info
    Class = Class(idx_ext);
    SN = SN(idx_ext);
    Year = Year(idx_ext);
    Name = Name(idx_ext);
    RegGrade = RegGrade(idx_ext);
    MidExam = MidExam(idx_ext);
    FinalExam = FinalExam(idx_ext);
    ExpGrade = ExpGrade(idx_ext);
    Overall = Overall(idx_ext);
    % Build the data table
    StudentScore = table(Class, SN, Name, Year, RegGrade, FinalExam, Overall);
    % Get the teacher name
    Teacher = VarName4(2);
    Teacher = [Teacher{:}];
    Teacher = Teacher(6:end);
    % Get the course id
    CourseID = VarName4{3};
    CourseID = CourseID(6:end);
    % Get the acadamic year
    AcadYear = VarName1{4};
    AcadYear = AcadYear(7:15); % e.g. '2013-2014'
    % Build the data set
    dataset(i).AcadYear = AcadYear;
    dataset(i).CourseID = CourseID;
    dataset(i).Course = Course;
    dataset(i).Teacher = Teacher;
    dataset(i).StudentScore = StudentScore;
    % Feedback the progress of file import
    filename = FileNames(i);
    prompt = sprintf('%s imported ...', filename{:});
    waitbar(i/FileNum, wb_gui, prompt)
end
close(wb_gui)
