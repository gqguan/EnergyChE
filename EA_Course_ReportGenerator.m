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

%% ˳�����ɸ��γ̵Ĵ�ɶȷ������
for iCourse=1:length(QE_Courses)
    % ��������ļ����ƣ����磬�γ�����_�꼶
    class = QE_Courses(iCourse).Class;
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
    t.ColSpecGroups = [t.ColSpecGroups,GetTabWidth('��ɶȷ�����', 9)];
    
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
    p = Paragraph('�������;��');
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
        tdata{iRow,9} = QE_Courses(iCourse).Requirements(iReq).Result;
        Objectives = QE_Courses(iCourse).Requirements(iReq).Objectives;
        NumObj = length(Objectives);
        for iObj = 1:NumObj
            Objectives(iObj).iRow = iRow;
            Objectives(iObj).iCol = iCol;
            tdata{iRow,2} = Objectives(iObj).Description;
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
    p = Paragraph(num2str(round(QE_Courses(iCourse).Result,4,'significant')));
    p.Style = [p.Style mainHeaderTextStyle {HAlign('right')}];
    te = TableEntry(p);
    te.ColSpan = 8;
    append(r,te);
    append(t,r);
    
    % ��ɶȷ�������
    r = TableRow;
    te = TableEntry('��ɶȷ���');
    append(r,te);
    te = TableEntry(QE_Courses(iCourse).Analysis);
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
    
    % ���������
    tdata2 = table2cell(QE_Courses(iCourse).Transcript.Detail);
    Headers = QE_Courses(iCourse).Transcript.Detail.Properties.VariableNames;
    % ������������25ʱ�ֳɶ�������
    idxesCols = SplitTabCol(NCol); % idxesCol����Ϊ�ӱ���Ŀ��ÿ��Ϊ�ӱ���ԭ���������
    
    for iTab = 1:size(idxesCols,1)
        idxesCol = idxesCols(iTab,:);
        subTab_data = tdata2(:,idxesCol);
        subTab_head = Headers(idxesCol);
        NCol_subTab = sum(idxesCol);
        % ���������
        t2 = Table(length(subTab_head));
        t2.Style = [t2.Style tableStyle];
        t2.ColSpecGroups = [t2.ColSpecGroups,GetTabWidth(QE_Courses(iCourse).Name, NCol_subTab)];
        % ��ͷ
        r = TableRow;
        r.Style = [r.Style mainHeaderRowStyle];
        for iCol = 1:length(subTab_head)
            p = Paragraph(subTab_head{iCol});
            p.Style = [p.Style mainHeaderTextStyle];
            te = TableEntry(p);
            append(r,te);
        end
        append(t2,r);
        % ������
        for iRow = 1:size(subTab_data,1)
            r = TableRow;
            r.Style = [r.Style bodyStyle {HAlign('center')}];
            for iCol = 1:size(subTab_data,2)
                content = subTab_data{iRow,iCol};
                if isnumeric(content)
                    content = num2str(round(content,3,'significant'));
                end
                te = TableEntry(content);
                append(r,te);
            end
            append(t2,r);
        end
        % д���
        append(d,t2);
        if iTab ~= size(idxesCols,1)
            append(d,Paragraph('�±���...'));
        end
    end

% �ر��ĵ�
close(d);

end

function idxes = SplitTabCol(n)
    % �ѱ��кŷ�Ϊ��Ϣ�У�1-4�У��������У����ࣩ
    infoCol = 1:4;
    dataCol = 5:n;
    ndata = length(dataCol);
    % �����������Ϊ25�������ӱ�
    NSubTab = ceil(length(dataCol)/21); % �ӱ���Ŀ
    % �ӱ�����������ֵ��ÿ�а���25�У�����Ϊ�ӱ���Ŀ��
    idxes = false(NSubTab,n);
    iStart = 5; nleft = ndata;
    for iSubTab = 1:NSubTab
        idxes(iSubTab,1:4) = true;
        iEnd = iStart+nleft-1;
        if iEnd-iStart > 21
            iEnd = iStart+21-1;
            idxes(iSubTab,iStart:iEnd) = true;
            iStart = iEnd+1;
            nleft = nleft-21;
        else
            idxes(iSubTab,iStart:iEnd) = true;
        end
    end
end

function Grps = GetTabWidth(type, NCol)
    import mlreportgen.dom.*
    % ����ɼ�������п�
    Grps = TableColSpecGroup;
    Grps.Span = NCol;    
    switch type
        case('��ɶȷ�����')
            % ��1-2�п��
            TabSpecs(1) = TableColSpec;
            TabSpecs(1).Span = 2;
            TabSpecs(1).Style = {Width("25%")};
            % ��3�п��
            TabSpecs(2) = TableColSpec;
            TabSpecs(2).Span = 1;
            TabSpecs(2).Style = {Width("13%")};
            % ��4�п��
            TabSpecs(3) = TableColSpec;
            TabSpecs(3).Span = 1;
            TabSpecs(3).Style = {Width("7%")};
            % ��5-9�У��ϼ�6�У�
            TabSpecs(4) = TableColSpec;
            TabSpecs(4).Span = 5;
            TabSpecs(4).Style = {Width("6%")};          
        case('��ҵ���(����)')
            % ��1-2�п��
            TabSpecs(1) = TableColSpec;
            TabSpecs(1).Span = 2;
            TabSpecs(1).Style = {Width("10%")};
            % ��3�п��
            TabSpecs(2) = TableColSpec;
            TabSpecs(2).Span = 1;
            TabSpecs(2).Style = {Width("5%")};
            % ��4�п��
            TabSpecs(3) = TableColSpec;
            TabSpecs(3).Span = 1;
            TabSpecs(3).Style = {Width("3%")}; 
            % ��5�п��
            TabSpecs(4) = TableColSpec;
            TabSpecs(4).Span = 1;
            TabSpecs(4).Style = {Width("22%")};
            % �����п��
            TabSpecs(5) = TableColSpec;
            TabSpecs(5).Span = NCol-5;
            TabSpecs(5).Style = {Width([num2str(50/(NCol-5)) '%'])};
        otherwise
            % ��1�п��
            TabSpecs(1) = TableColSpec;
            TabSpecs(1).Span = 1;
            TabSpecs(1).Style = {Width("13%")};
            % ��2�п��
            TabSpecs(2) = TableColSpec;
            TabSpecs(2).Span = 1;
            TabSpecs(2).Style = {Width("7%")};
            % ��3�п��
            TabSpecs(3) = TableColSpec;
            TabSpecs(3).Span = 1;
            TabSpecs(3).Style = {Width("10%")};
            % ��4�п��
            TabSpecs(4) = TableColSpec;
            TabSpecs(4).Span = 1;
            TabSpecs(4).Style = {Width("5%")};
            % �����п��
            TabSpecs(5) = TableColSpec;
            TabSpecs(5).Span = NCol-5;
            TabSpecs(5).Style = {Width([num2str(65/(NCol-4)) '%'])};         
    end
    %
    Grps.ColSpecs = TabSpecs;             
end


