%% 在Word中生成表格
%
% 功能说明：
% * 自动合并多列单元格
%
% 输入参数
% TabType - '毕业要求达成度结果表'
%           '毕业要求评价依据表'
%           '课程达成度分析表'
%           '毕业设计(论文)成绩单'
%           '其他'
%
% by Dr. Guan Guoqiang @ SCUT on 2020-07-08

function t = Tab2Worda(TabContent, TabType, TabName, TabHead)

%% 初始化
% 输入参数校核
if exist('TabContent','var')
    NCol = size(TabContent,2);
    if exist('TabHead','var')
        if size(TabHead,2) ~= NCol
            cprintf('err','【错误】输入表头与表体的宽度不一致！\n')
            return
        end
    else
        cprintf('Comments','未指定表头，输出没有表头的表！\n')
    end
else
    cprintf('err','【错误】缺少必要的输入参数TabContent！\n')
    return
end
if ~exist('TabType','var')
    cprintf('Comments','未指定输出表类型，使用缺省值“毕业要求达成度结果表”！\n')
    TabType = '毕业要求达成度结果表';
end
if ~exist('TabName','var')
    cprintf('Comments','未指定输出表名称，使用缺省值表类型为表名！\n')
    TabName = TabType;
end

% 载入Matlab报表生成器
import mlreportgen.dom.*
% 中文字体样式设置
headFont=FontFamily;
headFont.FamilyName='Arial';
headFont.EastAsiaFamilyName='黑体';
bodyFont=FontFamily;
bodyFont.FamilyName='Times New Roman';
bodyFont.EastAsiaFamilyName='宋体';
% 定义表属性
tableStyle = {Width('100%'), Border('solid'), ColSep('solid'), RowSep('solid')};
mainHeaderRowStyle = {HAlign('center'), VAlign('middle'), ...
    OuterMargin('0pt', '0pt', '0pt', '0pt'), InnerMargin('2pt', '2pt', '2pt', '2pt'), ...
    BackgroundColor('lightgrey'), LineSpacing('0pt'), headFont};
bodyStyle = {OuterMargin('0pt', '0pt', '0pt', '0pt'), InnerMargin('2pt', '2pt', '2pt', '2pt'), bodyFont};

%%
% 建立表对象
t = Table(NCol);
t.Style = [t.Style tableStyle];

% 设定表中各列宽度
t.ColSpecGroups = [t.ColSpecGroups,GetTabWidth(TabType,NCol)];

% 表头
if nargin == 4
    CombineVCell(TabHead, mainHeaderRowStyle)
end

% 表体
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
                if isnumeric(content) % 数值保留4位有效数字
                    content = num2str(round(content,4,'significant'));
                end
                te = TableEntry(content);
                if NRow ~= 1
                    % 找该列的下一个非空元素的位置
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
    % 定义成绩单表格列宽
    Grps = TableColSpecGroup;
    Grps.Span = NCol;    
    switch type
        case('实验教学内容表')
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
        case('评价标准表')
            TabSpecs(1) = TableColSpec;
            TabSpecs(1).Span = 1;
            TabSpecs(1).Style = {Width("10%")};
            TabSpecs(2) = TableColSpec;
            TabSpecs(2).Span = NCol-1;
            ColWidth = strcat(string(round(0.9/(NCol-1),3)*100),"%");
            TabSpecs(2).Style = {Width(ColWidth)};            
        case('关系矩阵表')
            TabSpecs(1) = TableColSpec;
            TabSpecs(1).Span = 1;
            TabSpecs(1).Style = {Width("25%")};
            TabSpecs(2) = TableColSpec;
            TabSpecs(2).Span = NCol-1;
            ColWidth = strcat(string(round(0.75/(NCol-1),3)*100),"%");
            TabSpecs(2).Style = {Width(ColWidth)};
        case('课程达成度分析表')
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
        case('毕业设计(论文)成绩单')
            % 第1-2列宽度
            TabSpecs(1) = TableColSpec;
            TabSpecs(1).Span = 2;
            TabSpecs(1).Style = {Width("10%")};
            % 第3列宽度
            TabSpecs(2) = TableColSpec;
            TabSpecs(2).Span = 1;
            TabSpecs(2).Style = {Width("5%")};
            % 第4列宽度
            TabSpecs(3) = TableColSpec;
            TabSpecs(3).Span = 1;
            TabSpecs(3).Style = {Width("3%")}; 
            % 第5列宽度
            TabSpecs(4) = TableColSpec;
            TabSpecs(4).Span = 1;
            TabSpecs(4).Style = {Width("22%")};
            % 其余列宽度
            TabSpecs(5) = TableColSpec;
            TabSpecs(5).Span = NCol-5;
            TabSpecs(5).Style = {Width([num2str(50/(NCol-5)) '%'])};
        case('毕业要求达成度结果表')
            % 第1列宽度
            TabSpecs(1) = TableColSpec;
            TabSpecs(1).Span = 1;
            TabSpecs(1).Style = {Width("10%")};
            % 第2列宽度
            TabSpecs(2) = TableColSpec;
            TabSpecs(2).Span = 1;
            TabSpecs(2).Style = {Width("35%")};
            % 第3列宽度
            TabSpecs(3) = TableColSpec;
            TabSpecs(3).Span = 1;
            TabSpecs(3).Style = {Width("30%")}; 
            % 第4列宽度
            TabSpecs(4) = TableColSpec;
            TabSpecs(4).Span = 1;
            TabSpecs(4).Style = {Width("5%")};    
            % 第5-8列宽度
            TabSpecs(5) = TableColSpec;
            TabSpecs(5).Span = 4;
            TabSpecs(5).Style = {Width("5%")};
        case('毕业要求评价依据表')
            % 第1列宽度
            TabSpecs(1) = TableColSpec;
            TabSpecs(1).Span = 1;
            TabSpecs(1).Style = {Width("10%")};
            % 第2列宽度
            TabSpecs(2) = TableColSpec;
            TabSpecs(2).Span = 1;
            TabSpecs(2).Style = {Width("15%")};
            % 第3列宽度
            TabSpecs(3) = TableColSpec;
            TabSpecs(3).Span = 1;
            TabSpecs(3).Style = {Width("15%")}; 
            % 第4-7列宽度
            TabSpecs(4) = TableColSpec;
            TabSpecs(4).Span = 5;
            TabSpecs(4).Style = {Width("12%")};
        case('毕业要求指标点')
            % 第1列宽度
            TabSpecs(1) = TableColSpec;
            TabSpecs(1).Span = 1;
            TabSpecs(1).Style = {Width("30%")};
            % 第2列宽度
            TabSpecs(2) = TableColSpec;
            TabSpecs(2).Span = 1;
            TabSpecs(2).Style = {Width("70%")};
        case('指标点支撑课程列表')
            % 第1列指标点宽度
            TabSpecs(1) = TableColSpec;
            TabSpecs(1).Span = 1;
            TabSpecs(1).Style = {Width("30%")};
            % 第2列宽度
            TabSpecs(2) = TableColSpec;
            TabSpecs(2).Span = 1;
            TabSpecs(2).Style = {Width("40%")};
            % 第3列宽度
            TabSpecs(3) = TableColSpec;
            TabSpecs(3).Span = 1;
            TabSpecs(3).Style = {Width("30%")}; 
        case('课程目标与毕业要求关系表')
            % 第1列宽度
            TabSpecs(1) = TableColSpec;
            TabSpecs(1).Span = 1;
            TabSpecs(1).Style = {Width("30%")};
            % 第2列宽度
            TabSpecs(2) = TableColSpec;
            TabSpecs(2).Span = 1;
            TabSpecs(2).Style = {Width("35%")};
            % 第3列宽度
            TabSpecs(3) = TableColSpec;
            TabSpecs(3).Span = 1;
            TabSpecs(3).Style = {Width("35%")};
        case('各课程评价方式的权重一览表')
            % 第1列宽度
            TabSpecs(1) = TableColSpec;
            TabSpecs(1).Span = 1;
            TabSpecs(1).Style = {Width("25%")};
            % 第2列宽度
            TabSpecs(2) = TableColSpec;
            TabSpecs(2).Span = 1;
            TabSpecs(2).Style = {Width([num2str(80/(NCol-1)),'%'])};
        otherwise
            % 第1列宽度
            TabSpecs(1) = TableColSpec;
            TabSpecs(1).Span = 1;
            TabSpecs(1).Style = {Width("13%")};
            % 第2列宽度
            TabSpecs(2) = TableColSpec;
            TabSpecs(2).Span = 1;
            TabSpecs(2).Style = {Width("7%")};
            % 第3列宽度
            TabSpecs(3) = TableColSpec;
            TabSpecs(3).Span = 1;
            TabSpecs(3).Style = {Width("10%")};
            % 第4列宽度
            TabSpecs(4) = TableColSpec;
            TabSpecs(4).Span = 1;
            TabSpecs(4).Style = {Width("5%")};
            % 其余列宽度
            TabSpecs(5) = TableColSpec;
            TabSpecs(5).Span = NCol-5;
            TabSpecs(5).Style = {Width([num2str(65/(NCol-4)) '%'])};         
    end
    %
    Grps.ColSpecs = TabSpecs;             
end

end