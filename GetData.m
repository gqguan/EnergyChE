function [output, db_Curriculum, db_GradRequire] = GetData1(Years, opt)
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
for i = 1:height(db_Curriculum)
%     if i == 49
%         disp('debugging')
%     end
    output_AllYears(i).ID = db_Curriculum.ID(i);
    output_AllYears(i).Name = db_Curriculum.Name(i);
    output_AllYears(i).Credit = db_Curriculum.Credit(i);
    switch opt
        case 0
            getData = dataset(strcmp({dataset.CourseID}, db_Curriculum.ID(i)));
        case 1
            getData = dataset1(strcmp({dataset1.CourseID}, db_Curriculum.ID(i)));
    end
    if ~isempty(getData)
        Transcript = CombineTranscript(output_AllYears(i).Name{:}, getData);
        % Get the categories according to year
        YearList = categories(categorical(Transcript.Detail.Year));
        for j = 1:length(YearList)
            fieldname = strcat('class', YearList{j});
            idx_ExtractYear = strcmp(Transcript.Detail.Year, YearList(j));
            output_AllYears(i).(fieldname).Detail = Transcript.Detail(idx_ExtractYear,:);
            output_AllYears(i).(fieldname).Definition = Transcript.Definition;
        end     
    end
    for j = 1:length(Years)
        fieldname = Years(j);
        if find(ismember(fieldnames(output_AllYears(i)), fieldname{:})) ~= 0
            if isempty(output_AllYears(i).(fieldname{:}))
                BlankRecord(BlankRecord_idx).idx = i;
                BlankRecord(BlankRecord_idx).Name = db_Curriculum.Name(i);
                BlankRecord(BlankRecord_idx).ID = db_Curriculum.ID(i);
                BlankRecord(BlankRecord_idx).IDv2018 = db_Curriculum.IDv2018(i);
                BlankRecord(BlankRecord_idx).class = fieldname;
                BlankRecord_idx = BlankRecord_idx+1;
            end
        end
    end
end

%% Recheck the empty ones with IDv2018
for BlankRecord_idx = 1:length(BlankRecord)
    i = BlankRecord(BlankRecord_idx).idx;
    % 按2018版课程代码提取数据
    getData = dataset(strcmp({dataset.CourseID}, db_Curriculum.IDv2018(i)));
    if ~isempty(getData)
        % 合并具有相同课程代码的成绩单
        Transcript = CombineTranscript(output_AllYears(i).Name{:}, getData);
        % 从年级名称（例如class2013）提取年级字段
        fieldname = BlankRecord(BlankRecord_idx).class{:}; 
        year = fieldname((end-3):end);
        % 按年级筛选成绩单
        idx_ExtractedYear = strcmp(Transcript.Detail.Year, year);
        output_AllYears(i).(fieldname).Detail = Transcript.Detail(idx_ExtractedYear,:);
        output_AllYears(i).(fieldname).Definition = Transcript.Definition;
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
        sprintf('【错误】找不到%s级课程数据!\n', Years{iYear})
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
function Transcript = CombineTranscript(CourseName, dataset_extracted)
    if ~strcmp(CourseName, '毕业设计(论文)')
        Definition = dataset_extracted(1).Definition;
        StudentScore = dataset_extracted(1).StudentScore;
        Detail = StudentScore;
        % 在成绩单中附加教师和选课代码
        if ~isempty(dataset_extracted(1).Teacher)
            Teacher = cell(height(StudentScore),1);
            Teacher(:,1) = {dataset_extracted(1).Teacher};
            Detail = [Detail,table(Teacher)];
        end
        if ~isempty(dataset_extracted(1).CourseCode)
            CourseCode = cell(height(StudentScore),1);
            CourseCode(:,1) = {dataset_extracted(1).CourseCode};
            Detail = [Detail,table(CourseCode)];
        end
        NumExtracted = length(dataset_extracted);
        if NumExtracted >= 2
            for iData = 2:NumExtracted
                if isequaln(Definition,dataset_extracted(iData).Definition)
                    StudentScore = dataset_extracted(iData).StudentScore;
                    Detail1 = StudentScore;
                    if ~isempty(dataset_extracted(iData).Teacher)
                        Teacher = cell(height(StudentScore),1);
                        Teacher(:,1) = {dataset_extracted(iData).Teacher};
                        Detail1 = [Detail1,table(Teacher)];
                    end
                    if ~isempty(dataset_extracted(iData).CourseCode)
                        CourseCode = cell(height(StudentScore),1);
                        CourseCode(:,1) = {dataset_extracted(iData).CourseCode};
                        Detail1 = [Detail1,table(CourseCode)];
                    end
                    Detail = [Detail;Detail1];
                else
                    sprintf('【警告】课程“%s”存在%d张成绩单，合并时发现第%d张成绩单的定义与第1张不同：输出前%d张成绩单!\n', ...
                            CourseName, NumExtracted, iData, iData-1)
                    break
                end
            end
        end
    else
        Definition = dataset_extracted(1).Definition;
        StudentScore = dataset_extracted(1).StudentScore;
        Detail = StudentScore;
        NumExtracted = length(dataset_extracted);
        if NumExtracted >= 2
            for iData = 2:NumExtracted
                if isequaln(Definition,dataset_extracted(iData).Definition)
                    StudentScore = dataset_extracted(iData).StudentScore;
                    Detail = [Detail;StudentScore];
                else
                    sprintf('【警告】课程“%s”存在%d张成绩单，合并时发现第%d张成绩单的定义与第1张不同：输出前%d张成绩单!\n', ...
                            CourseName, NumExtracted, iData, iData-1)
                    break
                end
            end
        end
    end
    % 输出带成绩单定义的成绩单
    Transcript.Definition = Definition;
    Transcript.Detail = Detail;
end

end