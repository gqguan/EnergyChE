%% ��ҵҪ���ɶȼ���
%
% ����˵����
% ��1������db_Curriculum�еĿγ̾��󣬰���ҵҪ������Ϊ�г���Ӧ�ı��޿γ�
% ��2��������Ӧ�γ̶�Ӧ��ָ����ɶȷ������
% ��3���ԡ�ĳ�γ̵�ѧ��/��ָ���ȫ���γ̵���ѧ�֡�ΪȨ��
% ��4�������ָ���ļ�Ȩƽ��ֵ
%
% by Dr. Guan Guoqiang @ SCUT on 2020-07-08

%% ��ʼ��
% ��鵱ǰ�����ռ��д������������
if ~exist('QE_Courses','var') % �γ�Ŀ���ɶ�����
    load('QE_Courses.mat','QE_Courses')
end
if ~exist('db_Curriculum','var') % �γ��б�
    load('database.mat','db_Curriculum')
end
if ~exist('db_Indicators','var') % �γ��б�
    load('database.mat','db_Indicators')
end
% ��ʼ���������
tout = cell(sum(sum(db_Curriculum.ReqMatrix)),6);

iRow = 1;

%% ���ָ���꼶������ɴ�ɶȷ����Ŀγ��б�
% �����꼶
Class = input('������б�ҵҪ���ɶȼ����꼶', 's');
% ɸѡָ���꼶������ɴ�ɶȷ����Ŀγ��б�
QE_Courses1 = QE_Courses(strcmp({QE_Courses.Class},Class));

%% ���ܣ�1��
% ���������ҵҪ��
ReqLists = EA_DefGR;
for iReq = 1:length(ReqLists)
    tout{iRow,1} = ReqLists(iReq).Brief;
    NumIdt = length(ReqLists(iReq).Indicators);
    for iIdt = 1:NumIdt
        tout{iRow,2} = ReqLists(iReq).Indicators(iIdt).Spec;
        UniNum = ReqLists(iReq).Indicators(iIdt).UniNum;
        idxs = strcmp(db_Indicators.UniNum,UniNum);
        if sum(idxs) == 1
            idx_Courses = db_Curriculum.ReqMatrix(:,idxs);
            CourseLists = db_Curriculum.Name(logical(idx_Courses));
            CreditLists = cell(size(CourseLists));
            ResultLists = cell(size(CourseLists));
            % ����γ̴�ɶȽ��
            for iCourse = 1:length(ResultLists)
                CreditLists{iCourse} = db_Curriculum.Credit(strcmp(db_Curriculum.Name,CourseLists(iCourse)));
                idx_QECourses = strcmp({QE_Courses1.Name}, CourseLists(iCourse));
                if any(idx_QECourses)
                    % ����IdxUniNum���UniNum
                    UniNumLists = db_Indicators.UniNum([QE_Courses1(idx_QECourses).Requirements.IdxUniNum]);
                    idx_Req = strcmp(UniNumLists,UniNum);
                    if any(idx_Req)
                        ResultLists{iCourse} = QE_Courses1(idx_QECourses).Requirements(idx_Req).Result;
                    else
                        fprintf('������ָ��㲻ƥ�䣡\n');
                    end
                else
                    fprintf('�����桿����ɴ�ɶȷ����Ŀγ���û�С�%s����\n',CourseLists{iCourse})
                end

            end
        end
        iRowEnd = iRow+length(CourseLists)-1;
        tout(iRow:iRowEnd,3) = CourseLists;
        tout(iRow:iRowEnd,4) = CreditLists;
        tout(iRow:iRowEnd,5) = ResultLists;
        iRow = iRowEnd+1;
    end
end