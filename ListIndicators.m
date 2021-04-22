%% 在课程列表后生成所支撑的毕业要求指标编号栏

clear

load('database.mat','db_Curriculum2019a')
load('database.mat','db_Curriculum2019b')
load('database.mat','db_Indicators')

supportIndicator = string;
for iCourse = 1:height(db_Curriculum2019a)
    idx = logical(db_Curriculum2019a.ReqMatrix(iCourse,:));
    UniNums = db_Indicators.UniNum(idx);
    content = string;
    for i = 1:length(UniNums)
        if i == 1
            content = sprintf('%s %s', content, UniNums{i});
        else
            content = sprintf('%s, %s', content, UniNums{i});
        end
    end
    supportIndicator(iCourse,1) = content;
end

cList1 = [db_Curriculum2019a(:,2:3),table(supportIndicator)];

supportIndicator = string;
for iCourse = 1:height(db_Curriculum2019b)
    idx = logical(db_Curriculum2019b.ReqMatrix(iCourse,:));
    UniNums = db_Indicators.UniNum(idx);
    content = string;
    for i = 1:length(UniNums)
        if i == 1
            content = sprintf('%s %s', content, UniNums{i});
        else
            content = sprintf('%s, %s', content, UniNums{i});
        end
    end
    supportIndicator(iCourse,1) = content;
end

cList2 = [db_Curriculum2019b(:,2:3),table(supportIndicator)];

cList = [cList1;cList2];
