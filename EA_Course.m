%% Assist to evaluate the teaching objective achievement
%
% 参数说明
% 输入参数：CourseName - char 进行课程目标达成度分析的课程名称
%          Class      - char 进行课程目标达成度分析的课程年级
%          opt1       - integer = 0 从database.mat载入db_Outcome0和db_Outcome1
%                                 1 运行GetData()获得db_Outcome0和db_Outcome1
%          opt2       - integer = 0 调用EA_Input()输入O2W关系矩阵
%                                 1 从db_Course中载入O2C和C2W关系矩阵
% 输出参数：QE_Course  - struct 课程目标达成度分析结果
%
%  by Dr. GUAN Guoqiang @ SCUT on 2019-09-14
%

function QE_Course = EA_Course(CourseName, Class, opt1, opt2)
%% Initialize
% 输入参数检查
if ~exist('CourseName','var')
    CourseName = input('输入课程名称：', 's');
end
if ~exist('Class','var')
    Class = input('输入年级：', 's');
end
if ~exist('opt1','var')
    opt1 = 1;
end
if ~exist('opt2','var')
    opt2 = 2;
end

%% 根据输入课程名称在db_Curriculum中获取该课程支撑的毕业要求指标点
%  Acquire the preset course info 
load('database.mat', 'db_Curriculum2019a', 'db_Indicators2019');
Curriculum = db_Curriculum2019a;
Curriculum.Properties.VariableNames{'IDv2018'} = 'ID';
Indcators = db_Indicators2019;
NumCourse = length(Curriculum.Name); % number of courses
idxes_Course = strcmp(Curriculum.Name,CourseName);
if any(idxes_Course)
    cprintf('Comments','计算“%s”课程目标达成度。\n',CourseName)
    idx = find(idxes_Course);
else
    cprintf('err','【错误】课程矩阵中没有“%s”！\n',CourseName)
    return
end

%% 输出
switch opt1
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
QE_Course.ID = Curriculum.ID{idx};
QE_Course.Name = Curriculum.Name{idx};
QE_Course.Class = Class(6:end);
Requirements = struct();
idx_UniNum = find(Curriculum.ReqMatrix(idx,:));
NumReq = sum(Curriculum.ReqMatrix(idx,:));
Req2Obj = eye(NumReq);
for iReq = 1:NumReq
    Requirements(iReq).IdxUniNum = idx_UniNum(iReq);
    Requirements(iReq).Description = Indcators.Spec{idx_UniNum(iReq)};
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
% opt_mode = input('请输入获得Obj2Way关系矩阵的方式：[1] 通过EA_Input()，[2] 输入O2C和C2W矩阵后通过EA_GetRelMatrix()');
switch opt2
    case(1)
        fprintf('通过EA_Input()获得Obj2Way关系矩阵！\n')
        QE_Course = EA_Input(QE_Course);
    case(2)
        fprintf('从db_Course中获得O2C和C2W矩阵后通过EA_GetRelMatrix()获得Obj2Way关系矩阵！\n')
        load('database.mat','db_Course')
        idxFound = strcmp({db_Course.Name}, CourseName);
        if any(idxFound)
            if any(contains(fieldnames(db_Course(idxFound).(Class)),'Obj2Way'))
                QE_Course.RelMatrix.Obj2Way = db_Course(idxFound).(Class).Obj2Way;
                if sum(contains(fieldnames(db_Course(idxFound).(Class)),{'O2C','C2W'})) == 2
                    QE_Course.RelMatrix.O2C = db_Course(idxFound).(Class).O2C;
                    QE_Course.RelMatrix.C2W = db_Course(idxFound).(Class).C2W;
                end
            else
                if sum(contains(fieldnames(db_Course(idxFound).(Class)),{'O2C','C2W'})) == 2
                    QE_Course.RelMatrix.Obj2Way = EA_GetRelMatrix(db_Course(idxFound).(Class).O2C,db_Course(idxFound).(Class).C2W);
                    QE_Course.RelMatrix.O2C = db_Course(idxFound).(Class).O2C;
                    QE_Course.RelMatrix.C2W = db_Course(idxFound).(Class).C2W;
                else
                    fprintf('[错误] 变量db_Course中课程“%s”不含课程目标、内容和评测点的关系矩阵！\n', CourseName)
                    return
                end
            end
            % 将db_Course中的课程目标内容及达成度分析文本输入QE_Course
            QE_Course = EA_FillCourseObjs(QE_Course,db_Course(idxFound).(Class).Objectives.Contents);
        else
            fprintf('[错误] 变量db_Course中找不到课程“%s”\n',Class,CourseName)
            cprintf('err','程序终止运行！\n')
            return
        end
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
    fprintf('[注意] 存盘变量QE_Courses中已存在%s级课程“%s”结果！\n',Class,CourseName)
    overwrt = input('[Y/N]覆盖存盘QE_Courses.mat文件中的变量QE_Courses：','s');
    switch overwrt
        case('Y')
            save('QE_Courses.mat', 'QE_Courses', '-append')
            disp('新计算结果已保存更新！')
        case('N')
            disp('新计算结果未保存更新！')
        otherwise
            disp('无法识别输入指令，新计算结果未保存更新！')
    end
else
    QE_Courses = [QE_Courses QE_Course];
    disp('存盘覆盖QE_Courses.mat中的变量QE_Courses.')
    save('QE_Courses.mat', 'QE_Courses', '-append')
end

end
