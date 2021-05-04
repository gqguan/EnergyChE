%% Assist to evaluate the teaching objective achievement
%
% ����˵��
% ���������CourseName - char ���пγ�Ŀ���ɶȷ����Ŀγ�����
%          Class      - char ���пγ�Ŀ���ɶȷ����Ŀγ��꼶
%          opt1       - integer = 0 ��database.mat����db_Outcome0��db_Outcome1
%                                 1 ����GetData()���db_Outcome0��db_Outcome1
%          opt2       - integer = 0 ����EA_Input()����O2W��ϵ����
%                                 1 ��db_Course������O2C��C2W��ϵ����
% ���������QE_Course  - struct �γ�Ŀ���ɶȷ������
%
%  by Dr. GUAN Guoqiang @ SCUT on 2019-09-14
%

function QE_Course = EA_Course(CourseName, Class, opt1, opt2)
%% Initialize
% ����������
if ~exist('CourseName','var')
    CourseName = input('����γ����ƣ�', 's');
end
if ~exist('Class','var')
    Class = input('�����꼶��', 's');
end
if ~exist('opt1','var')
    opt1 = 1;
end
if ~exist('opt2','var')
    opt2 = 2;
end

%% ��������γ�������db_Curriculum�л�ȡ�ÿγ�֧�ŵı�ҵҪ��ָ���
%  Acquire the preset course info 
load('database.mat', 'db_Curriculum2019a', 'db_Indicators2019');
Curriculum = db_Curriculum2019a;
Curriculum.Properties.VariableNames{'IDv2018'} = 'ID';
Indcators = db_Indicators2019;
NumCourse = length(Curriculum.Name); % number of courses
idxes_Course = strcmp(Curriculum.Name,CourseName);
if any(idxes_Course)
    cprintf('Comments','���㡰%s���γ�Ŀ���ɶȡ�\n',CourseName)
    idx = find(idxes_Course);
else
    cprintf('err','�����󡿿γ̾�����û�С�%s����\n',CourseName)
    return
end

%% ���
switch opt1
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
% opt_mode = input('��������Obj2Way��ϵ����ķ�ʽ��[1] ͨ��EA_Input()��[2] ����O2C��C2W�����ͨ��EA_GetRelMatrix()');
switch opt2
    case(1)
        fprintf('ͨ��EA_Input()���Obj2Way��ϵ����\n')
        QE_Course = EA_Input(QE_Course);
    case(2)
        fprintf('��db_Course�л��O2C��C2W�����ͨ��EA_GetRelMatrix()���Obj2Way��ϵ����\n')
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
                    fprintf('[����] ����db_Course�пγ̡�%s�������γ�Ŀ�ꡢ���ݺ������Ĺ�ϵ����\n', CourseName)
                    return
                end
            end
            % ��db_Course�еĿγ�Ŀ�����ݼ���ɶȷ����ı�����QE_Course
            QE_Course = EA_FillCourseObjs(QE_Course,db_Course(idxFound).(Class).Objectives.Contents);
        else
            fprintf('[����] ����db_Course���Ҳ����γ̡�%s��\n',Class,CourseName)
            cprintf('err','������ֹ���У�\n')
            return
        end
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
    fprintf('[ע��] ���̱���QE_Courses���Ѵ���%s���γ̡�%s�������\n',Class,CourseName)
    overwrt = input('[Y/N]���Ǵ���QE_Courses.mat�ļ��еı���QE_Courses��','s');
    switch overwrt
        case('Y')
            save('QE_Courses.mat', 'QE_Courses', '-append')
            disp('�¼������ѱ�����£�')
        case('N')
            disp('�¼�����δ������£�')
        otherwise
            disp('�޷�ʶ������ָ��¼�����δ������£�')
    end
else
    QE_Courses = [QE_Courses QE_Course];
    disp('���̸���QE_Courses.mat�еı���QE_Courses.')
    save('QE_Courses.mat', 'QE_Courses', '-append')
end

end
