function oTab = CombineCourseList(cList1,cList2)
% oTab包括上下两部分，表上半部分为cList1.Name课程，下半部分为cList2中不在cList1的课程
    % 构造表的上半部分    
    idC = cellfun(@(x)find(strcmp(x,cList2.Name)),cList1.Name,...
        'UniformOutput',false); % 根据cList1.Name对cList2排序
    courseName = cList1.Name; % oTab的第一个变量
    supportIndicator1 = cList1.supportIndicator; % oTab的第二个变量
    supportIndicator2 = string; % oTab的第三个变量
    for i = 1:length(idC)
        if isempty(idC{i})
            supportIndicator2(i,1) = ""; % 说明cList2中没有cList1的该课程
        else
            supportIndicator2(i,1) = cList2{idC{i},3};
        end
    end
    oTab1 = table(courseName,supportIndicator1,supportIndicator2);
    % 构造表的下半部分
    id = cell2mat(idC); % 其中空值会自动删除
    cList2(id,:) = []; % 删除已填入oTab1的课程
    courseName = cList2.Name; 
    supportIndicator1 = repmat("",size(courseName));
    supportIndicator2 = cList2.supportIndicator;
    oTab2 = table(courseName,supportIndicator1,supportIndicator2);
    % 输出
    oTab = [oTab1;oTab2];
    