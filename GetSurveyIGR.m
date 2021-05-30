%% 从问卷调查教师提交的课程支撑指标点结果数据文件中提取数据
% 问卷调查网址 https://forms.office.com/r/e9gjC26GP5
% 
% by Dr. Guan Guoqiang @ SCUT on 2021/5/30

%% 初始化
load('database.mat', 'db_Indicators')

%% 导入问卷数据文件
[Data,Workbook] = importfile();
% 获取表头
Heads = Data(1,:);
Data(1,:) = [];
% 获取信息列
TimeColIdx = find(cellfun(@(x)contains(x,'时间'),Heads));
TimeCols = cellfun(@(x)datetime(x,'InputFormat','yyyy/MM/dd HH:mm:ss'),Data(:,TimeColIdx));
% 转换为时间
for i = 1:size(Data,1)
    for j = 1:length(TimeColIdx)
        Data{i,TimeColIdx(j)} = datetime(Data{i,TimeColIdx(j)},'InputFormat','yyyy/MM/dd HH:mm:ss');
    end
end

%% 按问卷提交时限筛选数据
% 问卷提交时间晚于2021/5/1
Data1 = Data(TimeCols(:,2) > datetime("2021/5/1"),:);

%% 按提交顺序整理数据
results = struct([]);
for i = 1:length(Data1)
    results(i).Teacher = Data1{i,6};
    results(i).Course = Data1{i,7};
    supportIndicatorIdx = [];
    for iGR = 8:19
        if (Data1{i,iGR} ~= "")
            item_GR = strsplit(Data1{i,iGR},";");
            item_GR(item_GR == "") = [];
            UniNums = strtrim(regexp(item_GR,"№\d*.\d*\s",'match'));
            supportIndicatorIdx = [supportIndicatorIdx,cellfun(@(x)find(strcmp(db_Indicators.UniNum,x)),UniNums)];
%             for j = 1:length(item_GR)
%                 UniNum = strtrim(regexp(item_GR(j),"№\d*.\d*\s",'match'));
% %                 UniNum = sscanf(tmp(1),'№%f');
%                 find(strcmp(db_Indicators.UniNum,UniNum))
%                 supportIndicatorIdx = [supportIndicatorIdx,UniNum];
%             end
        end
    end
    results(i).supportIndicators = supportIndicatorIdx;
end