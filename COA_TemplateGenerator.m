%% 生成全部课程的达成度分析Excel模板
%
% by Dr. Guan Guoqiang @ SCUT on 2020/6/10
%

%% 初始化
% 读取课程列表
clear;
Years = {'class2015'}; % 该值为进行毕业要求达成度计算的学生年级
% Get data for processing
year = Years{:};
msg_str = sprintf('从保存工作区database.mat中导入 %s 数据', year);
Setlog(msg_str, 3);
[db_Outcome, db_Curriculum, db_GradRequire] = GetData(Years);

%% 构建课程目标说明表
% 列出对每门课程的毕业要求指标点
NumCourse = length(db_Outcome);
for course_sn = 1:NumCourse
    idx_UniNum = find(db_Curriculum.ReqMatrix(course_sn,:)); % 课程支撑指标点编号向量
    M = length(idx_UniNum); % 课程支撑的指标点数目
    % 假定通过考试和平时两个环节考核，各环节权重分别为0.7和0.3
    Evaluation = cell(1,7);
%     Evaluation(1,1) = {'考试'};
%     Evaluation(1,2) = {'例如填"A1_4，A2_2，A3_1和A3_2"表示统分表中的这些题对应于该考试目标'};
%     Evaluation(1,3) = {'例如A1_4，A2_2，A3_1和A3_2题合计满分为45'};
%     Evaluation(1,4) = {'按统分表A1_4，A2_2，A3_1和A3_2列的平均值之和33.21'};
%     Evaluation(1,5) = {'输入权重，例如0.2'};
%     Evaluation(1,6) = {'计算得分'};
%     Evaluation(1,7) = {'教学目标的达成度（0~1的值）'};
    % 创建课程目标说明表内容
    CO_description = cell(M*size(Evaluation,1),10);
    row1 = 1;
    for m = 1:M
        CO_description(row1,1:2) = db_GradRequire{idx_UniNum(m),:};
        CO_description(row1,3) = {'【输入相应教学目标】'};
        [height, width] = size(Evaluation);
        row2 = row1+height;
        CO_description(row1:(row2-1), 4:(3+width)) = Evaluation;
        row1 = row2;
    end
    CO_description(1,4) = {'考试'};
    CO_description(1,5) = {'例如填“A1_4+A2_2+A3_1+A3_2”表示统分表中的这些题对应于该课程目标'};
    CO_description(1,6) = {'例如填“45”表示Method所列的考题总分值'};
    CO_description(1,7) = {'例如填“33.21”表示统分表A1_4，A2_2，A3_1和A3_2列的平均值之和'};
    CO_description(1,8) = {'例如填“1”表示该评价方式对相应教学目标的权重为1'};
    CO_description(1,9) = {'例如填“0.738”表示得分=Average/Credit为0.738'};
    CO_description(1,10) = {'例如填“0.738”表示Completeness=Weight*Rate为0.738'};
    % 达成度分析表
    output = cell(5+size(CO_description,1),9);
    output(1,1) = {'课程名称'}; output(1,2) = db_Curriculum.Name(course_sn);
    output(2,1) = {'课程代码'}; output(2,2) = db_Curriculum.ID(course_sn);
    output(3,1) = {'学生班级'}; output(3,2) = {strcat('能源化工',year(end-3:end),'级')};
    output(4,:) = {'毕业要求指标点','课程目标','考核环节','评价方式','满分','平均分','权重','得分','达成度'};
    output(5:4+size(CO_description,1),:) = CO_description(:,2:10);
    output(5+size(CO_description,1),1) = {'达成度分析'}; output(5+size(CO_description,1),2) = {'【结合具体课程内容评述各目标的达成情况，重点关注持续改进的措施和效果】'};
    output = cell2table(output);
    % 转换为课程目标说明表：毕业要求指标点，教学目标，考试和平时两个考核环节的权重
    CO_description = cell2table(CO_description);
    CO_description.Properties.VariableNames = {'No','GR_Spec','Objective',...
        'Way','Method','Credit','Average','Weight','Rate','Completeness'};
    % 载入统分表示例
    load('sample.mat')
    % 在指定工作簿中输出工作表
    filename = strcat(db_Curriculum.Name{course_sn},'_',year(end-3:end),'级.xlsx');
    msg_str = sprintf('创建课程目标达成度分析模板文件：%s', filename);
    Setlog(msg_str, 3);
    warning off MATLAB:xlswrite:AddSheet % 关闭新建表的警告提示
    writetable(CO_description, filename, 'Sheet', '课程目标说明')
    writetable(sample, filename, 'Sheet', '统分表（示例）')
    writetable(output, filename, 'Sheet', '达成度分析')
end
