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
for iFile = 1:FileNum
    AcadYear = '';
    CourseCode = '';
    CourseID = '';
    Course = '';
    Teacher = '';
    Class = '';
    % Read the spreadsheet file
    FullPath = strcat(PathName, FileNames(iFile));
    [~, ~, raw] = xlsread([FullPath{:}],'Sheet1');
    % 对空的
    raw(cellfun(@(x) ~isempty(x) && isnumeric(x) && isnan(x),raw)) = {''};
    switch opt
        case(0)
            GetCourseInfo(1)
            raw = raw(5:end,:);
            raw_Width = size(raw,2);
            FirstRow = cell(1,raw_Width);
            IdxCol = raw(:,1); % 序号索引列
            % 从“序号索引列”中提取数值序号
            idx = ~isnan(str2double(IdxCol));
            % 该成绩单的学生人数
            NumStudent = sum(idx);
            rawdata = cell(NumStudent,raw_Width+2); 
            FirstRow(1,:) = raw(1,:);
            % 增加一列存放学生班级
            FirstRow = [FirstRow,{'班级'},{'年级'}];

            iStudent = 1;
            for iRow = 1:length(IdxCol)
                if idx(iRow) == 0
                    ClassName = raw{iRow,1}; % 班级名称
                else
                    rawdata(iStudent,1:raw_Width) = raw(iRow,:);
                    rawdata(iStudent,raw_Width+1) = {ClassName};
                    rawdata(iStudent,raw_Width+2) = {raw{iRow,2}(1:4)}; % 从学号前4位得年级
                    iStudent = iStudent+1;
                end
            end
            
            % 从多数学生的学号前4位得该班同学的年级
            Classes = categorical(rawdata(:,raw_Width+2));
            ClassNames = categories(Classes);
            [~,iMost] = max(countcats(Classes));
            Class = ClassNames(iMost);
           
            raw = [FirstRow; rawdata];
            Definition = ImportSpecification('简单成绩单定义1.xlsx');
            % 获取课程成绩
            StudentScore = GetTranscript();
        case 1  
            % 获取课程信息
            GetCourseInfo(2);
            % 导入成绩单定义
            Definition = ImportSpecification(FileNames(iFile));
            % 获取课程成绩
            StudentScore = GetTranscript();
        case 2
            % 获取课程信息
            GetCourseInfo(2);
            % 导入成绩单定义
            Definition = ImportSpecification();
            % 获取课程成绩
            StudentScore = GetTranscript();
    end
            
    % Build the data set
    dataset(iFile).AcadYear = AcadYear;
    dataset(iFile).Class = Class;
    dataset(iFile).CourseID = CourseID;
    dataset(iFile).Course = Course;
    dataset(iFile).CourseCode = CourseCode;
    dataset(iFile).Teacher = Teacher;
    dataset(iFile).Definition = Definition;
    dataset(iFile).StudentScore = StudentScore;
    % Feedback the progress of file import
    prompt = sprintf('已导入%s年课程“%s”（%s）', AcadYear, Course, Teacher);
    waitbar(iFile/FileNum, wb_gui, prompt)
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
            % 从文件名识别获得年级
            endIdx = regexp(FileNames{iFile},'[-_\s]', 'once');
            Class = FileNames{iFile}(1:(endIdx-1));            
        case 2
            % 从导入成绩单的文件名获取课程名称（通过文件名中的识别符“-”、“_”或空格）
            startIdx = regexp(FileNames{iFile},'[-_\s]', 'once');
            if ~isempty(startIdx)
                tryCourseName = FileNames{iFile}(1:(startIdx-1));
                % 获取课程名称后与课程清单匹对，确定课程代码和上课的学期
                load('database.mat', 'db_Curriculum')
                FoundIdx = strncmp(tryCourseName, db_Curriculum.Name, length(tryCourseName));
                if any(FoundIdx)
                    Course = db_Curriculum.Name{FoundIdx};
                    CourseID = db_Curriculum.ID{FoundIdx};
                    % 从文件名识别获得年级
                    Class = FileNames{iFile}((startIdx+1):(startIdx+4));
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

function Detail = GetTranscript()
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
    % 若成绩为“五分制”则转换为“百分制”
    for iCol = 1:size(raw,2)
        raw(:,iCol) = ConvertScale(raw(:,iCol));
    end
    % 筛选没有成绩的学生
    iCols_Overall = contains(headTitles,'总分')| ...
                    contains(headTitles,'总评成绩')| ...
                    contains(headTitles,'综合成绩')| ...
                    contains(headTitles,'Overall');
    if ~any(iCols_Overall)
        cprintf('err','【错误】成绩单数据中无综合成绩列！\n')
        return
    end
    % 当iCols_Overall有多列数据时选第一列
    iCol_Overall = find(iCols_Overall,1);
    % 根据raw第1行、第iCol_Overall列的数据类型选择数据处理的方式
    switch class(raw{1,iCol_Overall})
        case('char')
            idx_Completed = ~isnan(str2double(raw(:,iCol_Overall)));
        case('double')
            idx_Completed = ~isnan([raw{:,iCol_Overall}]);
        otherwise
    end
    raw = raw(idx_Completed,:);
    % 从导入成绩单的列名中查找班级列
    iCols_Class = contains(headTitles,'班级')|contains(headTitles,'Class');
    Detail.Class = raw(:,iCols_Class);
    % 筛选能源化工专业的学生
    idx_ext = cellfun(@(c) ischar(c) && (contains(c, '能源化学') || ...
                                         contains(c, '能源化工') || ...
                                         contains(c, '能化')) , Detail.Class);
    Detail.Class = Detail.Class(idx_ext);
    raw = raw(idx_ext,:);
    % 从导入成绩单的列名中查找学生姓名
    iCols_Name = contains(headTitles,'学生姓名')|contains(headTitles,'Student');
    if ~any(iCols_Name)
        iCols_Name = contains(headTitles,'姓名')|contains(headTitles,'Name');
    end
    Detail.Name = raw(:,iCols_Name);
    % 从导入成绩单的列名中查找学号
    iCols_SN = contains(headTitles,'学号')|contains(headTitles,'SN');
    Detail.SN = raw(:,iCols_SN);
    % 从每个同学学号的后4位
    Detail.Year = cellfun(@(x) x(1:4), raw(:,iCols_SN), 'UniformOutput', false);
    % 若有题目和指导教师列也将其导入
    iCols_Title = contains(headTitles,'课题')|contains(headTitles,'Title');
    if any(iCols_Title)
        Detail.Title = raw(:,iCols_Title);
    end
    iCols_Supervisor = contains(headTitles,'教师姓名')|contains(headTitles,'Supervisor');
    if any(iCols_Supervisor)
        Detail.Supervisor = raw(:,iCols_Supervisor);
    end
    % 从导入成绩单的列名中按成绩单定义查找成绩数据
    iCols_Data = false(1,length(headTitles));
    for iHead = 1:sum(Spec)
        iCols_Data = iCols_Data|strcmp(DefHeadCodes(iHead), headTitleCodes);
    end
    if ~any(iCols_Data)
        % 通过考核方式代号查找成绩单的数据列
        for iHead = 1:sum(Spec)
            iCols_Data = iCols_Data|strcmp(DefHeadCodes(iHead), headTitles);
        end
        if ~any(iCols_Data)
            cprintf('err','【错误】成绩单与定义不匹配！')
            return
        end
    end
    ScoreData = cell2table(raw(:,iCols_Data), 'VariableNames', DefHeadCodes);
    Detail = [struct2table(Detail),ScoreData];
end

end
