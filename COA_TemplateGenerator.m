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
    Evaluation = cell(1,7);
%     Evaluation(1,1) = {'����'};
%     Evaluation(1,2) = {'������"A1_4��A2_2��A3_1��A3_2"��ʾͳ�ֱ��е���Щ���Ӧ�ڸÿ���Ŀ��'};
%     Evaluation(1,3) = {'����A1_4��A2_2��A3_1��A3_2��ϼ�����Ϊ45'};
%     Evaluation(1,4) = {'��ͳ�ֱ�A1_4��A2_2��A3_1��A3_2�е�ƽ��ֵ֮��33.21'};
%     Evaluation(1,5) = {'����Ȩ�أ�����0.2'};
%     Evaluation(1,6) = {'����÷�'};
%     Evaluation(1,7) = {'��ѧĿ��Ĵ�ɶȣ�0~1��ֵ��'};
    % �����γ�Ŀ��˵��������
    CO_description = cell(M*size(Evaluation,1),10);
    row1 = 1;
    for m = 1:M
        CO_description(row1,1:2) = db_GradRequire{idx_UniNum(m),:};
        CO_description(row1,3) = {'��������Ӧ��ѧĿ�꡿'};
        [height, width] = size(Evaluation);
        row2 = row1+height;
        CO_description(row1:(row2-1), 4:(3+width)) = Evaluation;
        row1 = row2;
    end
    CO_description(1,4) = {'����'};
    CO_description(1,5) = {'�����A1_4+A2_2+A3_1+A3_2����ʾͳ�ֱ��е���Щ���Ӧ�ڸÿγ�Ŀ��'};
    CO_description(1,6) = {'�����45����ʾMethod���еĿ����ܷ�ֵ'};
    CO_description(1,7) = {'�����33.21����ʾͳ�ֱ�A1_4��A2_2��A3_1��A3_2�е�ƽ��ֵ֮��'};
    CO_description(1,8) = {'�����1����ʾ�����۷�ʽ����Ӧ��ѧĿ���Ȩ��Ϊ1'};
    CO_description(1,9) = {'�����0.738����ʾ�÷�=Average/CreditΪ0.738'};
    CO_description(1,10) = {'�����0.738����ʾCompleteness=Weight*RateΪ0.738'};
    % ��ɶȷ�����
    output = cell(5+size(CO_description,1),9);
    output(1,1) = {'�γ�����'}; output(1,2) = db_Curriculum.Name(course_sn);
    output(2,1) = {'�γ̴���'}; output(2,2) = db_Curriculum.ID(course_sn);
    output(3,1) = {'ѧ���༶'}; output(3,2) = {strcat('��Դ����',year(end-3:end),'��')};
    output(4,:) = {'��ҵҪ��ָ���','�γ�Ŀ��','���˻���','���۷�ʽ','����','ƽ����','Ȩ��','�÷�','��ɶ�'};
    output(5:4+size(CO_description,1),:) = CO_description(:,2:10);
    output(5+size(CO_description,1),1) = {'��ɶȷ���'}; output(5+size(CO_description,1),2) = {'����Ͼ���γ�����������Ŀ��Ĵ��������ص��ע�����Ľ��Ĵ�ʩ��Ч����'};
    output = cell2table(output);
    % ת��Ϊ�γ�Ŀ��˵������ҵҪ��ָ��㣬��ѧĿ�꣬���Ժ�ƽʱ�������˻��ڵ�Ȩ��
    CO_description = cell2table(CO_description);
    CO_description.Properties.VariableNames = {'No','GR_Spec','Objective',...
        'Way','Method','Credit','Average','Weight','Rate','Completeness'};
    % ����ͳ�ֱ�ʾ��
    load('sample.mat')
    % ��ָ�������������������
    filename = strcat(db_Curriculum.Name{course_sn},'_',year(end-3:end),'��.xlsx');
    msg_str = sprintf('�����γ�Ŀ���ɶȷ���ģ���ļ���%s', filename);
    Setlog(msg_str, 3);
    warning off MATLAB:xlswrite:AddSheet % �ر��½���ľ�����ʾ
    writetable(CO_description, filename, 'Sheet', '�γ�Ŀ��˵��')
    writetable(sample, filename, 'Sheet', 'ͳ�ֱ�ʾ����')
    writetable(output, filename, 'Sheet', '��ɶȷ���')
end
