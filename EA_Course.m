%% Assist to evaluate the teaching objective achievement
%
% 参数说明
% 输入参数：CourseName - char 进行课程目标达成度分析的课程名称
%          Class      - char 进行课程目标达成度分析的课程年级
% 输出参数：QE_Course  - struct 课程目标达成度分析结果
%
%  by Dr. GUAN Guoqiang @ SCUT on 2019-09-14
%

function QE_Course = EA_Course(CourseName, Class)
%% Initialize
opt = 0; % 运行模式为安静模式
idx = 0;
prompt0 = '输入进行课程达成度分析的课程名称后按回车\n课程名称： ';
prompt1 = '输入相应的年级（例如class2013）：';
prompt2 = '输入该课程的教学目标数目：';
if nargin == 0 %  Input the course name
    CourseName = input(prompt0, 's');
    Class = input(prompt1, 's');
    opt = 1; % 运行模式为对话输入模式
end

%% 根据输入课程名称在db_Curriculum中获取该课程支撑的毕业要求指标点
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
    prompt2 = sprintf('%s [直接回车输入缺省值 %d ]: ', prompt2, M);
    N = input(prompt2);
    if isempty(N)
       N = M; % Default value
    end
    %  Input the relation matrix of teaching objectives and supported
    %  graduation requirement
    prompt3 = '输入教学目标与毕业要求指标点的关系矩阵[M,N] [直接回车输入缺省值] ';
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
    prompt4 = '输入教学目标考查方式的定义向量 [直接回车输入缺省值：通过期末考试的综合成绩评价] ';
    Spec = input(prompt4);
    if isempty(Spec)
        Spec = 1;
    end
end

%% 输出
% 调用GetData导入全部课程的成绩单
db_Outcome0 = GetData({Class}); % 导入“简单成绩单”
db_Outcome1 = GetData({Class},1); % 导入“详细成绩单”
% 用“详细成绩单”代替“简单成绩单”
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

% 构造QE_Course
QE_Course.ID = db_Curriculum.ID{idx};
QE_Course.Name = db_Curriculum.Name{idx};
QE_Course.Class = Class(6:end);
Requirements = struct();
for iReq = 1:M
    Requirements(iReq).IdxUniNum = idx_UniNum(iReq);
    Requirements(iReq).Description = db_GradRequire.Spec{idx_UniNum(iReq)};
    Objectives = struct();
    for iObj = 1:sum(C(iReq,:))
        Objectives(iObj).Description = sprintf('请输入第%d个指标点相应的第%d个教学目标说明',iReq,iObj);
        EvalTypes = Definition.EvalTypes;
        for iType = 1:length(QE_Course.Transcript.Definition.Spec)
            EvalWays = Definition.EvalTypes(iType).EvalWays;
            for iWay = 1:QE_Course.Transcript.Definition.Spec(iType)
                EvalWays(iWay).Credit = sprintf('请输入/计算第%d个考核方法的得分',iWay);
                EvalWays(iWay).Result = sprintf('请输入/计算第%d个考核方法的得分率',iWay);
                EvalWays(iWay).Correction.Credit = sprintf('请输入/计算第%d个考核方法的修正得分',iWay);
                EvalWays(iWay).Correction.FullCredit = sprintf('请输入/计算第%d个考核方法的修正分值',iWay);
            end
            EvalTypes(iType).EvalWays = EvalWays; 
            EvalTypes(iType).Subsum.Credit = sprintf('请输入/计算第%d个考核方法的修正得分小计（= sum(EvalWays(iWay).Correction.Credit)）',iType);
            EvalTypes(iType).Subsum.FullCredit = sprintf('请输入/计算第%d个考核方法的修正分值小计（= sum(EvalWays(iWay).Correction.FullCredit)）',iType);
        end
        Objectives(iObj).EvalTypes = EvalTypes;
        Objectives(iObj).Weight = sprintf('请输入第%d个教学目标对第%d个指标点的权重',iObj,iReq);
        Objectives(iObj).Sum.Credit = sprintf('请输入第%d个教学目标对第%d个指标点的合计得分（= sum(EvalTypes(iType).Subsum.Credit)）',iObj,iReq);
        Objectives(iObj).Sum.FullCredit = sprintf('请输入第%d个教学目标对第%d个指标点的合计分值（= sum(EvalTypes(iType).Subsum.FullCredit)）',iObj,iReq);
        Objectives(iObj).Result = sprintf('请输入/计算第%d个指标点的第%d个教学目标达成度',iReq,iObj);
    end
    Requirements(iReq).Objectives = Objectives;
    Requirements(iReq).Weight = sprintf('请输入第%d个毕业要求指标点对课程评价的权重',iReq);
    Requirements(iReq).Result = sprintf('请输入/计算第%d个毕业要求指标点的达成度',iReq);
end
QE_Course.Requirements = Requirements;
QE_Course.Result = sprintf('请输入/计算课程质量');
QE_Course.RelMatrix.Req2Obj = C;
QE_Course.Analysis = sprintf('课程：%s-达成度分析（示例）',CourseName);

%% 输入教学目标及各考核内容与教学目标间的支撑关系
QE_Course = EA_Input(QE_Course);

%% 计算达成度
QE_Course = EA_EvalMethod(QE_Course);

%% 保存结果
% 从QE_Courses.mat中载入QE_Courses变量
load('QE_Courses.mat','QE_Courses')
% 检查当前进行达成度计算的课程是否存在
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
