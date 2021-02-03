%% ��QE_Courses�е����ֹ�¼��Ŀγ̴�ɶȽ��
%
% by Dr. Guan Guoqiang @ SCUT on 2020-07-10

function [QE_Courses CourseArray] = EA_ImportQECourses(CourseArray, QE_Courses)
%% ��ʼ��
% ����������
switch nargin
    case(0)
        % ��QE_Courses.mat�е���CourseArray��QE_Courses����
        cprintf('Comments', '��QE_Courses.mat�е���CourseArray��QE_Courses������\n')
        load('QE_Courses.mat','CourseArray')
        load('QE_Courses.mat','QE_Courses')
    case(1)
        % ����QE_Courses
        cprintf('Comments', '��QE_Courses.mat�е���QE_Courses������\n')
        load('QE_Courses.mat','QE_Courses')
    case(2)
        cprintf('Comments', '��QE_Courses�е����ֹ�¼��Ŀγ̴�ɶȽ����\n')
    otherwise
        cprintf('err','�����������������\n')
        return
end

%% �Ƚ����ݽṹ��QE_CoursesӦ����CourseArray��ȫ���ֶ�
varName = 'CourseArray';
% ���CourseArray�Ƿ����ָ���ֶ�
NeedFields1 = {'ID' 'Name' 'Class' 'Requirements'};
NeedFields2 = {'IdxUniNum' 'Result'};
if sum(contains(fieldnames(CourseArray),NeedFields1)) == length(NeedFields1)
    cprintf('Comments','����Ϣ��%s�ĵײ�ṹ���������\n',varName)
    % ���CourseArray�����ֶε���������
    for iField = 1:numel(NeedFields1)
        chkField = NeedFields1{iField};
        className1 = class(CourseArray(1).(chkField));
        className2 = class(QE_Courses(1).(chkField));
        if ~isequal(className1,className2)
            cprintf('err','�����桿����%s.%s����������Ϊ��%s�������ǡ�%s����\n', ...
                    varName,chkField,className1,className2)
            opt = input('�Ƿ���Ҫ�������Զ�����cell��ת��Ϊ��char��[Y/N]','s');
            if opt == 'Y'
                switch [className1,'2',className2]
                    case('cell2char')
                        cprintf('Comments','�Զ�����cell��ת��Ϊ��char��...\n')
                        for iCourse = 1:length(CourseArray)
                            CourseArray(iCourse).(chkField) = CourseArray(iCourse).(chkField){:};
                            % ���CourseArray.Class�����ǡ�2015�������ǡ�class2015��
                            CourseArray(iCourse).Class = CourseArray(iCourse).Class(end-3:end);
                        end
                    otherwise
                        cprintf('err','�������������Ͳ���ȷ���޷��Զ�ת����\n')
                end
            else
                cprintf('err','�������Ͳ�ƥ����ܵ������ݵ�������\n')
            end
        end
    end
    % ���CourseArray.Requirements
    chkStruct = CourseArray.(NeedFields1{end});
    if sum(contains(fieldnames(chkStruct),NeedFields2)) == length(NeedFields2)
        cprintf('Comments','����Ϣ��%s.Requirements�ṹ���������\n',varName)
        % ������QE_Courses���CourseArray�еĿγ̴�ɶȽ��
        for iCourse = 1:numel(CourseArray)
            % ����Ƿ�������ͬ�Ŀγ�Ŀ���ɶȽ��
            idx_Repeat = strcmp({QE_Courses.ID},CourseArray(iCourse).ID)&...
                         strcmp({QE_Courses.Class},CourseArray(iCourse).Class);
            if ~any(idx_Repeat)
                AddRow = numel(QE_Courses)+1;
                for iField = 1:numel(NeedFields1)
                    FieldName = NeedFields1{iField};
                    QE_Courses(AddRow).(FieldName) = CourseArray(iCourse).(FieldName);
                end
            else
                fprintf('�����桿%s���γ̡�%s�������ظ�δ���뵽QE_Courses�У�\n',CourseArray(iCourse).Class,CourseArray(iCourse).Name)
            end
        end
    end
end