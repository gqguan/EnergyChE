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
TabSpecs(1).Style = {Width("15%")};
% 第3列宽度
TabSpecs(2) = TableColSpec;
TabSpecs(2).Span = 1;
TabSpecs(2).Style = {Width("10%")};
% 第4列宽度
TabSpecs(3) = TableColSpec;
TabSpecs(3).Span = 1;
TabSpecs(3).Style = {Width("20%")};
% 第5-9列（合计6列）
TabSpecs(4) = TableColSpec;
TabSpecs(4).Span = 5;
TabSpecs(4).Style = {Width("8%")}; 
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
te.ColSpan = 4;
append(r,te);
te = TableEntry('评测结果');
te.ColSpan = 2;
append(r,te);
te = TableEntry('达成度');
te.RowSpan = 2;
append(r,te);
append(t,r);

r = TableRow;
r.Style = [r.Style,mainHeaderRowStyle];
te = TableEntry('评测方式');
append(r,te);
te = TableEntry('打分点');
append(r,te);
te = TableEntry('权重值');
append(r,te);
te = TableEntry('分值');
append(r,te);
te = TableEntry('得分');
append(r,te);
te = TableEntry('得分率');
append(r,te);
append(t,r);
append(doc,t);

% 达成度分析结果数据
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
row129 = 1; % 毕业要求指标点、课程目标及达成度（第1、2和9列）定位行
for iObj = 1:size(o2w,2)
    dat{row129,1} = cc.Outcomes{iObj}; % 课程支撑的毕业要求指标点
    dat{row129,2} = cc.Objectives{iObj}; % 课程目标
    idx1 = logical(o2w(:,iObj))'; % 指定课程目标的全部评测项
    row3 = row129; % 评测方式（第3列）定位行
    for iWay = 1:length(firstLetterCat)
        idx2 = (firstLetterAll == firstLetterCat{iWay}); % 选定某评测方式中评测项
        idx = idx1 & idx2;
        if any(idx)
            dat{row3,3} = tr.Definition(iWay).Name; % 评测方式
            row4 = row3; % 评测项（第4列）定位行
            row4e = row4+sum(idx)-1;
            dat(row4:row4e,4) = cellstr(tr.Descriptions(idx)); % 评测项说明
            w1 = tr.SubPoints(idx)/sum(tr.SubPoints(idx));
            w2(idx) = w1*weight(iWay,iObj)/sum(weight(:,iObj),'omitnan');
            dat(row4:row4e,5) = num2cell(w2(idx)); % 评测项的权重
            dat(row4:row4e,6) = num2cell(tr.SubPoints(idx)); % 评测项的分值
            dat(row4:row4e,7) = num2cell(avgSubscore(idx)); % 平均分
            dat(row4:row4e,8) = num2cell(x(idx)); % 得分率
            row3 = row4e+1; % 更新评测项（第4列）定位行
        else
            subPoint(iWay) = nan;
        end
    end
    dat{row129,9} = sum(w2(idx1).*x(idx1),'omitnan');
    GAValues(iObj) = dat{row129,9};
    row129 = row3; % 更新第1、2和9列定位行
end
tHead = num2cell(1:9);
t = Tab2Worda(dat,'课程达成度分析表','课程达成度分析表',tHead);

% 达成度分析文本
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

