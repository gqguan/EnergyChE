%% 用Matlab报表生成器将达成度分析结果按模板输出为docx文件
%
% by Dr. Guan Guoqiang @ SCUT on 2020-06-15

%% 初始化
% 检查工作空间中有无达成度分析结果

% 载入Matlab报表生成器
import mlreportgen.dom.*
% 定义表属性
tableStyle = ...
    { ...
    Width("100%"), ...
    Border("solid"), ...
    RowSep("solid"), ...
    ColSep("solid") ...
    };
tableEntriesStyle = ...
    { ...
    HAlign("center"), ...
    VAlign("middle") ...
    };
% 表头格式
headerRowStyle = ...
    { ...
    InnerMargin("2pt","2pt","2pt","2pt"), ...
    BackgroundColor("gray"), ...
    Bold(true) ...
    };
% 表头内容
headerContent = ...
    { ...
    '毕业要求指标点', '教学目标', '评价方式', '考核环节', ...
    '满分', '平均得分', '目标值', '得分', '目标达成度' ...
    };
% 定义表总共包括9列
grps(1) = TableColSpecGroup;
grps(1).Span = 9; % 总列数
% 第1-2列宽度
specs(1) = TableColSpec;
specs(1).Span = 2;
specs(1).Style = {Width("25%")};
% 第3列宽度
specs(2) = TableColSpec;
specs(2).Span = 1;
specs(2).Style = {Width("20%")};
% 第4-9列（合计6列）
specs(3) = TableColSpec;
specs(3).Span = 6;
specs(3).Style = {Width("5%")};
grps(1).ColSpecs = specs;

%% 顺次生成各课程的达成度分析结果
for i=1:length(db_Outcome)
    % 构建输出文件名称，例如，课程名称_年级
    filename = [db_Outcome(i).Name{:}, '_', '2015'];
    % 创建文档对象
    d = Document(filename, 'docx', 'EA_ReportTemplate.dotx');
    % 打开文档
    open(d);
    % 移位到下一标志位
    moveToNextHole(d);
    % 输入课程名称
    append(d, db_Outcome(i).Name{:});
    % 移位到下一标志位
    moveToNextHole(d);
    % 输入课程代码
    append(d, db_Outcome(i).ID{:});
    % 根据db_Curriculum中定义的支撑矩阵获取指标统一编号
    idx_UniNum = find(db_Curriculum.ReqMatrix(i,:));
    % 根据指标数目构造空矩阵
    bodyContent = cell(length(idx_UniNum),9);   
    % 矩阵第一列填入支撑指标点文本
    bodyContent(:,1) = db_GradRequire{idx_UniNum,2}; 
    % 矩阵第二列填入相应的教学目标【功能待开发】
    % 构造表主体内容
    tableContent = [headerContent; bodyContent];  
    % 生成表
    tout = Table(tableContent);   
    % 应用表属性
    tout.ColSpecGroups = grps;
    tout.Style = tableStyle;
    tout.TableEntriesStyle = tableEntriesStyle;
    firstRow = tout.Children(1);
    firstRow.Style = headerRowStyle;
    % 移位到下一标志位
    moveToNextHole(d);
    % 输入表
    append(d, tout);
    % 关闭文档
    close(d);
end
