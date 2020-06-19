%% ��Matlab��������������ɶȷ��������ģ�����Ϊdocx�ļ�
%
% by Dr. Guan Guoqiang @ SCUT on 2020-06-15

%% ��ʼ��
% ��鹤���ռ������޴�ɶȷ������
if ~exist('db_Outcome', 'var')
    disp('Required variable of db_Outcome is NOT existed')
    return
end
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
    BackgroundColor("yellow"), ...
    Bold(true) ...
    };
% ��ɶȼ����ı�ͷ����
headerContent_HowToCalc = ...
    { ...
    '��ҵҪ��ָ���', '��ѧĿ��', '���۷�ʽ', '���˻���', ...
    '����', 'ƽ���÷�', 'Ŀ��ֵ', '�÷�', 'Ŀ���ɶ�' ...
    };
% ���塰��ɶȼ�����ܹ�����9��
grps_HowToCalc(1) = TableColSpecGroup;
grps_HowToCalc(1).Span = 9; % ������
% ��1-2�п��
specs_HowToCalc(1) = TableColSpec;
specs_HowToCalc(1).Span = 2;
specs_HowToCalc(1).Style = {Width("25%")};
% ��3�п��
specs_HowToCalc(2) = TableColSpec;
specs_HowToCalc(2).Span = 1;
specs_HowToCalc(2).Style = {Width("20%")};
% ��4-9�У��ϼ�6�У�
specs_HowToCalc(3) = TableColSpec;
specs_HowToCalc(3).Span = 6;
specs_HowToCalc(3).Style = {Width("5%")};
%
grps_HowToCalc(1).ColSpecs = specs_HowToCalc;

%% ˳�����ɸ��γ̵Ĵ�ɶȷ������
for i=1:length(db_Outcome)
    % ��������ļ����ƣ����磬�γ�����_�꼶
    class = fieldnames(db_Outcome);
    class = class{4};
    filename = [db_Outcome(i).Name{:}, '_', class(6:end)];
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
    % ���조��ɶȼ������������
    tableContent = [headerContent_HowToCalc; bodyContent];  
    % ���ɡ���ɶȼ����
    tout_HowToCalc = Table(tableContent);   
    % Ӧ�ñ�����
    tout_HowToCalc.ColSpecGroups = grps_HowToCalc;
    tout_HowToCalc.Style = tableStyle;
    tout_HowToCalc.TableEntriesStyle = tableEntriesStyle;
    firstRow = tout_HowToCalc.Children(1);
    firstRow.Style = headerRowStyle;
    % ��λ����һ��־λ
    moveToNextHole(d);
    % ���롰��ɶȼ����
    append(d, tout_HowToCalc);
    
    % ��λ����һ��־λ
    moveToNextHole(d);
    % ���롰��ɶȷ���˵����
    append(d, '��ɶȷ���˵����ʾ����');
    % ��λ����һ��־λ
    moveToNextHole(d);
    % ��ҳ
    append(d, PageBreak());
    
    % ��λ����һ��־λ
    moveToNextHole(d);
    % ����γ�����
    append(d, db_Outcome(i).Name{:});
    
    % ��λ����һ��־λ
    moveToNextHole(d); 
    % ���롰�Ͽ�ѧ�ڡ���ͨ����ȡ�ɼ����ĵ�1��ͬѧ�γ̴����е�ǰ13���ַ���
    append(d, db_Outcome(i).(class).CourseCode{1}(1:13));
    
    % ѧ���ɼ���
    tout_Details = db_Outcome(i).(class);
    % ת��Ϊmlreportgen.dom.Table���󡾱��Ҫ�㡿
    tout_Details = Table(tout_Details(:,[1:3,5:(end-2)])); 
    
    % ���塰ѧ���ɼ���������
    grps_Details(1) = TableColSpecGroup;
    % ��1�п��
    specs_Details(1) = TableColSpec;
    specs_Details(1).Span = 1;
    specs_Details(1).Style = {Width("25%")};
    % ��2�п��
    specs_Details(2) = TableColSpec;
    specs_Details(2).Span = 1;
    specs_Details(2).Style = {Width("15%")};
    % ��3�п��
    specs_Details(3) = TableColSpec;
    specs_Details(3).Span = 1;
    specs_Details(3).Style = {Width("25%")};
    % �����п��
    specs_Details(4) = TableColSpec;
    specs_Details(4).Span = tout_Details.NCols-3;
    specs_Details(4).Style = {Width([num2str(35/(tout_Details.NCols-3)) '%'])};
    %
    grps_Details(1).ColSpecs = specs_Details;
    % Ӧ�ñ�����
    tout_Details.ColSpecGroups = grps_Details;
    tout_Details.Style = tableStyle;
    % ��λ����һ��־λ
    moveToNextHole(d);
    % ���롰�ɼ�����
    append(d, tout_Details);
    
    % �ر��ĵ�
    close(d);
end
