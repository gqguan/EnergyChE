%% 向QE_Courses中导入手工录入的课程达成度结果
%
% by Dr. Guan Guoqiang @ SCUT on 2020-07-10

function [QE_Courses CourseArray] = EA_ImportQECourses(CourseArray, QE_Courses)
%% 初始化
% 输入参数检查
switch nargin
    case(0)
        % 从QE_Courses.mat中导入CourseArray和QE_Courses变量
        cprintf('Comments', '从QE_Courses.mat中导入CourseArray和QE_Courses变量。\n')
        load('QE_Courses.mat','CourseArray')
        load('QE_Courses.mat','QE_Courses')
    case(1)
        % 导入QE_Courses
        cprintf('Comments', '从QE_Courses.mat中导入QE_Courses变量。\n')
        load('QE_Courses.mat','QE_Courses')
    case(2)
        cprintf('Comments', '向QE_Courses中导入手工录入的课程达成度结果。\n')
    otherwise
        cprintf('err','【错误】输入参数有误！\n')
        return
end

%% 比较数据结构，QE_Courses应包括CourseArray的全部字段
varName = 'CourseArray';
% 检查CourseArray是否存在指定字段
NeedFields1 = {'ID' 'Name' 'Class' 'Requirements'};
NeedFields2 = {'IdxUniNum' 'Result'};
if sum(contains(fieldnames(CourseArray),NeedFields1)) == length(NeedFields1)
    cprintf('Comments','【信息】%s的底层结构检查正常！\n',varName)
    % 检查CourseArray导入字段的数据类型
    for iField = 1:numel(NeedFields1)
        chkField = NeedFields1{iField};
        className1 = class(CourseArray(1).(chkField));
        className2 = class(QE_Courses(1).(chkField));
        if ~isequal(className1,className2)
            cprintf('err','【警告】发现%s.%s的数据类型为“%s”而不是“%s”！\n', ...
                    varName,chkField,className1,className2)
            opt = input('是否需要本程序自动将“cell”转换为“char”[Y/N]','s');
            if opt == 'Y'
                switch [className1,'2',className2]
                    case('cell2char')
                        cprintf('Comments','自动将“cell”转换为“char”...\n')
                        for iCourse = 1:length(CourseArray)
                            CourseArray(iCourse).(chkField) = CourseArray(iCourse).(chkField){:};
                            % 检查CourseArray.Class数据是‘2015’而不是‘class2015’
                            CourseArray(iCourse).Class = CourseArray(iCourse).Class(end-3:end);
                        end
                    otherwise
                        cprintf('err','【错误】数据类型不正确，无法自动转换！\n')
                end
            else
                cprintf('err','数据类型不匹配可能导致数据导入问题\n')
            end
        end
    end
    % 检查CourseArray.Requirements
    chkStruct = CourseArray.(NeedFields1{end});
    if sum(contains(fieldnames(chkStruct),NeedFields2)) == length(NeedFields2)
        cprintf('Comments','【信息】%s.Requirements结构检查正常！\n',varName)
        % 依次向QE_Courses添加CourseArray中的课程达成度结果
        for iCourse = 1:numel(CourseArray)
            % 检查是否已有相同的课程目标达成度结果
            idx_Repeat = strcmp({QE_Courses.ID},CourseArray(iCourse).ID)&...
                         strcmp({QE_Courses.Class},CourseArray(iCourse).Class);
            if ~any(idx_Repeat)
                AddRow = numel(QE_Courses)+1;
                for iField = 1:numel(NeedFields1)
                    FieldName = NeedFields1{iField};
                    QE_Courses(AddRow).(FieldName) = CourseArray(iCourse).(FieldName);
                end
            else
                fprintf('【警告】%s级课程“%s”数据重复未导入到QE_Courses中！\n',CourseArray(iCourse).Class,CourseArray(iCourse).Name)
            end
        end
    end
end