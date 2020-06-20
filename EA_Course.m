%% Assist to evaluate the teaching objective achievement
%
% ����˵��
% ���������CourseName - char ���пγ�Ŀ���ɶȷ����Ŀγ�����
%          Class      - char ���пγ�Ŀ���ɶȷ����Ŀγ��꼶
%          WayDefs    - double array ���鷽ʽ��������
% ���������QE_Course  - struct �γ�Ŀ���ɶȷ������
%
%  by Dr. GUAN Guoqiang @ SCUT on 2019-09-14
%

function QE_Course = EA_Course(CourseName, Class, WayDefs)
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
QE_Course.ID = db_Curriculum.ID{idx};
QE_Course.Name = db_Curriculum.Name{idx};
QE_Course.(Class).Requirements.IdxUniNum = idx_UniNum;
QE_Course.(Class).Requirements.Description = db_GradRequire(idx_UniNum,2);

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
QE_Course.(Class).RelMatrix.Req2Obj = C;

%  Input the relation matrix of teaching contents and objectives
if opt == 1
    prompt4 = '�����ѧĿ�꿼�鷽ʽ�Ķ������� [ֱ�ӻس�����ȱʡֵ��ͨ����ĩ���Ե��ۺϳɼ�����] ';
    WayDefs = input(prompt4);
    if isempty(WayDefs)
        WayDefs = [1];
    end
end
QE_Course.(Class).Evaluation.WayDefs = WayDefs;


end
