%% ��QE_Course�������QE_Courses��
%
% by Dr. Guan Guoqiang @ SCUT on 2020/6/29
%
function [QE_Courses,QE_Courses_original,QE_Courses_MultiRepeated] = EA_SaveQE(QE_Course)
%
if ~exist('QE_Courses', 'var')
    load('QE_Courses.mat', 'QE_Courses')
end
QE_Courses_original = QE_Courses;
% ͨ�����QE_Course�ֶ�ID��Name��Class�Ƿ���QE_Courses���ظ�
idxRepeated = strcmp({QE_Courses.ID},QE_Course.ID) & ...
              strcmp({QE_Courses.Name},QE_Course.Name) & ...
              strcmp({QE_Courses.Class},QE_Course.Class);
% ��QE_Course�滻QE_Courses�е��ظ���
if any(idxRepeated)
    fprintf('�����桿�滻%s���γ̡�%s����ɶȷ��������\n',QE_Course.Class,QE_Course.Name)
    QE_Courses(idxRepeated) = QE_Course;
    % �����ڶ���ظ���ʱ
    if sum(idxRepeated) > 1
        fprintf('�����桿����%s���γ̡�%s�����ڶ����ɶȷ���������滻��ɾ���ظ��\n',QE_Course.Class,QE_Course.Name)
        QE_Courses_MultiRepeated = QE_Courses;
        iRepeated = find(idxRepeated);
        iRepeated(1) = false;
        QE_Courses(iRepeated) = [];
    else
        QE_Courses_MultiRepeated = [];
    end
else
    fprintf('���%s���γ̡�%s����ɶȷ��������\n',QE_Course.Class,QE_Course.Name)
    QE_Courses = [QE_Courses,QE_Course];
end

end