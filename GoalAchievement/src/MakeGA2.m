function prompt = MakeGA2(saveData,figPath)
% 生成课程目标达成度分析报告
%
% by Dr. Guan Guoqiang @ SCUT on 2022/12/9

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
% default page layout is A4 portrait
portraitPLO = DOCXPageLayout;
portraitPLO.PageSize.Height = '297mm';
portraitPLO.PageSize.Width = '210mm';
append(doc,portraitPLO);
% 封面页
logo = Image([figPath,'logo.png']);
logo.Style = {HAlign('center'),ScaleToFit(1)};
append(doc,logo);
append(doc,LineBreak);
% 标题
p1 = Paragraph('化学与化工学院');
t1Style = [p1.Style,{HAlign('center'),FontSize('32pt'),LineSpacing(1),headFont}];
p1.Style = t1Style;
append(doc,p1);
append(doc,LineBreak);
p1 = Paragraph('课程目标达成情况评价报告');
p1.Style = t1Style;
append(doc,p1)
append(doc,LineBreak);
append(doc,LineBreak);
% 封面信息
t1 = Table(2);
t1Style = {Width('12cm'), Border('none'), ColSep('none'), RowSep('none'), ...
    FontSize('24pt'), HAlign('center')};
t1.Style = [t1.Style,t1Style];
bottomBorderStyle = Border();
bottomBorderStyle.BottomStyle = "single";
Grps = TableColSpecGroup;
Grps.Span = 2;
TabSpecs(1) = TableColSpec;
TabSpecs(1).Span = 1;
TabSpecs(1).Style = {Width("4cm")};
Grps.ColSpecs = TabSpecs;
t1.ColSpecGroups = [t1.ColSpecGroups,Grps];
t1Heads = {'课程名称','负责教师','任课教师','开课学期','学生专业','学生班级'};
t1Contents = {cc.Title,tr.Teacher,tr.Teacher,'','能源化学工程',tr.Class};
for i = 1:length(t1Heads)
    r1 = TableRow;
    te = TableEntry(t1Heads{i});
    headerStyle = {HAlign('justify'), InnerMargin('2pt', '2pt', '2pt', '2pt'), ...
    OuterMargin('0pt', '0pt', '0pt', '0pt'), headFont};
    te.Style = [te.Style,headerStyle];
    append(r1,te);
    te = TableEntry(t1Contents{i});
    te.Style = {HAlign('center'),InnerMargin('2pt', '2pt', '2pt', '2pt'),...
        OuterMargin('0pt', '0pt', '0pt', '0pt'),FontSize('24pt'),bottomBorderStyle,bodyFont};
    append(r1,te);
    append(t1,r1);
end
append(doc,t1);
for iLn = 1:3
    append(doc,LineBreak);
end
% 日期
p = Paragraph(datestr(saveData.Datetime,'YYYY年mm月DD日'));
p.Style = [p.Style,{HAlign('center'),FontSize('18pt'),bodyFont}];
append(doc,p);
append(doc,PageBreak());
% 生成报告正文第1部分
h1 = Heading1('一、课程基本信息');
h1.Style = [h1.Style,{HAlign('left'),FontSize('14pt'),headFont}];
h1Style = h1.Style;
append(doc,h1);
% 课程基本信息表
t2 = Table(4);
t2Style = {Width('14cm'),RowHeight('16pt'),FontSize('12pt'),...
    HAlign('center'),Border('solid'),ColSep('solid'),RowSep('solid')};
t2.Style = [t2.Style,t2Style];
Grps = TableColSpecGroup;
Grps.Span = 4;
TabSpecs(1) = TableColSpec;
TabSpecs(1).Span = 1;
TabSpecs(1).Style = {Width("15%")};
TabSpecs(2) = TableColSpec;
TabSpecs(2).Span = 1;
TabSpecs(2).Style = {Width("35%")};
TabSpecs(3) = TableColSpec;
TabSpecs(3).Span = 1;
TabSpecs(3).Style = {Width("15%")};
TabSpecs(4) = TableColSpec;
TabSpecs(4).Span = 1;
TabSpecs(4).Style = {Width("35%")};
Grps.ColSpecs = TabSpecs;
t2.ColSpecGroups = [t2.ColSpecGroups,Grps];
t2Heads = {'课程名称','课程代码';'课程类型','课程学分';'负责教师','任课教师';...
    '学生学院','学生专业';'学生班级','学生人数';'上课时间','上课地点'};
t2Contents = {cc.Title,cc.Code;cc.Category,cc.Credits;tr.Teacher,tr.Teacher;...
    cc.Institute,cc.ProgramOriented;tr.Class,string(height(tr.Detail));'',''};
for i = 1:6 % 行数
    r2 = TableRow;
    for j = 1:2 % 两栏
        te = TableEntry(t2Heads{i,j});
        headerStyle = {HAlign('left'), VAlign('middle'), ...
            InnerMargin('2pt', '2pt', '2pt', '2pt'), ...
            OuterMargin('0pt', '0pt', '0pt', '0pt'), headFont};
        te.Style = [te.Style,headerStyle];
        append(r2,te);
        te = TableEntry(t2Contents{i,j});
        te.Style = {HAlign('center'),bodyFont};
        append(r2,te);
    end
    append(t2,r2);
end
append(doc,t2);
% 生成报告正文第2部分
h1 = Heading1('二、课程目标与毕业要求及其指标点的对应关系');
h1.Style = h1Style;
append(doc,h1);
p = Paragraph(TextMaker(cc,tr,[],2));
pStyle = [p.Style,...
    {HAlign('justify'),FontSize('12pt'),FirstLineIndent('24pt'),bodyFont}];
p.Style = pStyle;
append(doc,p);
% 生成“课程目标与毕业要求关系表”
idx = fix(str2double(cellfun(@(x)regexp(x,'\d*\.?\d*','match'),cc.Outcomes))); % 毕业要求内容索引
load([figPath,'database.mat'],'db_GradRequires')
t3Contents = [cellfun(@(i)sprintf('毕业要求%d（%s）：%s',i,db_GradRequires{i,:}),...
    num2cell(idx),'UniformOutput',false),... % 从db_GradRequires中获取本课程支撑的毕业要求并合并为cell字符串数组
    cc.Outcomes,cc.Objectives];
% 置空重复单元
blankIdx = true(size(idx));
[~,ia] = unique(idx); % 找到不重复的元素
blankIdx(ia) = false; blankIdx = find(blankIdx);
for i = 1:length(blankIdx) % 若无重复元素则for循环不会执行
    t3Contents{blankIdx(i),1} = '';
end
t3Heads = {'毕业要求','指标点','课程目标'};
t3 = Tab2Worda(t3Contents,'课程目标与毕业要求关系表','',t3Heads);
t3.Style = [t3.Style,{FontSize('12pt')}];
append(doc,t3)
append(doc,LineBreak);
% 生成报告正文第3部分
h1 = Heading1('三、评价标准');
h1.Style = h1Style;
append(doc,h1);
for i = 1:length(saveData.Data.criteria)
    p = Paragraph(saveData.Data.criteria{i});
    p.Style = pStyle;
    append(doc,p);
end
append(doc,LineBreak);
% 生成报告正文第4部分
h1 = Heading1('四、课程目标的评价依据及评价方法');
h1.Style = h1Style;
append(doc,h1);
texts = '本课程以培养学生能力为目标，按照课程教学大纲的要求，围绕课程目标进行教学设计并实施教学';
wayStr = strjoin(saveData.Data.weight.Data(:,1),'、');
texts = sprintf('%s。%s年度课程教学采用%s%d种方式评估课程教学质量',...
    texts,tr.Class,wayStr,size(saveData.Data.weight.Data,1));
texts = sprintf('%s，其权重如下表所列：',texts);
p = Paragraph(texts);
p.Style = pStyle;
append(doc,p);
t4 = Tab2Worda(saveData.Data.weight.Data,'各课程评价方式的权重一览表','',...
    saveData.Data.weight.ColumnName');
t4.Style = [t4.Style,{FontSize('12pt')}];
append(doc,t4);
texts = '在每种课程评价方式中又分别设立了若干评分点，各评分点与课程目标的对应关系及达成度计算方法可参照《化学与化工学院本科专业课程目标达成情况评价办法》';
texts = sprintf('%s，具体过程详见如附表1所列。',texts);
p = Paragraph(texts);
p.Style = pStyle;
append(doc,p);
for i = 1:length(saveData.Data.basis)
    p = Paragraph(saveData.Data.basis{i});
    p.Style = pStyle;
    append(doc,p);
end
append(doc,LineBreak);
% 生成报告正文第5部分
h1 = Heading1('五、评价结果及分析');
h1.Style = h1Style;
append(doc,h1);
h2 = Heading2('5.1 当前课程教学目标达成情况');
h2Style = [h2.Style,{HAlign('left'),FontSize('12pt'),headFont}];
h2.Style = h2Style;
append(doc,h2);
p = Paragraph('课程目标达成评价结果采用如下箱式图表示：');
p.Style = pStyle;
append(doc,p);
img1 = Image([figPath,'GADetail.png']);
img1.Style = {ScaleToFit};
append(doc,img1);
append(doc,LineBreak);
p = Paragraph(TextMaker(cc,tr,cell2mat(saveData.Data.listObj.Data(:,3))));
p.Style = pStyle;
append(doc,p);
append(doc,LineBreak);
h2 = Heading2('5.2 课程教学持续改进情况');
h2.Style = h2Style;
append(doc,h2);
p = Paragraph(TextMaker(cc,tr,saveData.Data.GAResult,3));
p.Style = pStyle;
append(doc,p);
TextBoxData2Paragraph(doc,saveData.Data.text,pStyle);
img2 = Image([figPath,'GAResult.png']);
img2.Style = {ScaleToFit};
append(doc,img2);
append(doc,PageBreak);
% 生成封底
h1 = Heading1('六、审核意见');
h1.Style = h1Style;
append(doc,h1);
tb = Table(2);
tbStyle = {Width('100%'),RowHeight('9cm'),FontSize('12pt'),...
    HAlign('center'),Border('solid'),ColSep('solid'),RowSep('solid')};
tb.Style = [tb.Style,tbStyle];
Grps = TableColSpecGroup;
Grps.Span = 2;
TabSpecs(1) = TableColSpec;
TabSpecs(1).Span = 1;
TabSpecs(1).Style = {Width("5%")};
TabSpecs(2) = TableColSpec;
TabSpecs(2).Span = 1;
TabSpecs(2).Style = {Width("95%")};
Grps.ColSpecs = TabSpecs;
tb.ColSpecGroups = [tb.ColSpecGroups,Grps];
tbHeight = {'6cm','6cm','8.5cm'};
tbLineIdent = {'8cm','8cm','4cm'};
tbContent = {'课程组审核意见','课程负责人签字：';...
             '系审核意见','系主任签字：';...
             '学院教学指导委员会审核意见','学院教学指导委员会主任签字：'};
for i = 1:3
    r = TableRow;
    r.Style = [r.Style,{Height(tbHeight{i})}];
    te = TableEntry(tbContent{i,1});
    te.Style = [headerStyle,{HAlign('center')}];
    append(r,te);
    te = TableEntry(Paragraph(' '));
    for j = 1:5
        append(te,Paragraph(' '));
    end
    p = Paragraph(tbContent{i,2});
    p.Style = [pStyle,{FirstLineIndent(tbLineIdent{i})}];
    append(te,p);
    p = Paragraph('   年      月      日');
    p.Style = [pStyle,{FirstLineIndent('12cm')}];
    append(te,p);
    append(r,te);
    append(tb,r);
end
append(doc,tb);

% define landscape layout
landscapePLO = DOCXPageLayout;
landscapePLO.PageSize.Orientation = "landscape";
landscapePLO.PageSize.Height = portraitPLO.PageSize.Width;
landscapePLO.PageSize.Width = portraitPLO.PageSize.Height;
% 横向纸面布局
append(doc,clone(landscapePLO));
% 标题
h1 = Heading1('附件：');
h1.Style = h1Style;
append(doc,h1)
p = Paragraph(sprintf('附表1：《%s》课程目标达成度分析明细表',cc.Title));
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
scores = saveData.Data.tr.Detail{:,4:end};
scores(any(isnan(scores),2),:) = []; % 删除成绩单中有NaN的记录
avgSubscore = mean(scores);
% avgSubscore = mean(tr.Detail{:,4:end},'omitnan');
x = avgSubscore./tr.SubPoints;
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
            dat(row4:row4e,4) = cellstr(strcat(tr.VarNames(idx),"：",tr.Descriptions(idx))); % 评测项说明
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
% 
% % 绘图
% figFile = [figPath,'GAResult.png'];
% if exist(figFile,'file') == 2
%     text = sprintf('%s级《%s》课程目标达成度如下图所示：',tr.Class,tr.Name);
%     p = Paragraph(text);
%     p.Style = bodyStyle;
%     append(doc,p);
%     fig = Image(figFile);
%     append(doc,fig);
%     prompt = sprintf('导入图片%s',figFile);
% else
%     prompt = sprintf('找不到图片%s',figFile);
% end

% 学生成绩明细
append(doc,clone(landscapePLO));
title = Paragraph(sprintf('附表2：《%s》课程成绩单',cc.Title));
title.Style = headStyle;
append(doc,title);
tabStudents = tr.Detail(:,1:3);
tabDetails = TabNum2Str(tr.Detail(:,4:end));
tabSelected = tabDetails(:,any(o2w,2)); % 只列出支撑课程目标的打分点
colSet = 10;
while width(tabSelected) > colSet
    t = Table([tabStudents,tabSelected(:,1:colSet)]);
    % 设定表中各列宽度
    Grps = TableColSpecGroup;
    Grps.Span = 13;
    % 第1列宽度
    TabSpecs(1) = TableColSpec;
    TabSpecs(1).Span = 1;
    TabSpecs(1).Style = {Width("21%")};
    % 第2列宽度
    TabSpecs(2) = TableColSpec;
    TabSpecs(2).Span = 1;
    TabSpecs(2).Style = {Width("10%")};
    % 第3列宽度
    TabSpecs(3) = TableColSpec;
    TabSpecs(3).Span = 1;
    TabSpecs(3).Style = {Width("10%")};
    % 第4-13列（合计10列）
    TabSpecs(4) = TableColSpec;
    TabSpecs(4).Span = 9;
    TabSpecs(4).Style = {Width("6.5%")}; 
    Grps.ColSpecs = TabSpecs;
    t.ColSpecGroups = Grps;
    t.Style = [t.Style,tableStyle];
    t.Style = [t.Style,bodyStyle];
    append(doc,t);
    p = Paragraph('下表继续');
    p.Style = bodyStyle;
    append(doc,p);
    tabSelected(:,1:colSet) = [];
end
t = Table([tabStudents,tabSelected]);
% 设定表中各列宽度
Grps = TableColSpecGroup;
Grps.Span = width([tabStudents,tabSelected]);
% 第1列宽度
TabSpecs(1) = TableColSpec;
TabSpecs(1).Span = 1;
TabSpecs(1).Style = {Width("21%")};
% 第2列宽度
TabSpecs(2) = TableColSpec;
TabSpecs(2).Span = 1;
TabSpecs(2).Style = {Width("10%")};
% 第3列宽度
TabSpecs(3) = TableColSpec;
TabSpecs(3).Span = 1;
TabSpecs(3).Style = {Width("10%")};
% 其余列
TabSpecs(4) = TableColSpec;
TabSpecs(4).Span = Grps.Span-3;
strWidth = sprintf('"%.1f%%"',floor(59/(Grps.Span-3)*10)/10);
TabSpecs(4).Style = {Width(strWidth)}; 
Grps.ColSpecs = TabSpecs;
t.ColSpecGroups = Grps;
t.Style = [t.Style,tableStyle];
t.Style = [t.Style,bodyStyle];
append(doc,t);

close(doc);

prompt = sprintf('生成文件%s',file1);

end

