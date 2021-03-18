%% 从指定的EXCEL文件中读入指标点支撑矩阵
%
% by Dr. Guan Guoqiang @ SCUT on 2021-03-11

function sheet = importReqMatrix

% 读入指定的EXCEL文件
raws = imports(@readcell, '读入指标点支撑矩阵');
if length(raws) ~= 1 && ~iscell(raws)
    fprintf('[错误] 读入了多个EXCEL文件！\n')
    return
end
sheet.raw = raws{1};

% 变量名称
sheet.VarName.raw = sheet.raw(1,:);
sheet.VarName.idx = cellfun(@(x)~ismissing(string(x)), sheet.VarName.raw);
sheet.VarName.list = sheet.VarName.raw(sheet.VarName.idx);

% 课程列表
sheet.Course.raw = sheet.raw(:,1);
sheet.Course.idx = cellfun(@(x)~ismissing(string(x)),sheet.Course.raw);
sheet.Course.idx(1) = false; % 第一行为变量名称说明
sheet.Course.list = strip(sheet.Course.raw(sheet.Course.idx),"'"); % 删除字段中的单引号
sheet.Course.list = strip(sheet.Course.list); % 删除字段中的单引号

% 指标点索引号
sheet.indicatorNum.raw = sheet.raw(2,:);
sheet.indicatorNum.idx = cellfun(@(x)~ismissing(string(x)), sheet.indicatorNum.raw);
sheet.indicatorNum.list = cellfun(@(x)sprintf('№%.1f',x),sheet.indicatorNum.raw(sheet.indicatorNum.idx),'UniformOutput',false);

% 指标点支撑课程矩阵
sheet.ReqMatrix = sheet.raw(sheet.Course.idx,sheet.indicatorNum.idx);