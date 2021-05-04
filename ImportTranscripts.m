function [dataset, FileNum] = ImportTranscripts(opt)
%% Import data from selected spreadsheets
%
% ����˵����
% ������� opt - 0 ��ȱʡֵ�������ϰ����ϵͳ�����ĳɼ���
%               1 ���ݳɼ�����ȱʡλ��Ѱ�ҳɼ�������
%               2 �ȵ��롰�ɼ������塱���پ��䵼����Ӧ�ĳɼ���
%  
%  1) Selected all spreadsheets needed to be imported
%  2) Convert data in each spreadsheet into a table
%  3) Extract all student grades from the main class
%  4) Build the data structure for each course
%
%  by Dr. GUAN Guoqiang @ SCUT on 2019/09/12

%% ��������趨
if nargin == 0
    opt = 0; % ȱʡ�������
end

%% Multi-select files being imported
[FileNames, PathName] = uigetfile('*.*', 'ѡ��ɼ���Excel�ļ� ...', 'Multiselect', 'on');
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
    % �Կյ�
    raw(cellfun(@(x) ~isempty(x) && isnumeric(x) && isnan(x),raw)) = {''};
    switch opt
        case(0)
            GetCourseInfo(1)
            raw = raw(5:end,:);
            raw_Width = size(raw,2);
            FirstRow = cell(1,raw_Width);
            IdxCol = raw(:,1); % ���������
            % �ӡ���������С�����ȡ��ֵ���
            idx = ~isnan(str2double(IdxCol));
            % �óɼ�����ѧ������
            NumStudent = sum(idx);
            rawdata = cell(NumStudent,raw_Width+2); 
            FirstRow(1,:) = raw(1,:);
            % ����һ�д��ѧ���༶
            FirstRow = [FirstRow,{'�༶'},{'�꼶'}];

            iStudent = 1;
            for iRow = 1:length(IdxCol)
                if idx(iRow) == 0
                    ClassName = raw{iRow,1}; % �༶����
                else
                    rawdata(iStudent,1:raw_Width) = raw(iRow,:);
                    rawdata(iStudent,raw_Width+1) = {ClassName};
                    rawdata(iStudent,raw_Width+2) = {raw{iRow,2}(1:4)}; % ��ѧ��ǰ4λ���꼶
                    iStudent = iStudent+1;
                end
            end
            
            % �Ӷ���ѧ����ѧ��ǰ4λ�øð�ͬѧ���꼶
            Classes = categorical(rawdata(:,raw_Width+2));
            ClassNames = categories(Classes);
            [~,iMost] = max(countcats(Classes));
            Class = ClassNames(iMost);
           
            raw = [FirstRow; rawdata];
            Definition = ImportSpecification('�򵥳ɼ�������1.xlsx');
            % ��ȡ�γ̳ɼ�
            StudentScore = GetTranscript();
        case 1  
            % ��ȡ�γ���Ϣ
            GetCourseInfo(2);
            % ����ɼ�������
            Definition = ImportSpecification(FileNames(iFile));
            % ��ȡ�γ̳ɼ�
            StudentScore = GetTranscript();
        case 2
            % ��ȡ�γ���Ϣ
            GetCourseInfo(2);
            % ����ɼ�������
            Definition = ImportSpecification();
            % ��ȡ�γ̳ɼ�
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
    prompt = sprintf('�ѵ���%s��γ̡�%s����%s��', AcadYear, Course, Teacher);
    waitbar(iFile/FileNum, wb_gui, prompt)
end
close(wb_gui)

function GetCourseInfo(flag)
    switch flag
        case 1
            % �ӳɼ����Ĺ̶�λ�û�ȡ�γ���Ϣ
            % Get the course name in VarName1(3)
            Course = raw{3,1}(6:end);
            % Get the teacher name
            Teacher = raw{2,4}(6:end);
            % Get the course id
            CourseID = raw{3,4}(6:end);
            % ��ȡ��ѡ�δ��롱
            CourseCode =  raw{4,1}(6:end);            
            % Get the acadamic year
            AcadYear = CourseCode(2:10); % e.g. '2013-2014'
            % ���ļ���ʶ�����꼶
            endIdx = regexp(FileNames{iFile},'[-_\s]', 'once');
            Class = FileNames{iFile}(1:(endIdx-1));            
        case 2
            % �ӵ���ɼ������ļ�����ȡ�γ����ƣ�ͨ���ļ����е�ʶ�����-������_����ո�
            startIdx = regexp(FileNames{iFile},'[-_\s]', 'once');
            if ~isempty(startIdx)
                tryCourseName = FileNames{iFile}(1:(startIdx-1));
                % ��ȡ�γ����ƺ���γ��嵥ƥ�ԣ�ȷ���γ̴�����Ͽε�ѧ��
                load('database.mat', 'db_Curriculum')
                FoundIdx = strncmp(tryCourseName, db_Curriculum.Name, length(tryCourseName));
                if any(FoundIdx)
                    Course = db_Curriculum.Name{FoundIdx};
                    CourseID = db_Curriculum.ID{FoundIdx};
                    % ���ļ���ʶ�����꼶
                    Class = FileNames{iFile}((startIdx+1):(startIdx+4));
                    % �γ�ִ�е�ѧ��
                    if isnumeric(db_Curriculum.Semester(FoundIdx))
                        AcadYear_Num = str2double(Class)+round(db_Curriculum.Semester(FoundIdx)/2);
                        % �ɿγ�ִ�е�ѧ�������꼶ȷ���γ̽��е�ѧ��
                        AcadYear = [num2str(AcadYear_Num-1),'-',num2str(AcadYear_Num)];
                    end
                end
            else
                disp('�޷��ӳɼ����ļ����л�ȡ�γ�������Ϣ��2013���ɼ������ļ���ʾ������ҵ���(����)_2013.xlsx')
            end
    end
end

function Detail = GetTranscript()
    % �ɼ����ṹ����
    Spec = Definition.Spec; 
    % �ӳɼ��������л�ȡ�ɼ��������ݴ�����
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
    % �ӵ���ĳɼ����л�ȡ����������
    headTitles = raw(1,:);
    raw(1,:) = [];
    % Ϊ�ɼ��������Ʒ������ݴ���
    headTitleCodes = cell(size(headTitles));
    for iName = 1:length(DefHeadNames)
        headTitleCodes(contains(headTitles, DefHeadNames{iName})) = DefHeadCodes(iName);
    end
    % ���ɼ�Ϊ������ơ���ת��Ϊ���ٷ��ơ�
    for iCol = 1:size(raw,2)
        raw(:,iCol) = ConvertScale(raw(:,iCol));
    end
    % ɸѡû�гɼ���ѧ��
    iCols_Overall = contains(headTitles,'�ܷ�')| ...
                    contains(headTitles,'�����ɼ�')| ...
                    contains(headTitles,'�ۺϳɼ�')| ...
                    contains(headTitles,'Overall');
    if ~any(iCols_Overall)
        cprintf('err','�����󡿳ɼ������������ۺϳɼ��У�\n')
        return
    end
    % ��iCols_Overall�ж�������ʱѡ��һ��
    iCol_Overall = find(iCols_Overall,1);
    % ����raw��1�С���iCol_Overall�е���������ѡ�����ݴ���ķ�ʽ
    switch class(raw{1,iCol_Overall})
        case('char')
            idx_Completed = ~isnan(str2double(raw(:,iCol_Overall)));
        case('double')
            idx_Completed = ~isnan([raw{:,iCol_Overall}]);
        otherwise
    end
    raw = raw(idx_Completed,:);
    % �ӵ���ɼ����������в��Ұ༶��
    iCols_Class = contains(headTitles,'�༶')|contains(headTitles,'Class');
    Detail.Class = raw(:,iCols_Class);
    % ɸѡ��Դ����רҵ��ѧ��
    idx_ext = cellfun(@(c) ischar(c) && (contains(c, '��Դ��ѧ') || ...
                                         contains(c, '��Դ����') || ...
                                         contains(c, '�ܻ�')) , Detail.Class);
    Detail.Class = Detail.Class(idx_ext);
    raw = raw(idx_ext,:);
    % �ӵ���ɼ����������в���ѧ������
    iCols_Name = contains(headTitles,'ѧ������')|contains(headTitles,'Student');
    if ~any(iCols_Name)
        iCols_Name = contains(headTitles,'����')|contains(headTitles,'Name');
    end
    Detail.Name = raw(:,iCols_Name);
    % �ӵ���ɼ����������в���ѧ��
    iCols_SN = contains(headTitles,'ѧ��')|contains(headTitles,'SN');
    Detail.SN = raw(:,iCols_SN);
    % ��ÿ��ͬѧѧ�ŵĺ�4λ
    Detail.Year = cellfun(@(x) x(1:4), raw(:,iCols_SN), 'UniformOutput', false);
    % ������Ŀ��ָ����ʦ��Ҳ���䵼��
    iCols_Title = contains(headTitles,'����')|contains(headTitles,'Title');
    if any(iCols_Title)
        Detail.Title = raw(:,iCols_Title);
    end
    iCols_Supervisor = contains(headTitles,'��ʦ����')|contains(headTitles,'Supervisor');
    if any(iCols_Supervisor)
        Detail.Supervisor = raw(:,iCols_Supervisor);
    end
    % �ӵ���ɼ����������а��ɼ���������ҳɼ�����
    iCols_Data = false(1,length(headTitles));
    for iHead = 1:sum(Spec)
        iCols_Data = iCols_Data|strcmp(DefHeadCodes(iHead), headTitleCodes);
    end
    if ~any(iCols_Data)
        % ͨ�����˷�ʽ���Ų��ҳɼ�����������
        for iHead = 1:sum(Spec)
            iCols_Data = iCols_Data|strcmp(DefHeadCodes(iHead), headTitles);
        end
        if ~any(iCols_Data)
            cprintf('err','�����󡿳ɼ����붨�岻ƥ�䣡')
            return
        end
    end
    ScoreData = cell2table(raw(:,iCols_Data), 'VariableNames', DefHeadCodes);
    Detail = [struct2table(Detail),ScoreData];
end

end
