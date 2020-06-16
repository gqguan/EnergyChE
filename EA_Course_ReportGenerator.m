%% ��Matlab��������������ɶȷ��������ģ�����Ϊdocx�ļ�
%
% by Dr. Guan Guoqiang @ SCUT on 2020-06-15

%% ��ʼ��
% ��鹤���ռ������޴�ɶȷ������

% ����Matlab����������
import mlreportgen.dom.*
% ���������
tableStyle = ...
    { ...
    Width("100%"), ...
    Border("solid"), ...
    RowSep("solid"), ...
    ColSep("solid") ...
    };
tableEntriesStyle = ...
    { ...
    HAlign("center"), ...
    VAlign("middle") ...
    };
% ��ͷ��ʽ
headerRowStyle = ...
    { ...
    InnerMargin("2pt","2pt","2pt","2pt"), ...
    BackgroundColor("gray"), ...
    Bold(true) ...
    };
% ��ͷ����
headerContent = ...
    { ...
    '��ҵҪ��ָ���', '��ѧĿ��', '���۷�ʽ', '���˻���', ...
    '����', 'ƽ���÷�', 'Ŀ��ֵ', '�÷�', 'Ŀ���ɶ�' ...
    };
% ������ܹ�����9��
grps(1) = TableColSpecGroup;
grps(1).Span = 9; % ������
% ��1-2�п��
specs(1) = TableColSpec;
specs(1).Span = 2;
specs(1).Style = {Width("25%")};
% ��3�п��
specs(2) = TableColSpec;
specs(2).Span = 1;
specs(2).Style = {Width("20%")};
% ��4-9�У��ϼ�6�У�
specs(3) = TableColSpec;
specs(3).Span = 6;
specs(3).Style = {Width("5%")};
grps(1).ColSpecs = specs;

%% ˳�����ɸ��γ̵Ĵ�ɶȷ������
for i=1:length(db_Outcome)
    % ��������ļ����ƣ����磬�γ�����_�꼶
    filename = [db_Outcome(i).Name{:}, '_', '2015'];
    % �����ĵ�����
    d = Document(filename, 'docx', 'EA_ReportTemplate.dotx');
    % ���ĵ�
    open(d);
    % ��λ����һ��־λ
    moveToNextHole(d);
    % ����γ�����
    append(d, db_Outcome(i).Name{:});
    % ��λ����һ��־λ
    moveToNextHole(d);
    % ����γ̴���
    append(d, db_Outcome(i).ID{:});
    % ����db_Curriculum�ж����֧�ž����ȡָ��ͳһ���
    idx_UniNum = find(db_Curriculum.ReqMatrix(i,:));
    % ����ָ����Ŀ����վ���
    bodyContent = cell(length(idx_UniNum),9);   
    % �����һ������֧��ָ����ı�
    bodyContent(:,1) = db_GradRequire{idx_UniNum,2}; 
    % ����ڶ���������Ӧ�Ľ�ѧĿ�꡾���ܴ�������
    % �������������
    tableContent = [headerContent; bodyContent];  
    % ���ɱ�
    tout = Table(tableContent);   
    % Ӧ�ñ�����
    tout.ColSpecGroups = grps;
    tout.Style = tableStyle;
    tout.TableEntriesStyle = tableEntriesStyle;
    firstRow = tout.Children(1);
    firstRow.Style = headerRowStyle;
    % ��λ����һ��־λ
    moveToNextHole(d);
    % �����
    append(d, tout);
    % �ر��ĵ�
    close(d);
end
