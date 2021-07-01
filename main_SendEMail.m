%% 将课程支撑的指标点发送给课程负责人
%
% by Dr. Guan Guoqiang @ SCUT on 2021/7/1

%% 初始化
clear
load('database.mat','db_Curriculum2021a','db_Indicators2021')

%% 列出专业课程
idx = ~strcmp('N/A',db_Curriculum2021a.Email);
courses = db_Curriculum2021a(idx,:);

%% 对各课程列出其支撑的指标
supportIndicator = string;
for iCourse = 1:height(courses)
    idx = logical(courses.ReqMatrix(iCourse,:));
    UniNums = db_Indicators2021.UniNum(idx);
    Specs = db_Indicators2021.Spec(idx);
    content = string;
    for i = 1:length(UniNums)
        if i == 1
            content = sprintf('%s\n', strcat(UniNums{i},'：',Specs{i}));
        else
            content = sprintf('%s%s\n', content, strcat(UniNums{i},'：',Specs{i}));
        end
    end
    supportIndicator(iCourse,1) = content;
    % 邮件内容
    ctext = sprintf('您好！\n');
    ctext = [ctext,sprintf('根据专业认证进校专家意见对能源化工专业的毕业要求课程支撑矩阵进行了简化，为此请您核对所负责的能源化工专业课程《%s》支撑的指标点如下：\n',courses.Name(iCourse))];
    ctext = [ctext,content];
    ctext = [ctext,sprintf('后续请参照上列的指标点进行课程达成度分析和教纲修改。若有任何问题，请与我联系！\n')];
    ctext = [ctext,sprintf('礼\n')];
    ctext = [ctext,sprintf('关国强\n')];
    ctext = [ctext,sprintf('%s\n',char(datetime('now')))];
    ctext = [ctext,sprintf('备注：\n')];
    ctext = [ctext,sprintf('公共教学团队若指定专门负责的老师，烦请转发该邮件给相关老师，谢谢！\n')];
    % 收件人
    recipient = strsplit(courses.Email(iCourse),'; ');
    % 邮件主题
    subject = sprintf('能源化工专业必修课《%s》支撑指标点核对',courses.Name(iCourse));
    email(recipient, subject, ctext)
end