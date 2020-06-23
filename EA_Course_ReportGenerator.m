%% ��Matlab��������������ɶȷ��������ģ�����Ϊdocx�ļ�
% Wordģ�壺EA_ReportTemplate.dotx
%
% by Dr. Guan Guoqiang @ SCUT on 2020-06-15

%% ��ʼ��
% ��鹤���ռ������޴�ɶȷ������
if ~exist('QE_Courses', 'var')
    disp("���ֹ����빤������QE_Courses������load('QE_Courses.mat','QE_Courses')")
    return
end
% ����Matlab����������
import mlreportgen.dom.*
% ���������
tableStyle = {Width('100%'), Border('solid'), ColSep('solid'), RowSep('solid')};
mainHeaderRowStyle = {VAlign('middle'), InnerMargin('2pt', '2pt', '2pt', '2pt'), ...
    BackgroundColor('yellow')};
mainHeaderTextStyle = {Bold, OuterMargin('0pt', '0pt', '0pt', '0pt'), FontFamily('Arial'), HAlign('center')};
subHeaderRowStyle = {VAlign('middle'), InnerMargin('2pt', '2pt', '2pt', '2pt'), BackgroundColor('yellow')};
subHeaderTextStyle = {Bold, OuterMargin('0pt', '0pt', '0pt', '0pt'), FontFamily('Arial'), HAlign('center')};
bodyStyle = {OuterMargin('0pt', '0pt', '0pt', '0pt'), InnerMargin('2pt', '2pt', '2pt', '0pt')};

% ���塰��ɶȼ�����ܹ�����9��
Grps1(1) = TableColSpecGroup;
Grps1(1).Span = 9; % ������
% ��1-2�п��
Tab1Specs(1) = TableColSpec;
Tab1Specs(1).Span = 2;
Tab1Specs(1).Style = {Width("25%")};
% ��3�п��
Tab1Specs(2) = TableColSpec;
Tab1Specs(2).Span = 1;
Tab1Specs(2).Style = {Width("13%")};
% ��4�п��
Tab1Specs(3) = TableColSpec;
Tab1Specs(3).Span = 1;
Tab1Specs(3).Style = {Width("7%")};
% ��5-9�У��ϼ�6�У�
Tab1Specs(4) = TableColSpec;
Tab1Specs(4).Span = 5;
Tab1Specs(4).Style = {Width("6%")};
%
Grps1(1).ColSpecs = Tab1Specs;

%% ˳�����ɸ��γ̵Ĵ�ɶȷ������
for iCourse=1:length(QE_Courses)
    % ��������ļ����ƣ����磬�γ�����_�꼶
    class = QE_Courses.Class;
    filename = [QE_Courses(iCourse).Name, '_', class];
    % �����ĵ�����
    d = Document(filename, 'docx', 'EA_ReportTemplate.dotx');
    % ���ĵ�
    open(d);
    % ��λ����һ��־λ
    moveToNextHole(d);
    % ����γ�����
    append(d, QE_Courses(iCourse).Name);
    % ��λ����һ��־λ
    moveToNextHole(d);
    % ����γ̴���
    append(d, QE_Courses(iCourse).ID);
    % ��λ����һ��־λ
    moveToNextHole(d)
    
    % ���������
    t = Table(9);
    t.Style = [t.Style tableStyle];
    t.ColSpecGroups = [t.ColSpecGroups Grps1(1)];
    
    % ��ͷ
    r = TableRow;
    r.Style = [r.Style mainHeaderRowStyle];
    p = Paragraph('��ҵҪ��ָ���');
    p.Style = [p.Style mainHeaderTextStyle];
    te = TableEntry(p);
    te.RowSpan = 2;
    append(r,te);
    p = Paragraph('��ѧĿ��');
    p.Style = [p.Style mainHeaderTextStyle];
    te = TableEntry(p);
    te.RowSpan = 2;
    append(r,te);
    p = Paragraph('���;��');
    p.Style = [p.Style mainHeaderTextStyle];
    te = TableEntry(p);
    te.ColSpan = 2;
    append(r,te); 
    p = Paragraph('ʵ�ʴ��');
    p.Style = [p.Style mainHeaderTextStyle];
    te = TableEntry(p);
    te.ColSpan = 2;
    append(r,te);
    p = Paragraph('���Ŀ��ֵ���');
    p.Style = [p.Style mainHeaderTextStyle];
    te = TableEntry(p);
    te.ColSpan = 2;
    append(r,te);
    p = Paragraph('��ɶ�');
    p.Style = [p.Style mainHeaderTextStyle];
    te = TableEntry(p);
    te.RowSpan = 2;
    append(r,te);
    append(t,r);
    
    r = TableRow;
    r.Style = [r.Style subHeaderRowStyle];
    p = Paragraph('���۷�ʽ');
    p.Style = [p.Style subHeaderTextStyle];
    te = TableEntry(p);
    append(r,te);
    p = Paragraph('���˻���');
    p.Style = [p.Style subHeaderTextStyle];
    te = TableEntry(p);
    append(r,te);
    p = Paragraph('����ֵ');
    p.Style = [p.Style subHeaderTextStyle];
    te = TableEntry(p);
    append(r,te);
    p = Paragraph('ƽ���÷�');
    p.Style = [p.Style subHeaderTextStyle];
    te = TableEntry(p);
    append(r,te);
    p = Paragraph('Ŀ���ֵ');
    p.Style = [p.Style subHeaderTextStyle];
    te = TableEntry(p);
    append(r,te);
    p = Paragraph('���ճɼ�');
    p.Style = [p.Style subHeaderTextStyle];
    te = TableEntry(p);
    append(r,te);
    append(t,r);

    % ���ָ������ɴ�ɶȷ�����
    NumReq = length(QE_Courses(iCourse).Requirements);
    for iReq = 1:NumReq
        iRow = 1; iCol = 1;
        tdata = cell(sum(QE_Courses(iCourse).Transcript.Definition.Spec),9);
        tdata{iRow,iCol} = QE_Courses(iCourse).Requirements(iReq).Description;
        Objectives = QE_Courses(iCourse).Requirements(iReq).Objectives;
        NumObj = length(Objectives);
        for iObj = 1:NumObj
            Objectives(iObj).iRow = iRow;
            Objectives(iObj).iCol = iCol;
            tdata{iRow,2} = Objectives(iObj).Description;
            tdata{iRow,9} = Objectives(iObj).Result;
            NumType = length(Objectives(iObj).EvalTypes);
            RowNum_Type = zeros(NumType,1);
            for iType = 1:NumType
                iCol = 4;
                Objectives(iObj).EvalTypes(iType).iRow = iRow;
                Objectives(iObj).EvalTypes(iType).iCol = iCol;
                tdata{iRow,iCol} = [Objectives(iObj).EvalTypes(iType).Code, ': ', ...
                                    Objectives(iObj).EvalTypes(iType).Description];
                NumWay = length(Objectives(iObj).EvalTypes(iType).EvalWays);
                for iWay = 1:NumWay
                    iCol = 3;
                    Objectives(iObj).EvalTypes(iType).EvalWays(iWay).iRow = iRow;
                    Objectives(iObj).EvalTypes(iType).EvalWays(iWay).iCol = iCol;                    
                    tdata{iRow,iCol} = [Objectives(iObj).EvalTypes(iType).EvalWays(iWay).Code, ': ', ...
                                        Objectives(iObj).EvalTypes(iType).EvalWays(iWay).Description];
                    tdata{iRow,5} = Objectives(iObj).EvalTypes(iType).EvalWays(iWay).FullCredit;
                    tdata{iRow,6} = Objectives(iObj).EvalTypes(iType).EvalWays(iWay).Credit;
                    tdata{iRow,7} = Objectives(iObj).EvalTypes(iType).EvalWays(iWay).Correction.FullCredit;
                    tdata{iRow,8} = Objectives(iObj).EvalTypes(iType).EvalWays(iWay).Correction.Credit;
                    iRow = iRow+1;
                end
            end        
        end
        NRow = iRow-1;
        tdata = tdata(1:NRow,1:9);

        for iRow = 1:size(tdata,1)
            r = TableRow;
            r.Style = [r.Style bodyStyle];
            for iCol = 1:9
                if ~isempty(tdata{iRow,iCol})
                    content = tdata{iRow,iCol};
                    if isnumeric(content)
                        content = num2str(round(content,4,'significant'));
                    end
                    te = TableEntry(content);
                    if NRow ~= 1
                        % �Ҹ��е���һ���ǿ�Ԫ�ص�λ��
                        for jRow = (iRow+1):NRow
                            NotEmpty = false;
                            if ~isempty(tdata{jRow,iCol})
                                NotEmpty = true;
                                break
                            end
                        end
                        if NotEmpty
                            te.RowSpan = jRow-iRow;
                        else
                            te.RowSpan = jRow-iRow+1;
                        end
                    end
                    append(r,te);
                end
            end
            append(t,r);
        end
    end
    
    % �γ̴�ɶ���
    r = TableRow;
    te = TableEntry('��ɶȽ��');
    append(r,te);
    te = TableEntry(num2str(round(QE_Courses.Result,4,'significant')));
    te.ColSpan = 8;
    append(r,te);
    append(t,r);
    
    % ��ɶȷ�������
    r = TableRow;
    te = TableEntry('��ɶȷ���');
    append(r,te);
    te = TableEntry(QE_Courses.Analysis);
    te.ColSpan = 8;
    append(r,te);
    append(t,r);   
    
    % д����
    append(d,t);
    
    % ��ҳ
    append(d,PageBreak());
    
    % ��λ����һ��־λ
    moveToNextHole(d);
    % ����γ�����
    append(d, QE_Courses(iCourse).Name);
    
    % ��λ����һ��־λ
    moveToNextHole(d);
    
    % ����ɼ�������п�
    NCol = width(QE_Courses(iCourse).Transcript.Detail); % ������
    Grps2(1) = TableColSpecGroup;
    Grps2(1).Span = NCol;
    % ��1-2�п��
    Tab2Specs(1) = TableColSpec;
    Tab2Specs(1).Span = 2;
    Tab2Specs(1).Style = {Width("10%")};
    % ��3�п��
    Tab2Specs(2) = TableColSpec;
    Tab2Specs(2).Span = 1;
    Tab2Specs(2).Style = {Width("5%")};
    % ��4�п��
    Tab2Specs(3) = TableColSpec;
    Tab2Specs(3).Span = 1;
    Tab2Specs(3).Style = {Width("3%")}; 
    % ��5�п��
    Tab2Specs(4) = TableColSpec;
    Tab2Specs(4).Span = 1;
    Tab2Specs(4).Style = {Width("22%")};
    % �����п��
    Tab2Specs(5) = TableColSpec;
    Tab2Specs(5).Span = NCol-5;
    Tab2Specs(5).Style = {Width([num2str(50/(NCol-5)) '%'])};
    %
    Grps2(1).ColSpecs = Tab2Specs;
    
    % ���������
    tdata2 = table2cell(QE_Courses(iCourse).Transcript.Detail);
    Headers = QE_Courses(iCourse).Transcript.Detail.Properties.VariableNames;
    t2 = Table(length(Headers));
%     t2 = Table(QE_Courses(iCourse).Transcript.Detail);
    t2.Style = [t2.Style tableStyle];
    t2.ColSpecGroups = [t2.ColSpecGroups Grps2(1)];
    
    % ��ͷ
    r = TableRow;
    r.Style = [r.Style mainHeaderRowStyle];
    for iCol = 1:length(Headers)
        p = Paragraph(Headers{iCol});
        p.Style = [p.Style mainHeaderTextStyle];
        te = TableEntry(p);
        append(r,te);
    end
    append(t2,r);
    
    % ������
    for iRow = 1:size(tdata2,1)
        r = TableRow;
        r.Style = [r.Style bodyStyle {HAlign('center')}];
        for iCol = 1:size(tdata2,2)
            content = tdata2{iRow,iCol};
            if isnumeric(content)
                content = num2str(round(content,3,'significant'));
            end
            te = TableEntry(content);
            append(r,te);
        end
        append(t2,r);
    end
end
    
% д���
append(d,t2);

% �ر��ĵ�
close(d);

