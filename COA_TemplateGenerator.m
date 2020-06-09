%% ����ȫ���γ̵Ĵ�ɶȷ���Excelģ��
%
% by Dr. Guan Guoqiang @ SCUT on 2020/6/10
%

%% ��ʼ��
% ��ȡ�γ��б�
clear;
Years = {'class2015'}; % ��ֵΪ���б�ҵҪ���ɶȼ����ѧ���꼶
% Get data for processing
year = Years{:};
msg_str = sprintf('�ӱ��湤����database.mat�е��� %s ����', year);
Setlog(msg_str, 3);
[db_Outcome, db_Curriculum, db_GradRequire] = GetData(Years);

%% �����γ�Ŀ��˵����
% �г���ÿ�ſγ̵ı�ҵҪ��ָ���
NumCourse = length(db_Outcome);
for course_sn = 1:NumCourse
    idx_UniNum = find(db_Curriculum.ReqMatrix(course_sn,:)); % �γ�֧��ָ���������
    M = length(idx_UniNum); % �γ�֧�ŵ�ָ�����Ŀ
    % �ٶ�ͨ�����Ժ�ƽʱ�������ڿ��ˣ�������Ȩ�طֱ�Ϊ0.7��0.3
    EvalMethod.Name = {'Exam','Regular'};
    EvalMethod.Weight = ones(M,1)*[0.7,0.3];
    % �����γ�Ŀ��˵������ҵҪ��ָ��㣬��ѧĿ�꣬���Ժ�ƽʱ�������˻��ڵ�Ȩ��
    CO_description = [db_GradRequire(idx_UniNum,:),...
                      cell2table(cell(M,1),'VariableNames',{'Objective'}),...
                      array2table(EvalMethod.Weight,'VariableNames',EvalMethod.Name)];
end

%% ���������˻��ڵ�ѧ���ɼ���

%% ������ɶȷ�����