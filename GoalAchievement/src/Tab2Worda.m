%% ��Word�����ɱ��
%
% ����˵����
% * �Զ��ϲ����е�Ԫ��
%
% �������
% TabType - '��ҵҪ���ɶȽ����'
%           '��ҵҪ���������ݱ�'
%           '�γ̴�ɶȷ�����'
%           '��ҵ���(����)�ɼ���'
%           '����'
%
% by Dr. Guan Guoqiang @ SCUT on 2020-07-08

function t = Tab2Worda(TabContent, TabType, TabName, TabHead)

%% ��ʼ��
% �������У��
if exist('TabContent','var')
    NCol = size(TabContent,2);
    if exist('TabHead','var')
        if size(TabHead,2) ~= NCol
            cprintf('err','�����������ͷ�����Ŀ�Ȳ�һ�£�\n')
            return
        end
    else
        cprintf('Comments','δָ����ͷ�����û�б�ͷ�ı�\n')
    end
else
    cprintf('err','������ȱ�ٱ�Ҫ���������TabContent��\n')
    return
end
if ~exist('TabType','var')
    cprintf('Comments','δָ����������ͣ�ʹ��ȱʡֵ����ҵҪ���ɶȽ������\n')
    TabType = '��ҵҪ���ɶȽ����';
end
if ~exist('TabName','var')
    cprintf('Comments','δָ����������ƣ�ʹ��ȱʡֵ������Ϊ������\n')
    TabName = TabType;
end

% ����Matlab����������
import mlreportgen.dom.*
% ����������ʽ����
headFont=FontFamily;
headFont.FamilyName='Arial';
headFont.EastAsiaFamilyName='����';
bodyFont=FontFamily;
bodyFont.FamilyName='Times New Roman';
bodyFont.EastAsiaFamilyName='����';
% ���������
tableStyle = {Width('100%'), Border('solid'), ColSep('solid'), RowSep('solid')};
mainHeaderRowStyle = {HAlign('center'), VAlign('middle'), ...
    OuterMargin('0pt', '0pt', '0pt', '0pt'), InnerMargin('2pt', '2pt', '2pt', '2pt'), ...
    BackgroundColor('lightgrey'), LineSpacing('0pt'), headFont};
bodyStyle = {OuterMargin('0pt', '0pt', '0pt', '0pt'), InnerMargin('2pt', '2pt', '2pt', '2pt'), bodyFont};

%%
% ���������
t = Table(NCol);
t.Style = [t.Style tableStyle];

% �趨���и��п��
t.ColSpecGroups = [t.ColSpecGroups,GetTabWidth(TabType,NCol)];

% ��ͷ
if nargin == 4
    CombineVCell(TabHead, mainHeaderRowStyle)
end

% ����
CombineVCell(TabContent, bodyStyle)

function CombineVCell(cArray,Style)
    import mlreportgen.dom.*
    NRow = size(cArray,1);
    for iRow = 1:NRow
%             if iRow == 15
%                 disp('debugging')
%             end
        r = TableRow;
        r.Style = [r.Style Style];
        for iCol = 1:NCol
            if ~isempty(cArray{iRow,iCol})
                content = cArray{iRow,iCol};
                if isnumeric(content) % ��ֵ����4λ��Ч����
                    content = num2str(round(content,4,'significant'));
                end
                te = TableEntry(content);
                if NRow ~= 1
                    % �Ҹ��е���һ���ǿ�Ԫ�ص�λ��
                    for jRow = (iRow+1):NRow
                        NotEmpty = false;
                        if ~isempty(cArray{jRow,iCol})
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

function Grps = GetTabWidth(type, NCol)
    import mlreportgen.dom.*
    % ����ɼ�������п�
    Grps = TableColSpecGroup;
    Grps.Span = NCol;    
    switch type
        case('ʵ���ѧ���ݱ�')
            TabSpecs(1) = TableColSpec;
            TabSpecs(1).Span = 1;
            TabSpecs(1).Style = {Width('7.5%')};
            TabSpecs(2) = TableColSpec;
            TabSpecs(2).Span = 1;
            TabSpecs(2).Style = {Width('20%')};
            TabSpecs(3) = TableColSpec;
            TabSpecs(3).Span = 1;
            TabSpecs(3).Style = {Width('7.5%')};
            TabSpecs(4) = TableColSpec;
            TabSpecs(4).Span = 1;
            TabSpecs(4).Style = {Width('20%')};
            TabSpecs(5) = TableColSpec;
            TabSpecs(5).Span = 3;
            TabSpecs(5).Style = {Width('10%')};
            TabSpecs(6) = TableColSpec;
            TabSpecs(6).Span = 1;
            TabSpecs(6).Style = {Width('15%')};
        case('���۱�׼��')
            TabSpecs(1) = TableColSpec;
            TabSpecs(1).Span = 1;
            TabSpecs(1).Style = {Width("10%")};
            TabSpecs(2) = TableColSpec;
            TabSpecs(2).Span = NCol-1;
            ColWidth = strcat(string(round(0.9/(NCol-1),3)*100),"%");
            TabSpecs(2).Style = {Width(ColWidth)};            
        case('��ϵ�����')
            TabSpecs(1) = TableColSpec;
            TabSpecs(1).Span = 1;
            TabSpecs(1).Style = {Width("25%")};
            TabSpecs(2) = TableColSpec;
            TabSpecs(2).Span = NCol-1;
            ColWidth = strcat(string(round(0.75/(NCol-1),3)*100),"%");
            TabSpecs(2).Style = {Width(ColWidth)};
        case('�γ̴�ɶȷ�����')
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
        case('��ҵ���(����)�ɼ���')
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
        case('��ҵҪ���ɶȽ����')
            % ��1�п��
            TabSpecs(1) = TableColSpec;
            TabSpecs(1).Span = 1;
            TabSpecs(1).Style = {Width("10%")};
            % ��2�п��
            TabSpecs(2) = TableColSpec;
            TabSpecs(2).Span = 1;
            TabSpecs(2).Style = {Width("35%")};
            % ��3�п��
            TabSpecs(3) = TableColSpec;
            TabSpecs(3).Span = 1;
            TabSpecs(3).Style = {Width("30%")}; 
            % ��4�п��
            TabSpecs(4) = TableColSpec;
            TabSpecs(4).Span = 1;
            TabSpecs(4).Style = {Width("5%")};    
            % ��5-8�п��
            TabSpecs(5) = TableColSpec;
            TabSpecs(5).Span = 4;
            TabSpecs(5).Style = {Width("5%")};
        case('��ҵҪ���������ݱ�')
            % ��1�п��
            TabSpecs(1) = TableColSpec;
            TabSpecs(1).Span = 1;
            TabSpecs(1).Style = {Width("10%")};
            % ��2�п��
            TabSpecs(2) = TableColSpec;
            TabSpecs(2).Span = 1;
            TabSpecs(2).Style = {Width("15%")};
            % ��3�п��
            TabSpecs(3) = TableColSpec;
            TabSpecs(3).Span = 1;
            TabSpecs(3).Style = {Width("15%")}; 
            % ��4-7�п��
            TabSpecs(4) = TableColSpec;
            TabSpecs(4).Span = 5;
            TabSpecs(4).Style = {Width("12%")};
        case('��ҵҪ��ָ���')
            % ��1�п��
            TabSpecs(1) = TableColSpec;
            TabSpecs(1).Span = 1;
            TabSpecs(1).Style = {Width("30%")};
            % ��2�п��
            TabSpecs(2) = TableColSpec;
            TabSpecs(2).Span = 1;
            TabSpecs(2).Style = {Width("70%")};
        case('ָ���֧�ſγ��б�')
            % ��1��ָ�����
            TabSpecs(1) = TableColSpec;
            TabSpecs(1).Span = 1;
            TabSpecs(1).Style = {Width("30%")};
            % ��2�п��
            TabSpecs(2) = TableColSpec;
            TabSpecs(2).Span = 1;
            TabSpecs(2).Style = {Width("40%")};
            % ��3�п��
            TabSpecs(3) = TableColSpec;
            TabSpecs(3).Span = 1;
            TabSpecs(3).Style = {Width("30%")}; 
        case('�γ�Ŀ�����ҵҪ���ϵ��')
            % ��1�п��
            TabSpecs(1) = TableColSpec;
            TabSpecs(1).Span = 1;
            TabSpecs(1).Style = {Width("30%")};
            % ��2�п��
            TabSpecs(2) = TableColSpec;
            TabSpecs(2).Span = 1;
            TabSpecs(2).Style = {Width("35%")};
            % ��3�п��
            TabSpecs(3) = TableColSpec;
            TabSpecs(3).Span = 1;
            TabSpecs(3).Style = {Width("35%")};
        case('���γ����۷�ʽ��Ȩ��һ����')
            % ��1�п��
            TabSpecs(1) = TableColSpec;
            TabSpecs(1).Span = 1;
            TabSpecs(1).Style = {Width("25%")};
            % ��2�п��
            TabSpecs(2) = TableColSpec;
            TabSpecs(2).Span = 1;
            TabSpecs(2).Style = {Width([num2str(80/(NCol-1)),'%'])};
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

end