%% Assist to evaluate the teaching objective achievement
%
% ����˵��
% ���������CourseName - char ���пγ�Ŀ���ɶȷ����Ŀγ�����
%          Class      - char ���пγ�Ŀ���ɶȷ����Ŀγ��꼶
%          opt        - integer = 0 ��database.mat����db_Outcome0��db_Outcome1
%                                 1 ����GetData()���db_Outcome0��db_Outcome1
% ���������QE_Course  - struct �γ�Ŀ���ɶȷ������
%
%  by Dr. GUAN Guoqiang @ SCUT on 2019-09-14
%

function QE_Course = EA_Course(CourseName, Class, opt)
%% Initialize
% ����������
if ~exist('CourseName','var')
    CourseName = input('����γ����ƣ�', 's');
end
if ~exist('Class','var')
    Class = input('�����꼶��', 's');
end
if ~exist('opt','var')
    opt = 1;
end

%% ��������γ�������db_Curriculum�л�ȡ�ÿγ�֧�ŵı�ҵҪ��ָ���
%  Acquire the preset course info 
load('database.mat', 'db_Curriculum', 'db_GradRequire');
NumCourse = length(db_Curriculum.Name); % number of courses
idxes_Course = strcmp(db_Curriculum.Name,CourseName);
if any(idxes_Course)
    cprintf('Comments','���㡰%s���γ�Ŀ���ɶȡ�\n',CourseName)
    idx = find(idxes_Course);
else
    cprintf('err','�����󡿿γ̾�����û�С�%s����\n',CourseName)
    return
end

%% ���
switch opt
    case(0) % ��database.mat������db_Outcome0��db_Outcome1
        load('database.mat', 'db_Outcome0', 'db_Outcome1')
    case(1) % ����������ָ��
        % ����GetData����ȫ���γ̵ĳɼ���
        db_Outcome0 = GetData({Class}); % ���롰�򵥳ɼ�����
        db_Outcome1 = GetData({Class},1); % ���롰��ϸ�ɼ�����
end
% �á���ϸ�ɼ��������桰�򵥳ɼ�����
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
    fprintf('�������Ҳ����γ̡�%s���ĳɼ���',db_Outcome(idx).Name)
    return
end
QE_Course.Transcript = Transcript;

% ����QE_Course
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
QE_Course.RelMatrix.Req2Obj = Req2Obj;
QE_Course.Analysis = sprintf('�γ̣�%s-��ɶȷ�����ʾ����',CourseName);

%% �����ѧĿ�꼰�������������ѧĿ����֧�Ź�ϵ
opt_mode = input('��������Obj2Way��ϵ����ķ�ʽ��[1] ͨ��EA_Input()��[2] ����O2C��C2W�����ͨ��EA_GetRelMatrix()');
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
