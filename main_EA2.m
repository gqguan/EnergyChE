%% ��ҵҪ���ɶȼ���������
%
% by Dr. Guan Guoqiang @ SCUT on 2020/07/12
%
% ������ýṹ
% main_EA2
%   EA_GetReqMatrix() ����γ�֧�ž���
%   EA_ImportQECourses() ����γ̳ɼ���
%   EA_GradReq() ��ҵҪ���ɶȼ���
%     EA_DefGR()
%   Tab2Word() ��MS-WORD�ĵ��б�����

%% ��ʼ��
clear;

%% ������
% �ӶԻ���ѡȡ����֧�ž����EXCEL�ļ�������database.mat�е�db_Curriculum.ReqMatrix�Ƚ�
% �����߲�ͬ����ѡ��A���¹����ռ���ָ���Ŀγ�֧�ž���
db_Curriculum = EA_GetReqMatrix(); 
% �����ֹ�����Ŀγ̴�ɶȽ��
QE_Courses = EA_ImportQECourses();
% �����ҵҪ���ɶ�
output = EA_GradReq(QE_Courses,db_Curriculum);
% ��ʾδ��ɿγ̴�ɶȼ���Ŀγ��б������ʦ
idxes_ZeroValue = strcmp(output(1).Contents(:,6),'0.000');
Course = categorical(output(1).Contents(idxes_ZeroValue,3));
Teacher = output(2).Contents(idxes_ZeroValue,6);
tabout = table(Course, Teacher);
catCourse = categories(Course);
idxes_Select = zeros(numel(catCourse),1);
for iCourse = 1:numel(catCourse)
    idxes_Select(iCourse) = find(tabout.Course == catCourse(iCourse),1);
end
if any(idxes_Select)
    fprintf('���пγ���δ�ύ���γ�Ŀ���ɶȽ����\n');
    disp(tabout(idxes_Select,:))
end
% ��MS-Word���Ʊ������1����ҵҪ���ɶȼ���������2����ҵҪ���������ݱ�
flag = input('�Ƿ���MS-Word���Ʊ�������[Y/N]','s');
switch flag
    case('Y')
        cprintf('Comments','��MS-Word���Ʊ������1����ҵҪ���ɶȼ���������2����ҵҪ���������ݱ�\n')
        for iTab = 1:numel(output)
            Tab2Word(output(iTab).Contents, ...
                     output(iTab).Heads, ...
                     output(iTab).TableType, ...
                     output(iTab).TableName);
        end
    case('N')
end