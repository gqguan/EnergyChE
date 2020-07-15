%% ��ҵҪ���ɶȼ���
%
% ����˵����
% ��1������db_Curriculum�еĿγ̾��󣬰���ҵҪ������Ϊ�г���Ӧ�ı��޿γ�
% ��2��������Ӧ�γ̶�Ӧ��ָ����ɶȷ������
% ��3���ԡ�ĳ�γ̵�ѧ��/��ָ���ȫ���γ̵���ѧ�֡�ΪȨ��
% ��4�������ָ���ļ�Ȩƽ��ֵ
%
% ������
% output - ���ṹ������
%   Contents - ����Ԫ��������
%   Heads - ����Ԫ���󣩱�ͷ
% ��1������ҵҪ��ָ��㼰��֧�ſγ��б���Ӧָ��Ŀγ̴�ɶȡ�ָ����ɶȺͱ�ҵҪ���ɶȽ��
% ��2����ҵҪ��������������ݱ�
%
% by Dr. Guan Guoqiang @ SCUT on 2020-07-08

function output = EA_GradReq(QE_Courses,db_Curriculum)
%% ��ʼ��
% ��鵱ǰ�����ռ��д������������
if ~exist('QE_Courses','var') % �γ�Ŀ���ɶ�����
    cprintf('Comments','���ļ�QE_Courses.mat�е��롰QE_Courses��������\n')
    load('QE_Courses.mat','QE_Courses')
end
if ~exist('db_Curriculum','var') % �γ��б�
    cprintf('Comments','���ļ�database.mat�е��롰db_Curriculum��������\n')
    load('database.mat','db_Curriculum')
end
if ~exist('db_Indicators','var') % �γ��б�
    cprintf('Comments','���ļ�database.mat�е��롰db_Indicators��������\n')
    load('database.mat','db_Indicators')
end
% ��ʼ���������
tout1 = cell(sum(sum(db_Curriculum.ReqMatrix)),8);
t1head = {'��ҵҪ��' '��ҵҪ��ָ���' '֧�ſγ�' 'ѧ��' 'Ȩ��' '�γ�Ŀ���ɶ�' 'ָ����ɶ�' '��ҵҪ���ɶ�'};
tout2 = cell(sum(sum(db_Curriculum.ReqMatrix)),7);
t2head = {'��ҵҪ��' '�۲��' '�������۵Ľ�ѧ����' '���۷���' '��������' '����������' '�γɵļ�¼����'};

iRow = 1; % tout1��tout2����к�

%% ���ָ���꼶������ɴ�ɶȷ����Ŀγ��б�
% �����꼶
Class = input('������б�ҵҪ���ɶȼ����꼶', 's');
% ɸѡָ���꼶������ɴ�ɶȷ����Ŀγ��б�
QE_Courses1 = QE_Courses(strcmp({QE_Courses.Class},Class));

%% ���ܣ�1��
% ���������ҵҪ��
ReqLists = EA_DefGR;
for iReq = 1:length(ReqLists)
    iRowGR = iRow; % ��tout2�еı�ҵҪ����
    Content1 = sprintf('%d %s', iReq, ReqLists(iReq).Brief);
    tout1{iRow,1} = Content1;
    tout2{iRow,1} = tout1{iRow,1};
    NumIdt = length(ReqLists(iReq).Indicators);
    QEIndicators = zeros(NumIdt,1);
    for iIdt = 1:NumIdt
        Content2 = sprintf('%s %s', ReqLists(iReq).Indicators(iIdt).UniNum, ReqLists(iReq).Indicators(iIdt).Spec);
        tout1{iRow,2} = Content2;
        tout2{iRow,2} = tout1{iRow,2};
        UniNum = ReqLists(iReq).Indicators(iIdt).UniNum;
        idxs = strcmp(db_Indicators.UniNum,UniNum);
        if sum(idxs) == 1
            idx_Courses = db_Curriculum.ReqMatrix(:,idxs);
            Courses = db_Curriculum.Name(logical(idx_Courses)); % �г���ָ����ȫ��֧�ſγ����ƣ�����������
            IDs = db_Curriculum.ID(logical(idx_Courses)); % �г���ָ����ȫ��֧�ſγ̴��루����������
            Credits = db_Curriculum.Credit(logical(idx_Courses)); % �г���ָ����ȫ��֧�ſγ�ѧ�֣���ֵ��������
            CourseWeights = Credits/sum(Credits); % �����ָ����ȫ��֧�ſγ�Ȩ�أ���ֵ��������
            QECourses = zeros(size(Courses)); % ��ʼ����֧�ſγ̵Ľ�ѧĿ���ɽ��
            EvalMethods = cell(size(Courses)); % ��ʼ��tout2�и�֧�ſγ̣������۵Ľ�ѧ���ڣ������۷���
            EvalBasises = cell(size(Courses)); % ��ʼ��tout2�и����ۻ��ڵ�����
            Teachers = cell(size(Courses)); % ��ʼ��tout2�и����ۻ��ڵ�������
            Documents = cell(size(Courses)); % ��ʼ��tout2�и����ۻ��ڵ��γɼ�¼����
            % ����γ̴�ɶȽ��
            for iCourse = 1:length(QECourses)
%                 Credits{iCourse} = db_Curriculum.Credit(strcmp(db_Curriculum.Name,Courses(iCourse)));
                EvalMethods{iCourse} = '�ɼ�������';
                EvalBasises{iCourse} = '�γ�Ŀ���ɶ�';
                Teachers{iCourse} = db_Curriculum.Teacher(strcmp(db_Curriculum.Name,Courses(iCourse)));
                Documents = {'�γ�Ŀ���ɶȱ���'};
                idx_QECourses = strcmp({QE_Courses1.Name}, Courses(iCourse))|...
                                strcmp({QE_Courses1.ID}, IDs(iCourse));
                if any(idx_QECourses)
                    % ����IdxUniNum���UniNum
                    UniNumLists = db_Indicators.UniNum([QE_Courses1(idx_QECourses).Requirements.IdxUniNum]);
                    idx_Req = strcmp(UniNumLists,UniNum);
                    if any(idx_Req)
                        QECourses(iCourse) = QE_Courses1(idx_QECourses).Requirements(idx_Req).Result;
                    else
                        cprintf('err','�����󡿿γ̡�%s��ָ��㲻ƥ�䣡\n',Courses{iCourse});
                    end
                else
                    fprintf('�����桿����ɴ�ɶȷ����Ŀγ���û�С�%s����\n',Courses{iCourse})
                end
            end
        end
        QEIndicators(iIdt) = CourseWeights'*QECourses;
        iRowEnd = iRow+length(Courses)-1;
        tout1(iRow:iRowEnd,3) = Courses;
        tout1(iRow:iRowEnd,4) = num2cell(Credits);
        tout1(iRow:iRowEnd,5) = cellfun(@(x) sprintf('%.3f',x), num2cell(CourseWeights), 'UniformOutput', false);
        tout1(iRow:iRowEnd,6) = cellfun(@(x) sprintf('%.3f',x), num2cell(QECourses), 'UniformOutput', false);
        tout1(iRow,7) = cellfun(@(x) sprintf('%.3f',x), num2cell(QEIndicators(iIdt)), 'UniformOutput', false);
        tout2(iRow:iRowEnd,3) = Courses;
        tout2(iRow:iRowEnd,4) = EvalMethods;
        tout2(iRow:iRowEnd,5) = EvalBasises;
        tout2(iRow:iRowEnd,6) = Teachers;
        tout2(iRow:iRowEnd,7) = Documents;
        iRow = iRowEnd+1;
    end
    tout1{iRowGR,8} = sprintf('%.3f',mean(QEIndicators));
end

%% ������
%
output(1).TableName = sprintf('��ҵҪ���ɶȽ����_%s',Class);
output(1).TableType = '��ҵҪ���ɶȽ����';
output(1).Contents = tout1;
output(1).Heads = t1head;
%
output(2).TableName = sprintf('��ҵҪ���������ݱ�_%s',Class);
output(2).TableType = '��ҵҪ���������ݱ�';
output(2).Contents = tout2;
output(2).Heads = t2head;