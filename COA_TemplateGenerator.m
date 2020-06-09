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
    Evaluation.Method = {'Exam';'Regular'};
    Evaluation.Weight = [0.7;0.3];
    Evaluation.Way = {'A1.1+A2+A3';'B1~12'};
    EvalWays(1:M) = Evaluation;
    % �����γ�Ŀ��˵������ҵҪ��ָ��㣬��ѧĿ�꣬���Ժ�ƽʱ�������˻��ڵ�Ȩ��
    CO_description = [db_GradRequire(idx_UniNum,:),...
                      cell2table(cell(M,1),'VariableNames',{'Objective'}),...
                      struct2table(EvalWays)];
    filename = strcat(db_Curriculum.Name{course_sn},'_',year,'.xlsx');
    msg_str = sprintf('Export results of goal achievement in %s.', filename);
    Setlog(msg_str, 3);
    % ��ָ�������������������
    warning off MATLAB:xlswrite:AddSheet % �ر��½���ľ�����ʾ
    writetable(CO_description, filename, 'Sheet', '�γ�Ŀ��˵����')
end

%% ���������˻��ڵ�ѧ���ɼ���

%% ������ɶȷ�����