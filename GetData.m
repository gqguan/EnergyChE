function [output, db_Curriculum, db_GradRequire] = GetData(Years, opt)
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
    % ��2018��γ̴�����ȡ����
    getData = dataset(strcmp({dataset.CourseID}, db_Curriculum.IDv2018(iCourse)));
    if ~isempty(getData)
        Year = BlankRecord(BlankRecord_idx).class;
        Transcript = CombineTranscript(output_AllYears(iCourse).Name{:}, Year, getData);
        if isempty(Transcript.Detail)
            fprintf('�����桿�Ҳ���%sѧ��γ̡�%s���ɼ�����\n', Year, output_AllYears(iCourse).Name{:})
        else
            fprintf('%sѧ��γ̡�%s���ɼ����Ѹ��¡�\n', Year, output_AllYears(iCourse).Name{:})
            output_AllYears(iCourse).(Year).Detail = Transcript.Detail;
            output_AllYears(iCourse).(Year).Definition = Transcript.Definition;
        end
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
        fprintf('�������Ҳ���%s���γ�����!\n', Years{iYear})
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
function Transcript = CombineTranscript(CourseName, Class, dataset_extracted)
    Definition = struct();
    Detail = table();
    % ����ѧ��Ϳγ̴���ķ�������
    tdata = struct2table(dataset_extracted, 'AsArray', true);
    tdata.AcadYear = categorical(tdata.AcadYear);
    tdata.CourseID = categorical(tdata.CourseID);
    % ���ݡ��γ����ơ��ӡ��γ̱��л�ȡ���γ̴��롱
    CourseID = db_Curriculum.ID(strcmp(db_Curriculum.Name,CourseName));
    if length(CourseID) ~= 1
        fprintf('�����󡿿γ̱��д��ڶ��ſγ̡�%s����ÿγ�δ���ڿγ̱��У�', CourseName)
        return
    end
    % ��ָ��ѧ����ȡָ���γ̵ĳɼ���
    idx_GetTab = tdata.AcadYear == GetAcadYear(CourseName, Class);
    GetTabs = tdata(idx_GetTab,:);
    % ���ɼ��������Ƿ�һ��
    GetStructs = table2struct(GetTabs);
    if length(GetStructs) >=2 && isequal(GetStructs.Definition)
        Definition = GetStructs(1).Definition;
        if ~strcmp(CourseName, '��ҵ���(����)')
            % �ڳɼ����и��ӽ�ʦ��ѡ�δ���
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
        % �ϲ��ɼ���
        Detail = vertcat(GetTabs.StudentScore{:});
    elseif length(GetStructs) == 1
        Definition = GetStructs(1).Definition;
        if ~strcmp(CourseName, '��ҵ���(����)')
            % �ڳɼ����и��ӽ�ʦ��ѡ�δ���
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
        fprintf('�����桿�Ҳ���%sѧ��γ̡�%s���ɼ�����\n', GetAcadYear(CourseName, Class), CourseName)
    else
        fprintf('�����桿%sѧ��γ̡�%s�����ڶ�����岻ͬ�ĳɼ�����', GetAcadYear(CourseName, Class), CourseName)
        fprintf('�������һ���γ̳ɼ�����\n')
        GetTabs = tdata(idx_GetTab(end),:);
        GetStructs = table2struct(GetTabs);
        Transcript = CombineTranscript(CourseName, Class, GetStructs);
    end
    % ������ɼ�������ĳɼ���
    Transcript.Definition = Definition;
    Transcript.Detail = Detail;
end

% �������롰�꼶����Class���͡��γ̱��е��Ͽ�ѧ�ڰ��ż������롰�γ̡���CourseName������Ӧѧ��
function AcadYear = GetAcadYear(CourseName, Class)
    if ~ischar(CourseName)
        fprintf('�������������CourseName�������Ͳ���ȷ��\n')
        return
    end
    % ��ȡ�γ����ƺ���γ��嵥ƥ�ԣ�ȷ���γ̴�����Ͽε�ѧ��
    FoundIdx = strcmp(CourseName, db_Curriculum.Name);
    if any(FoundIdx) && (ischar(Class))
        % �����롰�꼶�������л���꼶
        Class = Class((end-3):end);
        % �γ�ִ�е�ѧ��
        switch CourseName
            case('����������')
                AcadYear_Num = str2double(Class)+3;
            case('�����Ͷ�')
                AcadYear_Num = str2double(Class)+4;
            otherwise
                Semester = db_Curriculum.Semester(FoundIdx);
                if isnumeric(Semester)
                    AcadYear_Num = str2double(Class)+round(Semester/2);
                else
                    fprintf('�����桿�γ̡�%s����ѧ������Ϊ����ֵ��', CourseName)
                end
        end
        % �ɿγ�ִ�е�ѧ�������꼶ȷ���γ̽��е�ѧ��
        AcadYear = [num2str(AcadYear_Num-1),'-',num2str(AcadYear_Num)];
    else
        fprintf('�����桿�γ̡�%s�����ڿγ̱��л�����Class��������\n', CourseName)
        AcadYear = 'NULL';
    end
end

end