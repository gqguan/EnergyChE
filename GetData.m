function [dataset, FileNum] = GetData()
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
    Course = VarName1(3);
    Course = [Course{:}];
    Course = Course(6:end);
    % Get the data info according to the series number in VarName1
    idx = ~isnan(str2double(VarName1)); % indices of number
    NumStudent = sum(idx);
    % Import data
    SN = VarName2(idx);
    Year = cellfun(@(x) x(1:4), SN, 'UniformOutput', false);
    Name = VarName3(idx);
    RegGrade = str2double(VarName4(idx));
    MidExam = str2double(VarName5(idx));
    FinalExam = str2double(VarName6(idx));
    ExpGrade = str2double(VarName7(idx));
    Overall = str2double(VarName8(idx));
    % Extract the students being in the same year
    % Find the year of most students being
    [~, imax] = max(countcats(categorical(Year)));
    YearList = categories(categorical(Year));
    idx_ext = find(strcmp(Year, YearList(imax)));
    % Extract the students' info
    SN = SN(idx_ext);
    Year = Year(idx_ext);
    Name = Name(idx_ext);
    RegGrade = RegGrade(idx_ext);
    MidExam = MidExam(idx_ext);
    FinalExam = FinalExam(idx_ext);
    ExpGrade = ExpGrade(idx_ext);
    Overall = Overall(idx_ext);
    % Build the data table
    StudentScore = table(SN, Name, Year, RegGrade, FinalExam, Overall);
    % Get the teacher name
    Teacher = VarName4(2);
    Teacher = [Teacher{:}];
    Teacher = Teacher(6:end);
    % Get the course id
    CourseID = VarName4(3);
    CourseID = [CourseID{:}];
    CourseID = CourseID(6:end);
    % Build the data set
    dataset(i).CourseID = CourseID;
    dataset(i).Course = Course;
    dataset(i).Teacher = Teacher;
    dataset(i).Class = strcat('class', YearList(imax));
    dataset(i).StudentScore = StudentScore;
end
