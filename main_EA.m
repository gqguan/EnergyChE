%% ��ɶȼ���ű�
%
% ������Ҫ����
% ��1��ѡ����Ҫ���м���Ŀγ���ϸ�ɼ���
% ��2�����ݳɼ������������û����봰�ڣ����й�ѡ��ѧĿ���뿼�˷�ʽ�Ĺ�ϵ
% ��3�����д�ɶȼ���
% ��4�����������QE_Courses.mat
%
% by Dr. Guan Guoqiang @ SCUT on 2020/6/29

%% ����γ���ϸ�ɼ���
% ��������
dataset_New = ImportTranscripts(1);
dataset_Updated = dataset_New;
% ��ȡ����ɼ������꼶
Years = cellfun(@(x) ['class',x], categories(categorical({dataset_New.Class})), ...
                'UniformOutput', false);
% ��ӵ�database.mat�е�dataset1
load('database.mat', 'dataset1')
% ɾ�������ݿ���һ�µĳɼ���
idxFound = false(1,length(dataset1));
for iCourse = 1:length(dataset_New)    
    idxFound = idxFound|arrayfun(@(x) isequal(dataset_New(iCourse),x), dataset1);
    if any(idxFound)
        fprintf('�����桿����dataset1������%s���γ̡�%s���ɼ�����\n', ...
                dataset_New(iCourse).Class,dataset_New(iCourse).Course)
        dataset_Updated(1) = [];
    end
end
if ~isempty(dataset_Updated)
    dataset1 = [dataset1,dataset_Updated];
    save('database.mat', '-append', 'dataset1')
    % ���γ̱���������
    db_Outcome1 = GetData(Years,1);
    fprintf('�����桿����dataset.mat�е�db_Outcome1������\n')
    save('database.mat','-append','db_Outcome1')  
else
    fprintf('û�е����µĳɼ�����\n')
    opt = input('�Ƿ�ʹ��database.mat�е�dataset1�������д�ɶȼ���[����1��������/�������֣���ֹ��]��');
    switch opt
        case(1)
            fprintf('�������д�ɶȼ��㡣\n')
        otherwise
            fprintf('��ֹ����\n')
            return
    end
end


%% ���д�ɶȼ���
load('QE_Courses.mat', 'QE_Courses')
for iCourse = 1:length(dataset_New)
    CourseName = dataset_New(iCourse).Course;
    Class = ['class',dataset_New(iCourse).Class];
    fprintf('���ڽ���%s���γ̡�%s����ɶȼ���...\n',Class(6:end),CourseName)
    % �����ɶ�
    opt = input('�Ƿ���������db_Outcome0��db_Outcome1����[����1���ǣ�/0����ʹ��database.mat�еı�����]');
    QE_Course = EA_Course(CourseName, Class, opt);
    % �����db_Course�������ҵ�����γ�����ƥ��Ľ�ѧĿ��ͷ����ı�
    if ~exist('db_Course', 'var')
        load('database.mat', 'db_Course')
    end
    idxFound = strcmp({db_Course.Name}, CourseName);
    if any(idxFound)
        fprintf('�ӿγ���Ϣ�������롰��ѧĿ�ꡱ�͡������ı�����\n')
        Objectives = db_Course(idxFound).Objectives;
        Analysis = db_Course(idxFound).(Class).Analysis;
        QE_Course = EA_FillText(QE_Course, Objectives, Analysis);
    end
    % �����ѽ��д�ɶȷ����Ŀγ̿�
    QE_Courses = EA_SaveQE(QE_Course, QE_Courses);
end
% ����QE_Courses
fprintf('����QE_Courses.mat��\n')
save('QE_Courses.mat', '-append', 'QE_Courses')