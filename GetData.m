function [output, db_Curriculum, db_GradRequire] = GetData1(Years, opt)
%% �ӹ����ռ��е�dataset��������ȡָ���꼶�ĸ��γ�ȫ��ѧ���ɼ���
%
% ����˵����
% ��1���ɲ������������������ȱʡֵ����
% ��2���γ̰�db_Curriculum�еĿγ�����ͨ��ƥ�Կγ̱��CourseIDʶ��
% ��3������db_Curriculum��CourseID�Ҳ����κογ̳ɼ������ٰ�IDv2018ƥ��
%
% ����˵����
% input arguments
% Years - (str array) default as {'class2013', 'class2014', 'class2015'}
% opt   - (integer) 0 - ȱʡֵ����dataset�е���ɼ���
%                   1 - ��dataset1�е���ɼ���
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
    % ��2018��γ̴�����ȡ����
    getData = dataset(strcmp({dataset.CourseID}, db_Curriculum.IDv2018(i)));
    if ~isempty(getData)
        % �ϲ�������ͬ�γ̴���ĳɼ���
        Transcript = CombineTranscript(output_AllYears(i).Name{:}, getData);
        % ���꼶���ƣ�����class2013����ȡ�꼶�ֶ�
        fieldname = BlankRecord(BlankRecord_idx).class{:}; 
        year = fieldname((end-3):end);
        % ���꼶ɸѡ�ɼ���
        idx_ExtractedYear = strcmp(Transcript.Detail.Year, year);
        output_AllYears(i).(fieldname).Detail = Transcript.Detail(idx_ExtractedYear,:);
        output_AllYears(i).(fieldname).Definition = Transcript.Definition;
    end
end

%% Output
AllFields = fieldnames(output_AllYears);
% �γ���Ϣ��
idx_CourseInfo = ~contains(AllFields,'class');
idx_ExtractCol = idx_CourseInfo;
% 
for iYear = 1:length(Years)
    idx_Year = strcmp(AllFields,Years(iYear));
    if any(idx_Year)
        idx_ExtractCol = idx_ExtractCol|idx_Year;
    else
        sprintf('�������Ҳ���%s���γ�����!\n', Years{iYear})
    end
end
output = struct();
for iCourse = 1:length(output_AllYears)
    getFieldNames = AllFields(idx_ExtractCol);
    for iField = 1:length(getFieldNames)
        output(iCourse).(getFieldNames{iField}) = output_AllYears(iCourse).(getFieldNames{iField});
    end
end


%% ��ӽ�ʦ��ѡ�δ����в��ϲ��ɼ������γ̡���ҵ���(����)��ֻ�ϲ��ɼ�����
function Transcript = CombineTranscript(CourseName, dataset_extracted)
    if ~strcmp(CourseName, '��ҵ���(����)')
        Definition = dataset_extracted(1).Definition;
        StudentScore = dataset_extracted(1).StudentScore;
        Detail = StudentScore;
        % �ڳɼ����и��ӽ�ʦ��ѡ�δ���
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
                    sprintf('�����桿�γ̡�%s������%d�ųɼ������ϲ�ʱ���ֵ�%d�ųɼ����Ķ������1�Ų�ͬ�����ǰ%d�ųɼ���!\n', ...
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
                    sprintf('�����桿�γ̡�%s������%d�ųɼ������ϲ�ʱ���ֵ�%d�ųɼ����Ķ������1�Ų�ͬ�����ǰ%d�ųɼ���!\n', ...
                            CourseName, NumExtracted, iData, iData-1)
                    break
                end
            end
        end
    end
    % ������ɼ�������ĳɼ���
    Transcript.Definition = Definition;
    Transcript.Detail = Detail;
end

end