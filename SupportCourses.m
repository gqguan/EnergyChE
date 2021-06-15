function oTab = SupportCourses(db_Curriculum1,db_Curriculum2,db_Indicators)
%% 根据输入的培养方案列出各毕业要求指标点支撑的课程列表

% 导入毕业要求及指标说明
if ~exist('db_Indicators','var')
    load('database.mat','db_Indicators');
end

if ~exist('db_Curriculum2','var')
    % 初始化
    oTab = cell(sum(sum(db_Curriculum1.ReqMatrix)),2);
    iRow = 1;
    % 列出各指标点的支撑课程
    for i = 1:height(db_Indicators)
        oTab{iRow,1} = [db_Indicators.UniNum{i},db_Indicators.Spec{i}];
        courseNum = sum(db_Curriculum1.ReqMatrix(:,i));
        courseList = cellstr(db_Curriculum1.Name(logical(db_Curriculum1.ReqMatrix(:,i))));
        oTab(iRow:(iRow+courseNum-1),2) = courseList;
        iRow = iRow+courseNum;
    end
else
    % 初始化
    rowN = sum(max(sum(db_Curriculum1.ReqMatrix),sum(db_Curriculum2.ReqMatrix)));
    oTab = cell(rowN,3);
    iRow = 1;
    % 列出各指标点的支撑课程
    for i = 1:height(db_Indicators)
        oTab{iRow,1} = [db_Indicators.UniNum{i},db_Indicators.Spec{i}];
        courseNum1 = sum(db_Curriculum1.ReqMatrix(:,i));
        courseNum2 = sum(db_Curriculum2.ReqMatrix(:,i));
        courseList1 = cellstr(db_Curriculum1.Name(logical(db_Curriculum1.ReqMatrix(:,i))));
        courseList2 = cellstr(db_Curriculum2.Name(logical(db_Curriculum2.ReqMatrix(:,i))));
        oTab(iRow:(iRow+courseNum1-1),2) = courseList1;
        oTab(iRow:(iRow+courseNum2-1),3) = courseList2;
        iRow = iRow+max(courseNum1,courseNum2);
    end
end
