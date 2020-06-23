%% 用Matlab报表生成器将达成度分析结果按模板输出为docx文件
% Word模板：EA_ReportTemplate.dotx
%
% by Dr. Guan Guoqiang @ SCUT on 2020-06-15

%% 初始化
% 检查工作空间中有无达成度分析结果
if ~exist('QE_Courses', 'var')
    disp("请手工载入工作变量QE_Courses，例如load('QE_Courses.mat','QE_Courses')")
    return
end
% 载入Matlab报表生成器
import mlreportgen.dom.*
% 定义表属性
tableStyle = {Width('100%'), Border('solid'), ColSep('solid'), RowSep('solid')};
mainHeaderRowStyle = {VAlign('middle'), InnerMargin('2pt', '2pt', '2pt', '2pt'), ...
    BackgroundColor('yellow')};
mainHeaderTextStyle = {Bold, OuterMargin('0pt', '0pt', '0pt', '0pt'), FontFamily('Arial'), HAlign('center')};
subHeaderRowStyle = {VAlign('middle'), InnerMargin('2pt', '2pt', '2pt', '2pt'), BackgroundColor('yellow')};
subHeaderTextStyle = {Bold, OuterMargin('0pt', '0pt', '0pt', '0pt'), FontFamily('Arial'), HAlign('center')};
bodyStyle = {OuterMargin('0pt', '0pt', '0pt', '0pt'), InnerMargin('2pt', '2pt', '2pt', '0pt')};

% 定义“达成度计算表”总共包括9列
Grps1(1) = TableColSpecGroup;
Grps1(1).Span = 9; % 总列数
% 第1-2列宽度
Tab1Specs(1) = TableColSpec;
Tab1Specs(1).Span = 2;
Tab1Specs(1).Style = {Width("25%")};
% 第3列宽度
Tab1Specs(2) = TableColSpec;
Tab1Specs(2).Span = 1;
Tab1Specs(2).Style = {Width("13%")};
% 第4列宽度
Tab1Specs(3) = TableColSpec;
Tab1Specs(3).Span = 1;
Tab1Specs(3).Style = {Width("7%")};
% 第5-9列（合计6列）
Tab1Specs(4) = TableColSpec;
Tab1Specs(4).Span = 5;
Tab1Specs(4).Style = {Width("6%")};
%
Grps1(1).ColSpecs = Tab1Specs;

%% 顺次生成各课程的达成度分析结果
for iCourse=1:length(QE_Courses)
    % 构建输出文件名称，例如，课程名称_年级
    class = QE_Courses.Class;
    filename = [QE_Courses(iCourse).Name, '_', class];
    % 创建文档对象
    d = Document(filename, 'docx', 'EA_ReportTemplate.dotx');
    % 打开文档
    open(d);
    % 移位到下一标志位
    moveToNextHole(d);
    % 插入课程名称
    append(d, QE_Courses(iCourse).Name);
    % 移位到下一标志位
    moveToNextHole(d);
    % 插入课程代码
    append(d, QE_Courses(iCourse).ID);
    % 移位到下一标志位
    moveToNextHole(d)
    
    % 建立表对象
    t = Table(9);
    t.Style = [t.Style tableStyle];
    t.ColSpecGroups = [t.ColSpecGroups Grps1(1)];
    
    % 表头
    r = TableRow;
    r.Style = [r.Style mainHeaderRowStyle];
    p = Paragraph('毕业要求指标点');
    p.Style = [p.Style mainHeaderTextStyle];
    te = TableEntry(p);
    te.RowSpan = 2;
    append(r,te);
    p = Paragraph('教学目标');
    p.Style = [p.Style mainHeaderTextStyle];
    te = TableEntry(p);
    te.RowSpan = 2;
    append(r,te);
    p = Paragraph('达成途径');
    p.Style = [p.Style mainHeaderTextStyle];
    te = TableEntry(p);
    te.ColSpan = 2;
    append(r,te); 
    p = Paragraph('实际打分');
    p.Style = [p.Style mainHeaderTextStyle];
    te = TableEntry(p);
    te.ColSpan = 2;
    append(r,te);
    p = Paragraph('相对目标值打分');
    p.Style = [p.Style mainHeaderTextStyle];
    te = TableEntry(p);
    te.ColSpan = 2;
    append(r,te);
    p = Paragraph('达成度');
    p.Style = [p.Style mainHeaderTextStyle];
    te = TableEntry(p);
    te.RowSpan = 2;
    append(r,te);
    append(t,r);
    
    r = TableRow;
    r.Style = [r.Style subHeaderRowStyle];
    p = Paragraph('评价方式');
    p.Style = [p.Style subHeaderTextStyle];
    te = TableEntry(p);
    append(r,te);
    p = Paragraph('考核环节');
    p.Style = [p.Style subHeaderTextStyle];
    te = TableEntry(p);
    append(r,te);
    p = Paragraph('满分值');
    p.Style = [p.Style subHeaderTextStyle];
    te = TableEntry(p);
    append(r,te);
    p = Paragraph('平均得分');
    p.Style = [p.Style subHeaderTextStyle];
    te = TableEntry(p);
    append(r,te);
    p = Paragraph('目标分值');
    p.Style = [p.Style subHeaderTextStyle];
    te = TableEntry(p);
    append(r,te);
    p = Paragraph('最终成绩');
    p.Style = [p.Style subHeaderTextStyle];
    te = TableEntry(p);
    append(r,te);
    append(t,r);

    % 逐个指标点生成达成度分析表
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
                        % 找该列的下一个非空元素的位置
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
    
    % 课程达成度行
    r = TableRow;
    te = TableEntry('达成度结果');
    append(r,te);
    te = TableEntry(num2str(round(QE_Courses.Result,4,'significant')));
    te.ColSpan = 8;
    append(r,te);
    append(t,r);
    
    % 达成度分析内容
    r = TableRow;
    te = TableEntry('达成度分析');
    append(r,te);
    te = TableEntry(QE_Courses.Analysis);
    te.ColSpan = 8;
    append(r,te);
    append(t,r);   
    
    % 写入表格
    append(d,t);
    
    % 换页
    append(d,PageBreak());
    
    % 移位到下一标志位
    moveToNextHole(d);
    % 插入课程名称
    append(d, QE_Courses(iCourse).Name);
    
    % 移位到下一标志位
    moveToNextHole(d);
    
    % 定义成绩单表格列宽
    NCol = width(QE_Courses(iCourse).Transcript.Detail); % 总列数
    Grps2(1) = TableColSpecGroup;
    Grps2(1).Span = NCol;
    % 第1-2列宽度
    Tab2Specs(1) = TableColSpec;
    Tab2Specs(1).Span = 2;
    Tab2Specs(1).Style = {Width("10%")};
    % 第3列宽度
    Tab2Specs(2) = TableColSpec;
    Tab2Specs(2).Span = 1;
    Tab2Specs(2).Style = {Width("5%")};
    % 第4列宽度
    Tab2Specs(3) = TableColSpec;
    Tab2Specs(3).Span = 1;
    Tab2Specs(3).Style = {Width("3%")}; 
    % 第5列宽度
    Tab2Specs(4) = TableColSpec;
    Tab2Specs(4).Span = 1;
    Tab2Specs(4).Style = {Width("22%")};
    % 其余列宽度
    Tab2Specs(5) = TableColSpec;
    Tab2Specs(5).Span = NCol-5;
    Tab2Specs(5).Style = {Width([num2str(50/(NCol-5)) '%'])};
    %
    Grps2(1).ColSpecs = Tab2Specs;
    
    % 建立表对象
    tdata2 = table2cell(QE_Courses(iCourse).Transcript.Detail);
    Headers = QE_Courses(iCourse).Transcript.Detail.Properties.VariableNames;
    t2 = Table(length(Headers));
%     t2 = Table(QE_Courses(iCourse).Transcript.Detail);
    t2.Style = [t2.Style tableStyle];
    t2.ColSpecGroups = [t2.ColSpecGroups Grps2(1)];
    
    % 表头
    r = TableRow;
    r.Style = [r.Style mainHeaderRowStyle];
    for iCol = 1:length(Headers)
        p = Paragraph(Headers{iCol});
        p.Style = [p.Style mainHeaderTextStyle];
        te = TableEntry(p);
        append(r,te);
    end
    append(t2,r);
    
    % 表内容
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
    
% 写入表
append(d,t2);

% 关闭文档
close(d);

