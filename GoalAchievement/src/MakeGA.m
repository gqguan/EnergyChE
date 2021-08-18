function prompt = MakeGA(saveData,figPath)
% 生成课程目标达成度分析报告
%
% by Dr. Guan Guoqiang @ SCUT on 2021/8/12

% 输入参数检查
cc = saveData.Data.cc;
tr = saveData.Data.tr;
text = saveData.Data.text;

if ismcc || isdeployed
    makeDOMCompilable()
end
import mlreportgen.dom.*; 
% 中文字体样式设置
headFont = FontFamily;
headFont.FamilyName = 'Arial';
headFont.EastAsiaFamilyName = '黑体';
bodyFont = FontFamily;
bodyFont.FamilyName = 'Times New Roman';
bodyFont.EastAsiaFamilyName = '宋体';
% 定义段落属性
headStyle = {HAlign('center'),FontSize('18pt'),headFont};
% 定义表属性
tableStyle = {Width('100%'), Border('solid'), ColSep('solid'), RowSep('solid')};
bodyStyle = {VAlign('middle'), OuterMargin('0pt', '0pt', '0pt', '0pt'), ...
    InnerMargin('2pt', '2pt', '2pt', '2pt'), FontSize('12pt'),bodyFont};
mainHeaderRowStyle = {HAlign('center'), VAlign('middle'), InnerMargin('2pt', '2pt', '2pt', '2pt'), ...
    OuterMargin('0pt', '0pt', '0pt', '0pt'), BackgroundColor('lightgrey'), headFont};

fileName = sprintf('《%s》课程目标达成度分析报告（%s）.docx',cc.Title,tr.Class);
[file1,filePath] = uiputfile(fileName,'保存达成度分析报告');
doc = Document([filePath,file1],'docx');
% default page layout is portrait
portraitPLO = DOCXPageLayout;
portraitPageSize = portraitPLO.PageSize;
% define landscape layout
landscapePLO = DOCXPageLayout;
landscapePLO.PageSize.Orientation = "landscape";
landscapePLO.PageSize.Height = portraitPageSize.Width;
landscapePLO.PageSize.Width = portraitPageSize.Height;
% 横向纸面布局
append(doc,clone(landscapePLO));
% 标题
p = Paragraph(sprintf('《%s》课程目标达成度分析报告',cc.Title));
p.Style = headStyle;
append(doc,p);
% 表宽设置
NCol = 9;
t = Table(NCol);
t.Style = [t.Style,tableStyle];
% 设定表中各列宽度
Grps = TableColSpecGroup;
Grps.Span = NCol;
% 第1-2列宽度
TabSpecs(1) = TableColSpec;
TabSpecs(1).Span = 2;
TabSpecs(1).Style = {Width("25%")};
% 第3列宽度
TabSpecs(2) = TableColSpec;
TabSpecs(2).Span = 1;
TabSpecs(2).Style = {Width("13%")};
% 第4列宽度
TabSpecs(3) = TableColSpec;
TabSpecs(3).Span = 1;
TabSpecs(3).Style = {Width("7%")};
% 第5-9列（合计6列）
TabSpecs(4) = TableColSpec;
TabSpecs(4).Span = 5;
TabSpecs(4).Style = {Width("6%")}; 
Grps.ColSpecs = TabSpecs;
t.ColSpecGroups = [t.ColSpecGroups,Grps];
% 表头（课程信息第1行）
r = TableRow;
r.Style = [r.Style,mainHeaderRowStyle];
te = TableEntry('课程名称');
append(r,te);
te = TableEntry(cc.Title);
te.Style = bodyStyle;
append(r,te);
te = TableEntry('课程代码');
append(r,te);
te = TableEntry(cc.Code);
te.Style = bodyStyle;
te.ColSpan = 6;
append(r,te);
append(t,r);
% 表头（课程信息第2行）
r = TableRow;
r.Style = [r.Style,mainHeaderRowStyle];
te = TableEntry('学生专业');
append(r,te);
te = TableEntry('能源化学工程');
te.Style = bodyStyle;
append(r,te);
te = TableEntry('学生学院');
append(r,te);
te = TableEntry('化学与化工学院');
te.Style = bodyStyle;
te.ColSpan = 6;
append(r,te);
append(t,r);
% 表头
r = TableRow;
r.Style = [r.Style,mainHeaderRowStyle];
te = TableEntry('毕业要求指标点（观测点）');
te.RowSpan = 2;
append(r,te);
te = TableEntry('课程教学目标');
te.RowSpan = 2;
append(r,te);
te = TableEntry('达成评价途径');
te.ColSpan = 2;
append(r,te);
te = TableEntry('实际得分');
te.ColSpan = 2;
append(r,te);
te = TableEntry('相对得分');
te.ColSpan = 2;
append(r,te);
te = TableEntry('达成度');
te.RowSpan = 2;
append(r,te);
append(t,r);
r = TableRow;
r.Style = [r.Style,mainHeaderRowStyle];
te = TableEntry('打分点');
append(r,te);
te = TableEntry('评测方式');
append(r,te);
te = TableEntry('满分值');
append(r,te);
te = TableEntry('平均分');
append(r,te);
te = TableEntry('权重值');
append(r,te);
te = TableEntry('得分');
append(r,te);
append(t,r);
append(doc,t);
% 达成度分析结果数据
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
t = Tab2Worda(dat,'课程达成度分析表','课程达成度分析表',tHead);
append(doc,t);
% 达成度分析文本
NCol = 2;
t = Table(NCol);
t.Style = [t.Style,tableStyle];
r = TableRow;
r.Style = [r.Style,bodyStyle];
te = TableEntry('课程目标平均达成度');
append(r,te);
p = Paragraph(sprintf('%.4g',mean(GAValues)));
te = TableEntry(p);
te.ColSpan = 8;
append(r,te);
append(t,r);
r = TableRow;
r.Style = [r.Style,bodyStyle];
te = TableEntry('课程目标达成度分析');
append(r,te);
p = Paragraph(char(join(text)));
te = TableEntry(p);
te.ColSpan = 8;
append(r,te);
append(t,r);
append(doc,t);
% 绘图
figFile = [figPath,'GAResult.png'];
if exist(figFile,'file') == 2
    text = sprintf('%s级《%s》课程目标达成度如下图所示：',tr.Class,tr.Name);
    p = Paragraph(text);
    p.Style = bodyStyle;
    append(doc,p);
    fig = Image(figFile);
    append(doc,fig);
    prompt = sprintf('导入图片%s',figFile);
else
    prompt = sprintf('找不到图片%s',figFile);
end

% 学生成绩明细
append(doc,clone(landscapePLO));
title = Paragraph(sprintf('《%s》课程成绩单',cc.Title));
title.Style = headStyle;
append(doc,title);
tabStudents = tr.Detail(:,1:3);
tabDetails = tr.Detail(:,4:end);
tabSelected = tabDetails(:,any(o2w,2)); % 只列出支撑课程目标的打分点
rowSet = 10;
while width(tabSelected) > rowSet
    t = Table([tabStudents,tabSelected(:,1:rowSet)]);
    t.Style = [t.Style,tableStyle];
    t.Style = [t.Style,bodyStyle];
    append(doc,t);
    p = Paragraph('下表继续');
    p.Style = bodyStyle;
    append(doc,p);
    tabSelected(:,1:rowSet) = [];
end
t = Table([tabStudents,tabSelected]);
t.Style = [t.Style,tableStyle];
t.Style = [t.Style,bodyStyle];
append(doc,t);

close(doc);

prompt = sprintf('%s；生成文件%s',prompt,file1);

end

