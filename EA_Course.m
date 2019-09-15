%% Assist to evaluate the teaching objective achievement
%
%  by Dr. GUAN Guoqiang @ SCUT on 2019-09-14
%
%% Initialize
clear;
idx = 0;
prompt1 = '����γ����ƺ󰴻س�\n�γ����ƣ� ';
prompt2 = '����ÿγ̵Ľ�ѧĿ����Ŀ';
%% Acquire the supported indicators of graduation requirement
%  Input the course name
CourseName = input(prompt1, 's');
%  Acquire the preset course info 
load('database.mat');
K = length(db_Curriculum.Name); % number of courses
for i = 1:K
    name = db_Curriculum.Name(i);
    name = [name{:}];
    if size(CourseName) == size(name)
        if CourseName == name;
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
    db_GradRequire(idx_UniNum,:)
    M = sum(db_Curriculum.ReqMatrix(idx,:)); % number of supported indicator
end
%% Supply info in syllabus
%  Input the number of teaching objectives
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
%  Input the relation matrix of teaching contents and objectives
prompt4 = '�����ѧ�������ѧĿ��Ĺ�ϵ����[N,L] [ֱ�ӻس�����ȱʡֵ] ';
D = input(prompt4);
if isempty(D)
    D = zeros(N, 2); % Default matrix of D(N,L), where L=2 as only regular
                     % grade and final score were used in student
                     % performance sheet
    D(:,1) = 0.3; % weight of regular grade
    D(:,2) = 0.7; % weight of score in final exam
end
L = size(D, 2);
if N ~= size(D, 1)
    fprintf('Error: size(D,1) = %d not %d \n', size(D, 1), N);
    return
end
%  Input the evaluation matrix of teaching contents
prompt5 = '�����ѧ��������������[L,J] ';
U = input(prompt5);
if L ~= size(U, 1)
    fprintf('Error: size(V,1) = %d not %d \n', size(U, 1), L);
    return
end
J = size(U, 2);
%  Input the weight array of evaluation
prompt6 = '������������Ȩ������ [ֱ�ӻس�����ȱʡֵ] ';
E = input(prompt6);
if isempty(E)
    E(1:J,1) = 1/J;
end
%%  Conduct the evaluation
%  Build the matrices of C and B
B = RelateC2B(C, idx_UniNum);
%  Evaluate the teaching objectives achievement
[X, Y] = TeachObj(B, C, D, E, U);
%%  Output
GR_Achieve = X;
Output = [db_GradRequire(idx_UniNum,:), table(GR_Achieve)];

