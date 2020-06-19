%% 用Matlab报表生成器将达成度分析结果按模板输出为docx文件
%
% by Dr. Guan Guoqiang @ SCUT on 2020-06-15

%% 初始化
% 检查工作空间中有无达成度分析结果
if ~exist('db_Outcome', 'var')
    disp('Required variable of db_Outcome is NOT existed')
    return
end
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
    BackgroundColor("yellow"), ...
    Bold(true) ...
    };
% 达成度计算表的表头内容
headerContent_HowToCalc = ...
    { ...
    '毕业要求指标点', '教学目标', '评价方式', '考核环节', ...
    '满分', '平均得分', '目标值', '得分', '目标达成度' ...
    };
% 定义“达成度计算表”总共包括9列
grps_HowToCalc(1) = TableColSpecGroup;
grps_HowToCalc(1).Span = 9; % 总列数
% 第1-2列宽度
specs_HowToCalc(1) = TableColSpec;
specs_HowToCalc(1).Span = 2;
specs_HowToCalc(1).Style = {Width("25%")};
% 第3列宽度
specs_HowToCalc(2) = TableColSpec;
specs_HowToCalc(2).Span = 1;
specs_HowToCalc(2).Style = {Width("20%")};
% 第4-9列（合计6列）
specs_HowToCalc(3) = TableColSpec;
specs_HowToCalc(3).Span = 6;
specs_HowToCalc(3).Style = {Width("5%")};
%
grps_HowToCalc(1).ColSpecs = specs_HowToCalc;

%% 顺次生成各课程的达成度分析结果
for i=1:length(db_Outcome)
    % 构建输出文件名称，例如，课程名称_年级
    class = fieldnames(db_Outcome);
    class = class{4};
    filename = [db_Outcome(i).Name{:}, '_', class(6:end)];
    % 创建文档对象
    d = Document(filename, 'docx', 'EA_ReportTemplate.dotx');
    % 打开文档
    open(d);
    % 移位到下一标志位
    moveToNextHole(d);
    % 插入课程名称
    append(d, db_Outcome(i).Name{:});
    % 移位到下一标志位
    moveToNextHole(d);
    % 插入课程代码
    append(d, db_Outcome(i).ID{:});
    
    % 根据db_Curriculum中定义的支撑矩阵获取指标统一编号
    idx_UniNum = find(db_Curriculum.ReqMatrix(i,:));
    % 根据指标数目构造空矩阵
    bodyContent = cell(length(idx_UniNum),9);   
    % 矩阵第一列填入支撑指标点文本
    bodyContent(:,1) = db_GradRequire{idx_UniNum,2}; 
    % 矩阵第二列填入相应的教学目标【功能待开发】
    % 构造“达成度计算表”主体内容
    tableContent = [headerContent_HowToCalc; bodyContent];  
    % 生成“达成度计算表”
    tout_HowToCalc = Table(tableContent);   
    % 应用表属性
    tout_HowToCalc.ColSpecGroups = grps_HowToCalc;
    tout_HowToCalc.Style = tableStyle;
    tout_HowToCalc.TableEntriesStyle = tableEntriesStyle;
    firstRow = tout_HowToCalc.Children(1);
    firstRow.Style = headerRowStyle;
    % 移位到下一标志位
    moveToNextHole(d);
    % 插入“达成度计算表”
    append(d, tout_HowToCalc);
    
    % 移位到下一标志位
    moveToNextHole(d);
    % 插入“达成度分析说明”
    append(d, '达成度分析说明（示例）');
    % 移位到下一标志位
    moveToNextHole(d);
    % 换页
    append(d, PageBreak());
    
    % 移位到下一标志位
    moveToNextHole(d);
    % 插入课程名称
    append(d, db_Outcome(i).Name{:});
    
    % 移位到下一标志位
    moveToNextHole(d); 
    % 插入“上课学期”（通过截取成绩单的第1个同学课程代码中的前13个字符）
    append(d, db_Outcome(i).(class).CourseCode{1}(1:13));
    
    % 学生成绩单
    tout_Details = db_Outcome(i).(class);
    % 转化为mlreportgen.dom.Table对象【编程要点】
    tout_Details = Table(tout_Details(:,[1:3,5:(end-2)])); 
    
    % 定义“学生成绩单”列数
    grps_Details(1) = TableColSpecGroup;
    % 第1列宽度
    specs_Details(1) = TableColSpec;
    specs_Details(1).Span = 1;
    specs_Details(1).Style = {Width("25%")};
    % 第2列宽度
    specs_Details(2) = TableColSpec;
    specs_Details(2).Span = 1;
    specs_Details(2).Style = {Width("15%")};
    % 第3列宽度
    specs_Details(3) = TableColSpec;
    specs_Details(3).Span = 1;
    specs_Details(3).Style = {Width("25%")};
    % 其余列宽度
    specs_Details(4) = TableColSpec;
    specs_Details(4).Span = tout_Details.NCols-3;
    specs_Details(4).Style = {Width([num2str(35/(tout_Details.NCols-3)) '%'])};
    %
    grps_Details(1).ColSpecs = specs_Details;
    % 应用表属性
    tout_Details.ColSpecGroups = grps_Details;
    tout_Details.Style = tableStyle;
    % 移位到下一标志位
    moveToNextHole(d);
    % 插入“成绩单”
    append(d, tout_Details);
    
    % 关闭文档
    close(d);
end
