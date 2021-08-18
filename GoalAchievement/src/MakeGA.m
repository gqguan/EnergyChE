function prompt = MakeGA(saveData,figPath)
% ���ɿγ�Ŀ���ɶȷ�������
%
% by Dr. Guan Guoqiang @ SCUT on 2021/8/12

% ����������
cc = saveData.Data.cc;
tr = saveData.Data.tr;
text = saveData.Data.text;

if ismcc || isdeployed
    makeDOMCompilable()
end
import mlreportgen.dom.*; 
% ����������ʽ����
headFont = FontFamily;
headFont.FamilyName = 'Arial';
headFont.EastAsiaFamilyName = '����';
bodyFont = FontFamily;
bodyFont.FamilyName = 'Times New Roman';
bodyFont.EastAsiaFamilyName = '����';
% �����������
headStyle = {HAlign('center'),FontSize('18pt'),headFont};
% ���������
tableStyle = {Width('100%'), Border('solid'), ColSep('solid'), RowSep('solid')};
bodyStyle = {VAlign('middle'), OuterMargin('0pt', '0pt', '0pt', '0pt'), ...
    InnerMargin('2pt', '2pt', '2pt', '2pt'), FontSize('12pt'),bodyFont};
mainHeaderRowStyle = {HAlign('center'), VAlign('middle'), InnerMargin('2pt', '2pt', '2pt', '2pt'), ...
    OuterMargin('0pt', '0pt', '0pt', '0pt'), BackgroundColor('lightgrey'), headFont};

fileName = sprintf('��%s���γ�Ŀ���ɶȷ������棨%s��.docx',cc.Title,tr.Class);
[file1,filePath] = uiputfile(fileName,'�����ɶȷ�������');
doc = Document([filePath,file1],'docx');
% default page layout is portrait
portraitPLO = DOCXPageLayout;
portraitPageSize = portraitPLO.PageSize;
% define landscape layout
landscapePLO = DOCXPageLayout;
landscapePLO.PageSize.Orientation = "landscape";
landscapePLO.PageSize.Height = portraitPageSize.Width;
landscapePLO.PageSize.Width = portraitPageSize.Height;
% ����ֽ�沼��
append(doc,clone(landscapePLO));
% ����
p = Paragraph(sprintf('��%s���γ�Ŀ���ɶȷ�������',cc.Title));
p.Style = headStyle;
append(doc,p);
% �������
NCol = 9;
t = Table(NCol);
t.Style = [t.Style,tableStyle];
% �趨���и��п��
Grps = TableColSpecGroup;
Grps.Span = NCol;
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
Grps.ColSpecs = TabSpecs;
t.ColSpecGroups = [t.ColSpecGroups,Grps];
% ��ͷ���γ���Ϣ��1�У�
r = TableRow;
r.Style = [r.Style,mainHeaderRowStyle];
te = TableEntry('�γ�����');
append(r,te);
te = TableEntry(cc.Title);
te.Style = bodyStyle;
append(r,te);
te = TableEntry('�γ̴���');
append(r,te);
te = TableEntry(cc.Code);
te.Style = bodyStyle;
te.ColSpan = 6;
append(r,te);
append(t,r);
% ��ͷ���γ���Ϣ��2�У�
r = TableRow;
r.Style = [r.Style,mainHeaderRowStyle];
te = TableEntry('ѧ��רҵ');
append(r,te);
te = TableEntry('��Դ��ѧ����');
te.Style = bodyStyle;
append(r,te);
te = TableEntry('ѧ��ѧԺ');
append(r,te);
te = TableEntry('��ѧ�뻯��ѧԺ');
te.Style = bodyStyle;
te.ColSpan = 6;
append(r,te);
append(t,r);
% ��ͷ
r = TableRow;
r.Style = [r.Style,mainHeaderRowStyle];
te = TableEntry('��ҵҪ��ָ��㣨�۲�㣩');
te.RowSpan = 2;
append(r,te);
te = TableEntry('�γ̽�ѧĿ��');
te.RowSpan = 2;
append(r,te);
te = TableEntry('�������;��');
te.ColSpan = 2;
append(r,te);
te = TableEntry('ʵ�ʵ÷�');
te.ColSpan = 2;
append(r,te);
te = TableEntry('��Ե÷�');
te.ColSpan = 2;
append(r,te);
te = TableEntry('��ɶ�');
te.RowSpan = 2;
append(r,te);
append(t,r);
r = TableRow;
r.Style = [r.Style,mainHeaderRowStyle];
te = TableEntry('��ֵ�');
append(r,te);
te = TableEntry('���ⷽʽ');
append(r,te);
te = TableEntry('����ֵ');
append(r,te);
te = TableEntry('ƽ����');
append(r,te);
te = TableEntry('Ȩ��ֵ');
append(r,te);
te = TableEntry('�÷�');
append(r,te);
append(t,r);
append(doc,t);
% ��ɶȷ����������
questionPart = saveData.Data.obj2Way.Data(:,1);
o2w = cell2mat(saveData.Data.obj2Way.Data(:,2:end));
GAValues = zeros(size(o2w,2),1);
dat = cell(sum(o2w,'all'),9);
iRow = 1;
for iObj = 1:size(o2w,2)
    row1 = iRow;
    dat{iRow,1} = cc.Outcomes{iObj};
    dat{iRow,2} = cc.Objectives{iObj};
%     EWLetterList = cellfun(@(x)x(1),questionPart(o2w(:,iObj)));
    idx = find(o2w(:,iObj));
    j0 = 0;
    for iPart = 1:length(idx)
        strPart = questionPart{idx(iPart)};
        dat{iRow,3} = strPart;
        j = char(strPart(1))-64;
        if j ~= j0
            dat{iRow,4} = tr.Definition(j).Name;
            j0 = j;
        end
        dat{iRow,5} = tr.SubPoints(idx(iPart));
        var = tr.VarNames(idx(iPart));
        dat{iRow,6} = round(mean(tr.Detail.(var)),3);
        dat{iRow,7} = round(dat{iRow,5}/sum(tr.SubPoints(idx)),3);
        dat{iRow,8} = round(dat{iRow,6}/dat{iRow,5}*dat{iRow,7},4);
        iRow = iRow+1;
    end
    GAValues(iObj) = sum(cell2mat(dat(row1:iRow-1,8)));
    dat{row1,9} = sprintf('%.3f',GAValues(iObj));
end
tHead = num2cell(1:9);
t = Tab2Worda(dat,'�γ̴�ɶȷ�����','�γ̴�ɶȷ�����',tHead);
append(doc,t);
% ��ɶȷ����ı�
NCol = 2;
t = Table(NCol);
t.Style = [t.Style,tableStyle];
r = TableRow;
r.Style = [r.Style,bodyStyle];
te = TableEntry('�γ�Ŀ��ƽ����ɶ�');
append(r,te);
p = Paragraph(sprintf('%.4g',mean(GAValues)));
te = TableEntry(p);
te.ColSpan = 8;
append(r,te);
append(t,r);
r = TableRow;
r.Style = [r.Style,bodyStyle];
te = TableEntry('�γ�Ŀ���ɶȷ���');
append(r,te);
p = Paragraph(char(join(text)));
te = TableEntry(p);
te.ColSpan = 8;
append(r,te);
append(t,r);
append(doc,t);
% ��ͼ
figFile = [figPath,'GAResult.png'];
if exist(figFile,'file') == 2
    text = sprintf('%s����%s���γ�Ŀ���ɶ�����ͼ��ʾ��',tr.Class,tr.Name);
    p = Paragraph(text);
    p.Style = bodyStyle;
    append(doc,p);
    fig = Image(figFile);
    append(doc,fig);
    prompt = sprintf('����ͼƬ%s',figFile);
else
    prompt = sprintf('�Ҳ���ͼƬ%s',figFile);
end

% ѧ���ɼ���ϸ
append(doc,clone(landscapePLO));
title = Paragraph(sprintf('��%s���γ̳ɼ���',cc.Title));
title.Style = headStyle;
append(doc,title);
tabStudents = tr.Detail(:,1:3);
tabDetails = tr.Detail(:,4:end);
tabSelected = tabDetails(:,any(o2w,2)); % ֻ�г�֧�ſγ�Ŀ��Ĵ�ֵ�
rowSet = 10;
while width(tabSelected) > rowSet
    t = Table([tabStudents,tabSelected(:,1:rowSet)]);
    t.Style = [t.Style,tableStyle];
    t.Style = [t.Style,bodyStyle];
    append(doc,t);
    p = Paragraph('�±����');
    p.Style = bodyStyle;
    append(doc,p);
    tabSelected(:,1:rowSet) = [];
end
t = Table([tabStudents,tabSelected]);
t.Style = [t.Style,tableStyle];
t.Style = [t.Style,bodyStyle];
append(doc,t);

close(doc);

prompt = sprintf('%s�������ļ�%s',prompt,file1);

end

