function [dataset, FileNum] = ImportTranscripts(opt)
%% Import data from selected spreadsheets
%
% 参数说明：
% 输入参数 opt - 0 （缺省值）导入老版教务系统导出的成绩单
%               1 根据成绩单从缺省位置寻找成绩单定义
%               2 先导入“成绩单定义”，再据其导入相应的成绩单
%  
%  1) Selected all spreadsheets needed to be imported
%  2) Convert data in each spreadsheet into a table
%  3) Extract all student grades from the main class
%  4) Build the data structure for each course
%
%  by Dr. GUAN Guoqiang @ SCUT on 2019/09/12

%% 输入参数设定
if nargin == 0
    opt = 0; % 缺省输入参数
end

%% Multi-select files being imported
[FileNames, PathName] = uigetfile('*.*', '选择成绩单Excel文件 ...', 'Multiselect', 'on');
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
    AcadYear = '';
    CourseCode = '';
    CourseID = '';
    Course = '';
    Teacher = '';
    % Read the spreadsheet file
    FullPath = strcat(PathName, FileNames(i));
    [~, ~, raw] = xlsread([FullPath{:}],'Sheet1');
    raw(cellfun(@(x) ~isempty(x) && isnumeric(x) && isnan(x),raw)) = {''};
    switch opt
        case(0)
            GetCourseInfo(1)
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
            StudentScore = table(Class, SN, Name, Year, RegGrade, MidExam, FinalExam, ExpGrade, Overall);
            Definition = ImportSpecification('简单成绩单定义1.xlsx');
        case 1  
            % 获取课程信息
            GetCourseInfo(2);
            % 导入成绩单定义
            Definition = ImportSpecification(FileNames(i));
            % 获取课程成绩
            GetTranscript();
        case 2
            % 获取课程信息
            GetCourseInfo(2);
            % 导入成绩单定义
            Definition = ImportSpecification();
            % 获取课程成绩
            GetTranscript();
    end
            
    % Build the data set
    dataset(i).AcadYear = AcadYear;
    dataset(i).CourseID = CourseID;
    dataset(i).Course = Course;
    dataset(i).CourseCode = CourseCode;
    dataset(i).Teacher = Teacher;
    dataset(i).Definition = Definition;
    dataset(i).StudentScore = StudentScore;
    % Feedback the progress of file import
    prompt = sprintf('已导入%s年课程“%s”（%s）', AcadYear, Course, Teacher);
    waitbar(i/FileNum, wb_gui, prompt)
end
close(wb_gui)

function GetCourseInfo(flag)
    switch flag
        case 1
            % 从成绩单的固定位置获取课程信息
            % Get the course name in VarName1(3)
            Course = raw{3,1}(6:end);
            % Get the teacher name
            Teacher = raw{2,4}(6:end);
            % Get the course id
            CourseID = raw{3,4}(6:end);
            % 提取“选课代码”
            CourseCode =  raw{4,1}(6:end);            
            % Get the acadamic year
            AcadYear = CourseCode(2:10); % e.g. '2013-2014'           
        case 2
            % 从导入成绩单的文件名获取课程名称（通过文件名中的识别符“-”、“_”或空格）
            startIdx = regexp(FileNames{i},'[-_\s]', 'once');
            if ~isempty(startIdx)
                tryCourseName = FileNames{i}(1:(startIdx-1));
                % 获取课程名称后与课程清单匹对，确定课程代码和上课的学期
                load('database.mat', 'db_Curriculum')
                FoundIdx = strncmp(tryCourseName, db_Curriculum.Name, length(tryCourseName));
                if any(FoundIdx)
                    Course = db_Curriculum.Name{FoundIdx};
                    CourseID = db_Curriculum.ID{FoundIdx};
                    % 从文件名识别获得年级
                    Class = FileNames{i}((startIdx+1):(startIdx+4));
                    % 课程执行的学期
                    if isnumeric(db_Curriculum.Semester(FoundIdx))
                        AcadYear_Num = str2double(Class)+round(db_Curriculum.Semester(FoundIdx)/2);
                        % 由课程执行的学期数和年级确定课程进行的学年
                        AcadYear = [num2str(AcadYear_Num-1),'-',num2str(AcadYear_Num)];
                    end
                end
            else
                disp('无法从成绩单文件名中获取课程名称信息！2013级成绩单的文件名示例：毕业设计(论文)_2013.xlsx')
            end
    end
end

function GetTranscript()
    % 成绩单结构向量
    Spec = Definition.Spec; 
    % 从成绩单定义中获取成绩单的数据代码列
    DefHeadCodes = cell(1,sum(Spec));
    DefHeadNames = cell(1,sum(Spec));
    iName = 1;
    for iType = 1:length(Spec)
        for iWay = 1:Spec(iType)
            DefHeadCodes{iName} = Definition.EvalTypes(iType).EvalWays(iWay).Code;
            DefHeadNames{iName} = Definition.EvalTypes(iType).EvalWays(iWay).Description;
            iName = iName+1;
        end
    end
    % 从导入的成绩单中获取列名称向量
    headTitles = raw(1,:);
    raw(1,:) = [];
    % 为成绩单列名称分配数据代码
    headTitleCodes = cell(size(headTitles));
    for iName = 1:length(DefHeadNames)
        headTitleCodes(contains(headTitles, DefHeadNames{iName})) = DefHeadCodes(iName);
    end
    % 从导入成绩单的列名中查找班级列
    iCols_Class = contains(headTitles,'班级')|contains(headTitles,'Class');
    StudentScore.Class = raw(:,iCols_Class);
    % 从导入成绩单的列名中查找学生姓名
    iCols_Name = contains(headTitles,'学生姓名')|contains(headTitles,'Student');
    StudentScore.Name = raw(:,iCols_Name);
    % 从导入成绩单的列名中查找学号
    iCols_SN = contains(headTitles,'学号')|contains(headTitles,'SN');
    StudentScore.SN = raw(:,iCols_SN);
    % 从每个同学学号的前4位
    StudentScore.Year = cellfun(@(x) x(1:4), raw(:,iCols_SN), 'UniformOutput', false);
    % 若有题目和指导教师列也将其导入
    iCols_Title = contains(headTitles,'课题')|contains(headTitles,'Title');
    if any(iCols_Title)
        StudentScore.Title = raw(:,iCols_Title);
    end
    iCols_Supervisor = contains(headTitles,'教师姓名')|contains(headTitles,'Supervisor');
    if any(iCols_Supervisor)
        StudentScore.Supervisor = raw(:,iCols_Supervisor);
    end
    % 从导入成绩单的列名中按成绩单定义查找成绩数据
    iCols_Data = false(1,length(headTitles));
    for iHead = 1:sum(Spec)
        iCols_Data = iCols_Data|strcmp(DefHeadCodes(iHead), headTitleCodes);
    end
    if ~any(iCols_Data)
        % 通过考核方式代号查找成绩单的数据列
        for iHead = 1:sum(Spec)
            iCols_Data = iCols_Data|strcmp(DefHeadCodes(iHead), headTitle);
        end
        if ~any(iCols_Data)
            disp('【错误】成绩单与定义不匹配！')
            close(wb_gui)
            return
        end
    end
    ScoreData = cell2table(raw(:,iCols_Data), 'VariableNames', DefHeadCodes);
    StudentScore = [struct2table(StudentScore),ScoreData];
end

end
