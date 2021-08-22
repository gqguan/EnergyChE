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
if exist('figPath','var') == 0
    figPath = filePath;
end
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
TabSpecs(1).Style = {Width("15%")};
% ��3�п��
TabSpecs(2) = TableColSpec;
TabSpecs(2).Span = 1;
TabSpecs(2).Style = {Width("10%")};
% ��4�п��
TabSpecs(3) = TableColSpec;
TabSpecs(3).Span = 1;
TabSpecs(3).Style = {Width("20%")};
% ��5-9�У��ϼ�6�У�
TabSpecs(4) = TableColSpec;
TabSpecs(4).Span = 5;
TabSpecs(4).Style = {Width("8%")}; 
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
te.ColSpan = 4;
append(r,te);
te = TableEntry('������');
te.ColSpan = 2;
append(r,te);
te = TableEntry('��ɶ�');
te.RowSpan = 2;
append(r,te);
append(t,r);

r = TableRow;
r.Style = [r.Style,mainHeaderRowStyle];
te = TableEntry('���ⷽʽ');
append(r,te);
te = TableEntry('��ֵ�');
append(r,te);
te = TableEntry('Ȩ��ֵ');
append(r,te);
te = TableEntry('��ֵ');
append(r,te);
te = TableEntry('�÷�');
append(r,te);
te = TableEntry('�÷���');
append(r,te);
append(t,r);
append(doc,t);

% ��ɶȷ����������
questionPart = saveData.Data.obj2Way.Data(:,1);
o2w = cell2mat(saveData.Data.obj2Way.Data(:,2:end));
GAValues = zeros(size(o2w,2),1);
dat = cell(sum(o2w,'all'),9);
firstLetterAll = categorical(cellfun(@(x){x(1)},cellstr(tr.VarNames)));
firstLetterCat = categories(firstLetterAll);
subPoint = zeros(length(firstLetterCat),1);
w2 = zeros(1,length(firstLetterAll));
weight = cell2mat(saveData.Data.weight.Data(:,2:end));
avgSubscore = mean(tr.Detail{:,4:end});
x = mean(tr.Detail{:,4:end})./tr.SubPoints;
row129 = 1; % ��ҵҪ��ָ��㡢�γ�Ŀ�꼰��ɶȣ���1��2��9�У���λ��
for iObj = 1:size(o2w,2)
    dat{row129,1} = cc.Outcomes{iObj}; % �γ�֧�ŵı�ҵҪ��ָ���
    dat{row129,2} = cc.Objectives{iObj}; % �γ�Ŀ��
    idx1 = logical(o2w(:,iObj))'; % ָ���γ�Ŀ���ȫ��������
    row3 = row129; % ���ⷽʽ����3�У���λ��
    for iWay = 1:length(firstLetterCat)
        idx2 = (firstLetterAll == firstLetterCat{iWay}); % ѡ��ĳ���ⷽʽ��������
        idx = idx1 & idx2;
        if any(idx)
            dat{row3,3} = tr.Definition(iWay).Name; % ���ⷽʽ
            row4 = row3; % �������4�У���λ��
            row4e = row4+sum(idx)-1;
            dat(row4:row4e,4) = cellstr(tr.Descriptions(idx)); % ������˵��
            w1 = tr.SubPoints(idx)/sum(tr.SubPoints(idx));
            w2(idx) = w1*weight(iWay,iObj)/sum(weight(:,iObj),'omitnan');
            dat(row4:row4e,5) = num2cell(w2(idx)); % �������Ȩ��
            dat(row4:row4e,6) = num2cell(tr.SubPoints(idx)); % ������ķ�ֵ
            dat(row4:row4e,7) = num2cell(avgSubscore(idx)); % ƽ����
            dat(row4:row4e,8) = num2cell(x(idx)); % �÷���
            row3 = row4e+1; % �����������4�У���λ��
        else
            subPoint(iWay) = nan;
        end
    end
    dat{row129,9} = sum(w2(idx1).*x(idx1),'omitnan');
    GAValues(iObj) = dat{row129,9};
    row129 = row3; % ���µ�1��2��9�ж�λ��
end
tHead = num2cell(1:9);
t = Tab2Worda(dat,'�γ̴�ɶȷ�����','�γ̴�ɶȷ�����',tHead);

% ��ɶȷ����ı�
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

