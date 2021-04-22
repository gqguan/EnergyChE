%% Assist to evaluate the teaching objective achievement
%
% 参数说明
% 输入参数：CourseName - char 进行课程目标达成度分析的课程名称
%          Class      - char 进行课程目标达成度分析的课程年级
%          opt        - integer = 0 从database.mat载入db_Outcome0和db_Outcome1
%                                 1 运行GetData()获得db_Outcome0和db_Outcome1
% 输出参数：QE_Course  - struct 课程目标达成度分析结果
%
%  by Dr. GUAN Guoqiang @ SCUT on 2019-09-14
%

function QE_Course = EA_Course(CourseName, Class, opt)
%% Initialize
% 输入参数检查
if ~exist('CourseName','var')
    CourseName = input('输入课程名称：', 's');
end
if ~exist('Class','var')
    Class = input('输入年级：', 's');
end
if ~exist('opt','var')
    opt = 1;
end

%% 根据输入课程名称在db_Curriculum中获取该课程支撑的毕业要求指标点
%  Acquire the preset course info 
load('database.mat', 'db_Curriculum', 'db_GradRequire');
NumCourse = length(db_Curriculum.Name); % number of courses
idxes_Course = strcmp(db_Curriculum.Name,CourseName);
if any(idxes_Course)
    cprintf('Comments','计算“%s”课程目标达成度。\n',CourseName)
    idx = find(idxes_Course);
else
    cprintf('err','【错误】课程矩阵中没有“%s”！\n',CourseName)
    return
end

%% 输出
switch opt
    case(0) % 从database.mat中载入db_Outcome0和db_Outcome1
        load('database.mat', 'db_Outcome0', 'db_Outcome1')
    case(1) % 命令行输入指令
        % 调用GetData导入全部课程的成绩单
        db_Outcome0 = GetData({Class}); % 导入“简单成绩单”
        db_Outcome1 = GetData({Class},1); % 导入“详细成绩单”
end
% 用“详细成绩单”代替“简单成绩单”
db_Outcome = db_Outcome0;
if any(contains(fieldnames(db_Outcome1),Class))
    for iCourse = 1:length(db_Outcome1)
        if ~isempty(db_Outcome1(iCourse).(Class))
            idx_RepeatedCourse = strcmp(db_Outcome1(iCourse).ID, [db_Outcome.ID]);
            db_Outcome(idx_RepeatedCourse).(Class) = db_Outcome1(iCourse).(Class);
        end
    end
end
Transcript = db_Outcome(idx).(Class);
Definition = Transcript.Definition;
Detail = Transcript.Detail;
if isempty(Detail)
    fprintf('【错误】找不到课程“%s”的成绩单',db_Outcome(idx).Name)
    return
end
QE_Course.Transcript = Transcript;

% 构造QE_Course
QE_Course.ID = db_Curriculum.ID{idx};
QE_Course.Name = db_Curriculum.Name{idx};
QE_Course.Class = Class(6:end);
Requirements = struct();
idx_UniNum = find(db_Curriculum.ReqMatrix(idx,:));
NumReq = sum(db_Curriculum.ReqMatrix(idx,:));
Req2Obj = eye(NumReq);
for iReq = 1:NumReq
    Requirements(iReq).IdxUniNum = idx_UniNum(iReq);
    Requirements(iReq).Description = db_GradRequire.Spec{idx_UniNum(iReq)};
    Objectives = struct();
    for iObj = 1:sum(Req2Obj(iReq,:))
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
QE_Course.RelMatrix.Req2Obj = Req2Obj;
QE_Course.Analysis = sprintf('课程：%s-达成度分析（示例）',CourseName);

%% 输入教学目标及各考核内容与教学目标间的支撑关系
opt_mode = input('请输入获得Obj2Way关系矩阵的方式：[1] 通过EA_Input()，[2] 输入O2C和C2W矩阵后通过EA_GetRelMatrix()');
switch opt_mode
    case(1)
        QE_Course = EA_Input(QE_Course);
    case(2)
        load('database.mat','db_Course')
        idxFound = strcmp({db_Course.Name}, CourseName);
        QE_Course.RelMatrix.Obj2Way = EA_GetRelMatrix(db_Course(idxFound).(Class).O2C,db_Course(idxFound).(Class).C2W);
        QE_Course.RelMatrix.O2C = db_Course(idxFound).(Class).O2C;
        QE_Course.RelMatrix.C2W = db_Course(idxFound).(Class).C2W;
end


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
