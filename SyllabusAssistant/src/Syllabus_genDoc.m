%% 将对象cc转化为教纲docx文件
%
% by Dr. Guan Guoqiang @ SCUT on 2021/7/26
function [status] = Syllabus_genDoc(cc,flag) 

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

% 检查输入参数 
if nargin == 2
    if isequal(class(cc),'Course')
        doc = Document(cc.FilePath,'docx');
        % default page layout is portrait
        portraitPLO = DOCXPageLayout;
        portraitPageSize = portraitPLO.PageSize;
        % define landscape layout
        landscapePLO = DOCXPageLayout;
        landscapePLO.PageSize.Orientation = "landscape";
        landscapePLO.PageSize.Height = portraitPageSize.Width;
        landscapePLO.PageSize.Width = portraitPageSize.Height;
        % 教纲标题
        p = Paragraph(sprintf('《%s》教学大纲',cc.Title));
        p.Style = headStyle;
        append(doc, p);
        % 教纲内容列表
        NCol = 2; % 内容列表为2列
        t = Table(NCol);
        t.Style = [t.Style tableStyle];
        % 设定表中各列宽度
        Grps = TableColSpecGroup;
        Grps.Span = NCol;
        TabSpecs(1) = TableColSpec;
        TabSpecs(1).Span = 1;
        TabSpecs(1).Style = {Width("15%")};
        TabSpecs(2) = TableColSpec;
        TabSpecs(2).Span = 1;
        TabSpecs(2).Style = {Width("85%")};        
        Grps.ColSpecs = TabSpecs;
        t.ColSpecGroups = [t.ColSpecGroups,Grps];

        % 第1-11行
        % 教纲内容胞矩阵
        c = cell(11,2);
        if cc.CompulsoryOrNot
            textObj = "必修";
        else
            textObj = "选修";
        end
        c(:,1) = {'课程代码';'课程名称';'英文名称';'课程类别';'课程性质';...
            '课程时间';'学分';'开课学期';'开课单位';'适用专业';'授课语言'};
        c(:,2) = {cc.Code;cc.Title;'';cc.Category;textObj;cc.ClassHour;...
            cc.Credits;cc.Semester;'化学与化工学院';'能源化学工程';cc.Language};
        for iRow = 1:11
            r = TableRow;
            r.Style = [r.Style,bodyStyle];
            te = TableEntry(c{iRow,1});
            append(r,te);
            te = TableEntry(c{iRow,2});
            append(r,te);
            append(t,r);
        end
        
        r = TableRow;
        r.Style = [r.Style,bodyStyle];
        te = TableEntry('先修课程');
        append(r,te);
        te = TableEntry(string(join(cc.Prerequisites)));
        append(r,te);
        append(t,r); 
        
        r = TableRow;
        r.Style = [r.Style,bodyStyle];
        te = TableEntry('课程对毕业要求的支撑');
        append(r,te);
        id_outcome = cell(length(cc.Outcomes),1);
        te = TableEntry;
        for i = 1:length(cc.Outcomes)
            append(te,Paragraph(cc.Outcomes{i}));
            id_outcome(i) = regexp(cc.Outcomes{i},'№\d*.\d','match');
        end
        append(r,te);
        append(t,r); 
        
        r = TableRow;
        r.Style = [r.Style,bodyStyle];
        te = TableEntry('课程培养学生的能力（教学目标）');
        append(r,te);
        if isempty(cc.Objectives)
            cc.Objectives = cellstr(string(1:length(cc.Outcomes)));
        end
        id_objective = cell(length(cc.Objectives),1);
        te = TableEntry;
        for i = 1:length(cc.Objectives)
            append(te,Paragraph(cc.Objectives{i}));
            id_objective(i) = {sprintf('[o%d]',i)};
        end
        % 课程目标与毕业要求指标点的关系矩阵
        append(te,Paragraph("课程目标与毕业要求的支撑关系如下表所列："));
        ctab1 = cell(length(id_outcome)+1,length(id_objective)+1);
        ctab1{1,1} = '毕业要求指标点';
        ctab1(1,2:end) = id_objective;
        ctab1(2:end,1) = id_outcome;
        ctab1(2:end,2:end) = num2cell(eye(length(id_outcome)));
        t1 = Tab2Worda(ctab1(2:end,:),'关系矩阵表','关系矩阵表',ctab1(1,:));
        append(te,t1);
        append(r,te);
        append(t,r); 
        
        r = TableRow;
        r.Style = [r.Style,bodyStyle];
        te = TableEntry('课程简介');
        append(r,te);
        te = TableEntry;
        for i = 1:length(cc.Description)
            append(te,Paragraph(cc.Description{i}));
        end
        append(r,te);
        append(t,r); 
        
        switch cc.Category
            case('集中实践教学')
                r = TableRow;
                r.Style = [r.Style,bodyStyle];
                te = TableEntry('教学内容');
                append(r,te);
                te = TableEntry;
                for i = 1:length(cc.Content)
                    append(te,Paragraph(cc.Content{i}));
                end
                append(r,te);
                append(t,r); 
                %
                r = TableRow;
                r.Style = [r.Style,bodyStyle];
                te = TableEntry('实习方式');
                append(r,te);
                te = TableEntry;
                for i = 1:length(cc.ExpTeach)
                    append(te,Paragraph(cc.ExpTeach{i}));
                end
                append(r,te);
                append(t,r); 
                %
                r = TableRow;
                r.Style = [r.Style,bodyStyle];
                te = TableEntry('实习地点');
                append(r,te);
                te = TableEntry;
                for i = 1:length(cc.TeachMethod)
                    append(te,Paragraph(cc.TeachMethod{i}));
                end
                append(r,te);
                append(t,r);
            otherwise
                if ~isempty(regexp(cc.Title,'实验','once'))
                    r = TableRow;
                    r.Style = [r.Style,bodyStyle];
                    te = TableEntry('实验教学（包括上机学时、实验学时、实践学时）');
                    append(r,te);
                    te = TableEntry;
                    for i = 1:length(cc.ExpTeach)
                        append(te,Paragraph(cc.ExpTeach{i}));
                    end
                    append(r,te);
                    append(t,r); 
                    %
                    r = TableRow;
                    r.Style = [r.Style,bodyStyle];
                    te = TableEntry('教学方法');
                    append(r,te);
                    te = TableEntry;
                    for i = 1:length(cc.TeachMethod)
                        append(te,Paragraph(cc.TeachMethod{i}));
                    end
                    append(r,te);
                    append(t,r);
                else
                    r = TableRow;
                    r.Style = [r.Style,bodyStyle];
                    te = TableEntry('教学内容与学时分配');
                    append(r,te);
                    te = TableEntry;
                    for i = 1:length(cc.Content)
                        append(te,Paragraph(cc.Content{i}));
                    end
                    append(r,te);
                    append(t,r); 
                    %
                    r = TableRow;
                    r.Style = [r.Style,bodyStyle];
                    te = TableEntry('实验教学（包括上机学时、实验学时、实践学时）');
                    append(r,te);
                    te = TableEntry;
                    for i = 1:length(cc.ExpTeach)
                        append(te,Paragraph(cc.ExpTeach{i}));
                    end
                    append(r,te);
                    append(t,r); 
                    %
                    r = TableRow;
                    r.Style = [r.Style,bodyStyle];
                    te = TableEntry('教学方法');
                    append(r,te);
                    te = TableEntry;
                    for i = 1:length(cc.TeachMethod)
                        append(te,Paragraph(cc.TeachMethod{i}));
                    end
                    append(r,te);
                    append(t,r);
                end
        end
      
        r = TableRow;
        r.Style = [r.Style,bodyStyle];
        te = TableEntry('考核方式');
        append(r,te);
        te = TableEntry;
        for i = 1:length(cc.ExamMethod)
            append(te,Paragraph(cc.ExamMethod{i}));
        end
        if ~isempty(cc.Benchmark)
            append(te,Paragraph("课程目标评价标准如下表所列："));
            t2head = {'课程目标', '优秀（>0.90）', '良好（0.80~0.89）', ...
                '中等（0.70~0.79）', '合格（0.60~0.69）', '不合格（<0.60）'};
            t2 = Tab2Worda(cc.Benchmark,'评价标准表','课程目标评价标准',t2head);
            append(te,t2);
            append(te,Paragraph(''));
        end
        append(r,te);
        append(t,r); 
        
        if isequal(cc.Category,'集中实践教学')
            r = TableRow;
            r.Style = [r.Style,bodyStyle];
            te = TableEntry('实习注意事项');
            append(r,te);
            te = TableEntry;
            for i = 1:length(cc.Notices)
                append(te,Paragraph(cc.Notices{i}));
            end            
        end
        
        r = TableRow;
        r.Style = [r.Style,bodyStyle];
        te = TableEntry('教材及参考资料');
        append(r,te);
        te = TableEntry;
        for i = 1:length(cc.Textbook)
            append(te,Paragraph(cc.Textbook{i}));
        end
        append(r,te);
        append(t,r);

        r = TableRow;
        r.Style = [r.Style,bodyStyle];
        te = TableEntry('制定人及制定时间');
        append(r,te);
        te = TableEntry;
        append(te,Paragraph(flag));
        append(r,te);
        append(t,r);
        
        append(doc,t);
        
        % 实验课程教纲中表列实验内容和学时明细
        if ~isempty(regexp(cc.Title,'实验','once')) && ...
                ~isequal(cc.Category,'集中实践教学')
            append(doc,clone(landscapePLO));
            p3 = Paragraph(sprintf('《%s》实验教学内容与学时分配',cc.Title));
            p3.Style = headStyle;
            append(doc,p3);
            t3head = {'编号', '实验项目名称', '学时', '实验内容提要', ...
                '实验类型', '实验要求', '每组人数', '主要仪器设备与软件'};
            t3 = Tab2Worda(cc.ExpDetail,'实验教学内容表','课程目标评价标准',t3head);
            append(doc,t3);
            
            append(doc,Paragraph(''));
        end

        close(doc);
        
        status = sprintf('成功创建文件“%s.docx”',cc.Title);
        
%         rptview(cc.Title, 'docx');
        
    else
        status = '输入参数类型有误';
        warning('输入参数类型有误')
    end
else
    status = '输入参数不完整';
    warning('输入参数不完整')
end

end
