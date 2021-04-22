%% 在UI创建考核内容表供用户输入教学目标及各考核内容与教学目标间的支撑关系
%
% 参数说明
% 输入参数：QE_Course (struct)
% 输出参数：QE_Course (struct) 增加RelMatrix.Obj2Way矩阵
%
% by Dr. Guan Guoqiang @ SCUT on 2020/6/20
%

function QE_Course = EA_Input(QE_Course)
%% 初始化
[NumReq,NumTotalObj] = size(QE_Course.RelMatrix.Req2Obj);
Spec = QE_Course.Transcript.Definition.Spec;
NumWay = sum(Spec);
NumType = length(Spec);
EA_Matrix = cell(NumTotalObj,NumWay+2);
Ways = cell(NumWay,1);
HeadTitle = cell(1,NumWay+2);
ColWidth = cell(1,NumWay+2);

FigPosX = 100;
FigPosY = 100;
FigWidth = 1200;
FigHeight = 300;
TabMargin = 25;

iWay = 1;

%% 用户输入表的表头
% 由“考核结构向量”长度确定考核环节
Way1 = {QE_Course.Transcript.Definition.EvalTypes.Code};
% 对每个考核环节，按“考核结构向量”的定义设定该环节中的考核数
for iWay1 = 1:length(Spec)
    for iWay2 = 1:Spec(iWay1)
        Ways(iWay) = {[Way1{iWay1},num2str(iWay2)]};
        iWay = iWay+1;
    end
end
HeadTitle{1} = '毕业要求指标点';
HeadTitle{2} = '教学目标';
HeadTitle(3:end) = Ways;

%% 用户输入表的内容
% 第一列为毕业要求指标点
EA_Matrix(:,1) = {QE_Course.Requirements.Description}';
% 第二列为课程目标
iRow = 1;
for iReq = 1:NumReq
    NumObj = length(QE_Course.Requirements(iRow).Objectives);
    for iObj = 1:NumObj
        EA_Matrix(iRow,2) = {QE_Course.Requirements(iRow).Objectives(iObj).Description};
        iRow = iRow+1;
    end
end
% 其余列中的值为逻辑值
EA_Matrix(:,3:NumWay+2) = num2cell(false(NumTotalObj,NumWay));

%% 计算各列宽度
TabWidth = FigWidth-2*TabMargin;
TabHeight = FigHeight-2*TabMargin;
ColWidth{1} = 250;
ColWidth{2} = 'Auto';
ColWidth(3:end) = num2cell(ones(NumWay,1)*(TabWidth-500)/NumWay);

%% 在ui中创建表
figTitle = sprintf('华南理工大学能源化工专业%s级课程：%s(%s) 课程目标与考核内容关系',QE_Course.Class,QE_Course.Name,QE_Course.ID);
fig = uifigure('Position', [FigPosX FigPosY FigWidth FigHeight], ...
               'Name', figTitle); 
uit = uitable('Parent', fig, ...
              'Position', [TabMargin TabMargin TabWidth TabHeight], ...
              'ColumnName', HeadTitle, ...
              'ColumnWidth', ColWidth, ...
              'RowName', 'numbered', ...
              'ColumnEditable', [false true true(1,NumWay)], ...
              'Data', EA_Matrix);

disp('Press ENTER to continue...');
pause

%% 输出
EA_Matrix = get(uit, 'Data');
QE_Course.RelMatrix.Obj2Way  = cell2mat(EA_Matrix(:,3:NumWay+2));
iRow = 1;
for iReq = 1:NumReq
    NumObj = length(QE_Course.Requirements(iRow).Objectives);
    for iObj = 1:NumObj
        QE_Course.Requirements(iReq).Objectives(iObj).Description = EA_Matrix{iRow,2};
        iRow = iRow+1;
    end
end

closereq

end

