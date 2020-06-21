%% Assist to evaluate the teaching objective achievement
%
% ����˵��
% ���������CourseName - char ���пγ�Ŀ���ɶȷ����Ŀγ�����
%          Class      - char ���пγ�Ŀ���ɶȷ����Ŀγ��꼶
%          Spec       - double array ���鷽ʽ��������
% ���������QE_Course  - struct �γ�Ŀ���ɶȷ������
%
%  by Dr. GUAN Guoqiang @ SCUT on 2019-09-14
%

function QE_Course = EA_Course(CourseName, Class, Spec)
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

%% ����GetData����ȫ���γ̵ĳɼ���
db_Outcome = GetData({Class});
Transcript = db_Outcome(idx).(Class);
if isempty(Transcript)
    disp('No transcript in dataset and STOP')
    return
end

%% Supply info in syllabus
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
        Spec = [1];
    end
end

%% ����QE_Course
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
        EvalTypes = struct();
        for iType = 1:length(Spec)
            EvalTypes(iType).Description = sprintf('�������%d����������˵��',iType);
            EvalTypes(iType).Code = sprintf('�������%d���������͵Ĵ���',iType);
            EvalTypes(iType).Weight = sprintf('�������%d���������ͶԵ�%d����ѧĿ���Ȩ��',iType,iObj);
            EvalWays = struct();
            for iWay = 1:Spec(iType)
                EvalWays(iWay).Description = sprintf('�������%d���������͵ĵ�%d�����˷���˵��',iType,iWay);
                EvalWays(iWay).Weight = sprintf('�������%d�����˷����Ե�%d���������͵�Ȩ��',iWay,iType);
                EvalWays(iWay).FullCredit = sprintf('�������%d�����˷����ķ�ֵ',iWay);
                EvalWays(iWay).Outcome = sprintf('������/�����%d�����˷����ĵ÷�',iWay);
                EvalWays(iWay).Result = sprintf('������/�����%d�����˷����ĵ÷���',iWay);
            end
            EvalTypes(iType).EvalWays = EvalWays;
            EvalTypes(iType).Result = sprintf('������/�����%d���������͵ļ�Ȩƽ���÷���',iType);
        end
        Objectives(iObj).EvalTypes = EvalTypes;
        Objectives(iObj).Weight = sprintf('�������%d����ѧĿ��Ե�%d��ָ����Ȩ��',iObj,iReq);
        Objectives(iObj).Result = sprintf('������/�����%d��ָ���ĵ�%d����ѧĿ���ɶ�',iReq,iObj);
    end
    Requirements(iReq).Objectives = Objectives;
    Requirements(iReq).Weight = sprintf('�������%d����ҵҪ��ָ���Կγ����۵�Ȩ��',iReq);
    Requirements(iReq).Result = sprintf('������/�����%d����ҵҪ��ָ���Ĵ�ɶ�',iReq);
end
QE_Course.Requirements = Requirements;
QE_Course.Result = sprintf('������/����γ�����');
QE_Course.RelMatrix.Req2Obj = C;
QE_Course.Transcript.Definition.Spec = Spec;

end
