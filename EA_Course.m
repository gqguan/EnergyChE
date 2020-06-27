%% Assist to evaluate the teaching objective achievement
%
% ����˵��
% ���������CourseName - char ���пγ�Ŀ���ɶȷ����Ŀγ�����
%          Class      - char ���пγ�Ŀ���ɶȷ����Ŀγ��꼶
% ���������QE_Course  - struct �γ�Ŀ���ɶȷ������
%
%  by Dr. GUAN Guoqiang @ SCUT on 2019-09-14
%

function QE_Course = EA_Course(CourseName, Class)
%% Initialize
opt = 0; % ����ģʽΪ����ģʽ
idx = 0;
prompt0 = '������пγ̴�ɶȷ����Ŀγ����ƺ󰴻س�\n�γ����ƣ� ';
prompt1 = '������Ӧ���꼶������class2013����';
prompt2 = '����ÿγ̵Ľ�ѧĿ����Ŀ��';
if nargin == 0 %  Input the course name
    CourseName = input(prompt0, 's');
    Class = input(prompt1, 's');
    opt = 1; % ����ģʽΪ�Ի�����ģʽ
end

%% ��������γ�������db_Curriculum�л�ȡ�ÿγ�֧�ŵı�ҵҪ��ָ���
%  Acquire the preset course info 
load('database.mat', 'db_Curriculum', 'db_GradRequire');
K = length(db_Curriculum.Name); % number of courses
for i = 1:K
    name = db_Curriculum.Name{i};
    if size(CourseName) == size(name)
        if CourseName == name
            idx = i;
            break
        end
    end
end
if idx == 0
    fprintf('Input course is NOT found! \n');
    return
else
    fprintf('Input course is found as \n');
    idx_UniNum = find(db_Curriculum.ReqMatrix(idx,:));
    M = sum(db_Curriculum.ReqMatrix(idx,:)); % number of supported indicator
end

%  Input the number of teaching objectives
if opt == 1
    prompt2 = sprintf('%s [ֱ�ӻس�����ȱʡֵ %d ]: ', prompt2, M);
    N = input(prompt2);
    if isempty(N)
       N = M; % Default value
    end
    %  Input the relation matrix of teaching objectives and supported
    %  graduation requirement
    prompt3 = '�����ѧĿ�����ҵҪ��ָ���Ĺ�ϵ����[M,N] [ֱ�ӻس�����ȱʡֵ] ';
    C = input(prompt3);
    if isempty(C)
        C = eye(M); %  Default matrix of C(M,N), where M=N
    end
    if M ~= size(C, 1) && N ~= size(C, 2)
        fprintf('Error: size(C,1) = %d not %d, or size(C,2) = %d not %d \n', ...
                size(C, 1), M, size(C, 2), N);
        return
    end
else
    N = M;
    C = eye(M);
end

%  Input the relation matrix of teaching contents and objectives
if opt == 1
    prompt4 = '�����ѧĿ�꿼�鷽ʽ�Ķ������� [ֱ�ӻس�����ȱʡֵ��ͨ����ĩ���Ե��ۺϳɼ�����] ';
    Spec = input(prompt4);
    if isempty(Spec)
        Spec = 1;
    end
end

%% ���
% ����GetData����ȫ���γ̵ĳɼ���
db_Outcome0 = GetData({Class}); % ���롰�򵥳ɼ�����
db_Outcome1 = GetData({Class},1); % ���롰��ϸ�ɼ�����
% �á���ϸ�ɼ��������桰�򵥳ɼ�����
db_Outcome = db_Outcome0;
for iCourse = 1:length(db_Outcome1)
    if ~isempty(db_Outcome1(iCourse).(Class))
        idx_RepeatedCourse = strcmp(db_Outcome1(iCourse).ID, [db_Outcome.ID]);
        db_Outcome(idx_RepeatedCourse).(Class) = db_Outcome1(iCourse).(Class);
    end
end
Transcript = db_Outcome(idx).(Class);
Definition = db_Outcome(idx).(Class).Definition;
if isempty(Transcript)
    disp('No transcript in dataset and STOP')
    return
end
QE_Course.Transcript = Transcript;

% ����QE_Course
QE_Course.ID = db_Curriculum.ID{idx};
QE_Course.Name = db_Curriculum.Name{idx};
QE_Course.Class = Class(6:end);
Requirements = struct();
for iReq = 1:M
    Requirements(iReq).IdxUniNum = idx_UniNum(iReq);
    Requirements(iReq).Description = db_GradRequire.Spec{idx_UniNum(iReq)};
    Objectives = struct();
    for iObj = 1:sum(C(iReq,:))
        Objectives(iObj).Description = sprintf('�������%d��ָ�����Ӧ�ĵ�%d����ѧĿ��˵��',iReq,iObj);
        EvalTypes = Definition.EvalTypes;
        for iType = 1:length(QE_Course.Transcript.Definition.Spec)
            EvalWays = Definition.EvalTypes(iType).EvalWays;
            for iWay = 1:QE_Course.Transcript.Definition.Spec(iType)
                EvalWays(iWay).Credit = sprintf('������/�����%d�����˷����ĵ÷�',iWay);
                EvalWays(iWay).Result = sprintf('������/�����%d�����˷����ĵ÷���',iWay);
                EvalWays(iWay).Correction.Credit = sprintf('������/�����%d�����˷����������÷�',iWay);
                EvalWays(iWay).Correction.FullCredit = sprintf('������/�����%d�����˷�����������ֵ',iWay);
            end
            EvalTypes(iType).EvalWays = EvalWays; 
            EvalTypes(iType).Subsum.Credit = sprintf('������/�����%d�����˷����������÷�С�ƣ�= sum(EvalWays(iWay).Correction.Credit)��',iType);
            EvalTypes(iType).Subsum.FullCredit = sprintf('������/�����%d�����˷�����������ֵС�ƣ�= sum(EvalWays(iWay).Correction.FullCredit)��',iType);
        end
        Objectives(iObj).EvalTypes = EvalTypes;
        Objectives(iObj).Weight = sprintf('�������%d����ѧĿ��Ե�%d��ָ����Ȩ��',iObj,iReq);
        Objectives(iObj).Sum.Credit = sprintf('�������%d����ѧĿ��Ե�%d��ָ���ĺϼƵ÷֣�= sum(EvalTypes(iType).Subsum.Credit)��',iObj,iReq);
        Objectives(iObj).Sum.FullCredit = sprintf('�������%d����ѧĿ��Ե�%d��ָ���ĺϼƷ�ֵ��= sum(EvalTypes(iType).Subsum.FullCredit)��',iObj,iReq);
        Objectives(iObj).Result = sprintf('������/�����%d��ָ���ĵ�%d����ѧĿ���ɶ�',iReq,iObj);
    end
    Requirements(iReq).Objectives = Objectives;
    Requirements(iReq).Weight = sprintf('�������%d����ҵҪ��ָ���Կγ����۵�Ȩ��',iReq);
    Requirements(iReq).Result = sprintf('������/�����%d����ҵҪ��ָ���Ĵ�ɶ�',iReq);
end
QE_Course.Requirements = Requirements;
QE_Course.Result = sprintf('������/����γ�����');
QE_Course.RelMatrix.Req2Obj = C;
QE_Course.Analysis = sprintf('�γ̣�%s-��ɶȷ�����ʾ����',CourseName);

%% �����ѧĿ�꼰�������������ѧĿ����֧�Ź�ϵ
QE_Course = EA_Input(QE_Course);

%% �����ɶ�
QE_Course = EA_EvalMethod(QE_Course);

%% ������
% ��QE_Courses.mat������QE_Courses����
load('QE_Courses.mat','QE_Courses')
% ��鵱ǰ���д�ɶȼ���Ŀγ��Ƿ����
IDFound = strcmp(QE_Course.ID, {QE_Courses.ID});
ClassAlsoFound = strcmp(QE_Course.Class, {QE_Courses(IDFound).Class});
if sum(ClassAlsoFound) ~= 0
    disp('Data are existed and manually fix')
else
    QE_Courses = [QE_Courses QE_Course];
    disp('Save into QE_Courses.')
    save('QE_Courses.mat', 'QE_Courses', '-append')
end

end
