function [output, db_Curriculum, db_GradRequire] = GetData(Years, opt)
%% 从工作空间中的dataset变量中提取指定年级的各课程全部学生成绩单
%
% 功能说明：
% （1）可不输入输入参数，程序按缺省值导入
% （2）课程按db_Curriculum中的课程排序，通过匹对课程编号CourseID识别
% （3）若按db_Curriculum中CourseID找不到任何课程成绩单，再按IDv2018匹对
%
% 参数说明：
% input arguments
% Years - (str array) default as {'class2013', 'class2014', 'class2015'}
% opt   - (integer) 0 - 缺省值，从dataset中导入成绩单
%                   1 - 从dataset1中导入成绩单
%
% output arguments
% output - (struct array) outcomes for all courses
% db_Curriculum - (table) preset curriculum
% db_GradRequire - (table) preset graduation requirement
%
% by Dr. GUAN Guoqiang @ SCUT on 2019/9/21
%                                2020/6/27

%% Initialize
clear detail BlankRecord;
load('database.mat', 'db_Curriculum', 'db_GradRequire', 'dataset', 'dataset1')
BlankRecord_idx = 1;
BlankRecord = struct([]);
output_AllYears = struct([]);
% Build a default table to show the completion of file imported
switch nargin
    case 1
        opt = 0;
    case 0
        Years = {'class2013', 'class2014', 'class2015'};
        opt = 0;
end

%% Get all transcripts of given course according to the course ID
for iCourse = 1:height(db_Curriculum)
%     if iCourse == 53
%         disp('debugging')
%     end
    disp(db_Curriculum.Name{iCourse})
    output_AllYears(iCourse).ID = db_Curriculum.ID(iCourse);
    output_AllYears(iCourse).Name = db_Curriculum.Name(iCourse);
    output_AllYears(iCourse).Credit = db_Curriculum.Credit(iCourse);
    switch opt
        case 0
            getData = dataset(strcmp({dataset.CourseID}, db_Curriculum.ID(iCourse)));
        case 1
            getData = dataset1(strcmp({dataset1.CourseID}, db_Curriculum.ID(iCourse)));
    end
    if ~isempty(getData)
        for iYear = 1:length(Years)
            Transcript = CombineTranscript(output_AllYears(iCourse).Name{:}, Years{iYear}, getData);
            Year = Years{iYear};         
            if isempty(Transcript.Detail)
                BlankRecord(BlankRecord_idx).idx = iCourse;
                BlankRecord(BlankRecord_idx).Name = db_Curriculum.Name(iCourse);
                BlankRecord(BlankRecord_idx).ID = db_Curriculum.ID(iCourse);
                BlankRecord(BlankRecord_idx).IDv2018 = db_Curriculum.IDv2018(iCourse);
                BlankRecord(BlankRecord_idx).class = Year;
                BlankRecord_idx = BlankRecord_idx+1;
            else
                output_AllYears(iCourse).(Year).Detail = Transcript.Detail;
                output_AllYears(iCourse).(Year).Definition = Transcript.Definition;                 
            end         
        end    
    end
end

%% Recheck the empty ones with IDv2018
for BlankRecord_idx = 1:length(BlankRecord)
    iCourse = BlankRecord(BlankRecord_idx).idx;
    % 按2018版课程代码提取数据
    getData = dataset(strcmp({dataset.CourseID}, db_Curriculum.IDv2018(iCourse)));
    if ~isempty(getData)
        Year = BlankRecord(BlankRecord_idx).class;
        Transcript = CombineTranscript(output_AllYears(iCourse).Name{:}, Year, getData);
        if isempty(Transcript.Detail)
            fprintf('【警告】找不到%s学年课程“%s”成绩单！\n', Year, output_AllYears(iCourse).Name{:})
        else
            fprintf('%s学年课程“%s”成绩单已更新。\n', Year, output_AllYears(iCourse).Name{:})
            output_AllYears(iCourse).(Year).Detail = Transcript.Detail;
            output_AllYears(iCourse).(Year).Definition = Transcript.Definition;
        end
    end
end

%% Output
AllFields = fieldnames(output_AllYears);
% 课程信息列
idx_CourseInfo = ~contains(AllFields,'class');
idx_ExtractCol = idx_CourseInfo;
% 
for iYear = 1:length(Years)
    idx_Year = strcmp(AllFields,Years(iYear));
    if any(idx_Year)
        idx_ExtractCol = idx_ExtractCol|idx_Year;
    else
        fprintf('【错误】找不到%s级课程数据!\n', Years{iYear})
    end
end
output = struct();
for iCourse = 1:length(output_AllYears)
    getFieldNames = AllFields(idx_ExtractCol);
    for iField = 1:length(getFieldNames)
        output(iCourse).(getFieldNames{iField}) = output_AllYears(iCourse).(getFieldNames{iField});
    end
end


%% 添加教师和选课代码列并合并成绩单（课程“毕业设计(论文)”只合并成绩单）
function Transcript = CombineTranscript(CourseName, Class, dataset_extracted)
    Definition = struct();
    Detail = table();
    % 建立学年和课程代码的分类索引
    tdata = struct2table(dataset_extracted, 'AsArray', true);
    tdata.AcadYear = categorical(tdata.AcadYear);
    tdata.CourseID = categorical(tdata.CourseID);
    % 根据“课程名称”从“课程表”中获取“课程代码”
    CourseID = db_Curriculum.ID(strcmp(db_Curriculum.Name,CourseName));
    if length(CourseID) ~= 1
        fprintf('【错误】课程表中存在多门课程“%s”或该课程未列于课程表中！', CourseName)
        return
    end
    % 按指定学年提取指定课程的成绩单
    idx_GetTab = tdata.AcadYear == GetAcadYear(CourseName, Class);
    GetTabs = tdata(idx_GetTab,:);
    % 检查成绩单定义是否一致
    GetStructs = table2struct(GetTabs);
    if length(GetStructs) >=2 && isequal(GetStructs.Definition)
        Definition = GetStructs(1).Definition;
        if ~strcmp(CourseName, '毕业设计(论文)')
            % 在成绩单中附加教师和选课代码
            for iGetTab = 1:height(GetTabs)
                if ~isempty(GetTabs.Teacher{iGetTab})
                    Teacher = cell(height(GetTabs.StudentScore{iGetTab}),1);
                    Teacher(:,1) = GetTabs.Teacher(iGetTab);
                    GetTabs.StudentScore{iGetTab} = [GetTabs.StudentScore{iGetTab},table(Teacher)];
                end
                if ~isempty(GetTabs.CourseCode{iGetTab})
                    CourseCode = cell(height(GetTabs.StudentScore{iGetTab}),1);
                    CourseCode(:,1) = GetTabs.CourseCode(iGetTab);
                    GetTabs.StudentScore{iGetTab} = [GetTabs.StudentScore{iGetTab},table(CourseCode)];
                end                
            end
        end
        % 合并成绩单
        Detail = vertcat(GetTabs.StudentScore{:});
    elseif length(GetStructs) == 1
        Definition = GetStructs(1).Definition;
        if ~strcmp(CourseName, '毕业设计(论文)')
            % 在成绩单中附加教师和选课代码
            iGetTab = 1;
            if ~isempty(GetTabs.Teacher{iGetTab})
                Teacher = cell(height(GetTabs.StudentScore{iGetTab}),1);
                Teacher(:,1) = GetTabs.Teacher(iGetTab);
                GetTabs.StudentScore{iGetTab} = [GetTabs.StudentScore{iGetTab},table(Teacher)];
            end
            if ~isempty(GetTabs.CourseCode{iGetTab})
                CourseCode = cell(height(GetTabs.StudentScore{iGetTab}),1);
                CourseCode(:,1) = GetTabs.CourseCode(iGetTab);
                GetTabs.StudentScore{iGetTab} = [GetTabs.StudentScore{iGetTab},table(CourseCode)];
            end                
        end
        Detail = GetTabs.StudentScore{:};
    elseif isempty(GetStructs)
        fprintf('【警告】找不到%s学年课程“%s”成绩单！\n', GetAcadYear(CourseName, Class), CourseName)
    else
        fprintf('【警告】%s学年课程“%s”存在多个定义不同的成绩单，', GetAcadYear(CourseName, Class), CourseName)
        fprintf('保留最后一个课程成绩单！\n')
        GetTabs = tdata(idx_GetTab(end),:);
        GetStructs = table2struct(GetTabs);
        Transcript = CombineTranscript(CourseName, Class, GetStructs);
    end
    % 输出带成绩单定义的成绩单
    Transcript.Definition = Definition;
    Transcript.Detail = Detail;
end

% 根据输入“年级”（Class）和“课程表”中的上课学期安排计算输入“课程”（CourseName）的相应学年
function AcadYear = GetAcadYear(CourseName, Class)
    if ~ischar(CourseName)
        fprintf('【错误】输入参数CourseName数据类型不正确！\n')
        return
    end
    % 获取课程名称后与课程清单匹对，确定课程代码和上课的学期
    FoundIdx = strcmp(CourseName, db_Curriculum.Name);
    if any(FoundIdx) && (ischar(Class))
        % 从输入“年级”参数中获得年级
        Class = Class((end-3):end);
        % 课程执行的学期
        switch CourseName
            case('形势与政策')
                AcadYear_Num = str2double(Class)+3;
            case('公益劳动')
                AcadYear_Num = str2double(Class)+4;
            otherwise
                Semester = db_Curriculum.Semester(FoundIdx);
                if isnumeric(Semester)
                    AcadYear_Num = str2double(Class)+round(Semester/2);
                else
                    fprintf('【警告】课程“%s”的学年数据为非数值！', CourseName)
                end
        end
        % 由课程执行的学期数和年级确定课程进行的学年
        AcadYear = [num2str(AcadYear_Num-1),'-',num2str(AcadYear_Num)];
    else
        fprintf('【警告】课程“%s”不在课程表中或输入Class参数有误！\n', CourseName)
        AcadYear = 'NULL';
    end
end

end