%% ��UI�����������ݱ��û������ѧĿ�꼰�������������ѧĿ����֧�Ź�ϵ
%
% ����˵��
% ���������QE_Course (struct)
% ���������QE_Course (struct) ����RelMatrix.Obj2Way����
%
% by Dr. Guan Guoqiang @ SCUT on 2020/6/20
%

function QE_Course = EA_Input(QE_Course)
%% ��ʼ��
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

%% �û������ı�ͷ
% �ɡ����˽ṹ����������ȷ�����˻���
Way1 = {QE_Course.Transcript.Definition.EvalTypes.Code};
% ��ÿ�����˻��ڣ��������˽ṹ�������Ķ����趨�û����еĿ�����
for iWay1 = 1:length(Spec)
    for iWay2 = 1:Spec(iWay1)
        Ways(iWay) = {[Way1{iWay1},num2str(iWay2)]};
        iWay = iWay+1;
    end
end
HeadTitle{1} = '��ҵҪ��ָ���';
HeadTitle{2} = '��ѧĿ��';
HeadTitle(3:end) = Ways;

%% �û�����������
% ��һ��Ϊ��ҵҪ��ָ���
EA_Matrix(:,1) = {QE_Course.Requirements.Description}';
% �ڶ���Ϊ�γ�Ŀ��
iRow = 1;
for iReq = 1:NumReq
    NumObj = length(QE_Course.Requirements(iRow).Objectives);
    for iObj = 1:NumObj
        EA_Matrix(iRow,2) = {QE_Course.Requirements(iRow).Objectives(iObj).Description};
        iRow = iRow+1;
    end
end
% �������е�ֵΪ�߼�ֵ
EA_Matrix(:,3:NumWay+2) = num2cell(false(NumTotalObj,NumWay));

%% ������п��
TabWidth = FigWidth-2*TabMargin;
TabHeight = FigHeight-2*TabMargin;
ColWidth{1} = 250;
ColWidth{2} = 'Auto';
ColWidth(3:end) = num2cell(ones(NumWay,1)*(TabWidth-500)/NumWay);

%% ��ui�д�����
figTitle = sprintf('��������ѧ��Դ����רҵ%s���γ̣�%s(%s) �γ�Ŀ���뿼�����ݹ�ϵ',QE_Course.Class,QE_Course.Name,QE_Course.ID);
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

%% ���
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

