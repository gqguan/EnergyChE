function [out,prompt] = importTranscript(course,filePath)
% 导入成绩单
%   
% 输入参数检查
if exist('course','var') == 0
    warning('函数importTranscript()未指定课程名称作为输入参数1！')
    return
else
    if isa(course,'string') || isa(course,'char')
        out = Transcript(course);
    else
        warning('函数importTranscript()输出参数1类型有误！')
        return
    end
end
if exist('filePath','var') == 0
    [file,path] = uigetfile('*.xlsx','multiselect','off','导入成绩单Excel文件');
    if ~any([path,file]) % 当在文件选取窗中点"取消"终止函数执行
        prompt = '';
        return
    end
    filePath = [path,file];
end
LOT = char(65:65+25);
iLetter1 = 1;
raw = readcell(filePath);
prompt = sprintf('导入文件%s',filePath);
% 学生成绩明细
raw0 = raw(5:end,5:end);
% 成绩数据中文本转数字
idx = cellfun(@(x)~isnumeric(x),raw0);
raw0(idx) = num2cell(str2double(raw0(idx)));
sMat = cellfun(@(x)double(x),raw0);
% 学生信息
Class = categorical(raw(5:end,1)); % 班级
SN = raw(5:end,2); % 学号
Name = raw(5:end,3); % 姓名
% 评测方式
evalWays = struct;
raw1 = string(raw(1:4,5:end));
while ~isempty(raw1)
    iLetter2 = 1;
    idxName1s = ~ismissing(raw1(1,:));
    if sum(idxName1s) >= 2
        range = find(idxName1s,2);
        range(2) = range(2)-1;
    else
        range = [1,size(raw1,2)];
    end
    raw2 = raw1(:,range(1):range(2));
    raw1(:,range(1):range(2)) = [];
    evalWay.Name = raw2(1,1);
    raw2(1,:) = [];
    questions = struct;
    while ~isempty(raw2)
        idxName2s = ~ismissing(raw2(1,:));
        if sum(idxName2s) >= 2
            range = find(idxName2s,2);
            range(2) = range(2)-1;
        else
            range = [1,size(raw2,2)];
        end
        raw3 = raw2(:,range(1):range(2));
        raw2(:,range(1):range(2)) = [];
        question.Name = raw3(1,1);
        part = struct;
        for i = 1:length(raw3(2,:))
            part(i).Name = raw3(2,i);
            if ismissing(part(i).Name)
                part(i).Description = "";
            else
                part(i).Description = strcat("（",part(i).Name,"）");
            end
            if ismissing(question.Name)
                part(i).Description = part(i).Description;
            else
                part(i).Description = strcat(question.Name,part(i).Description);
            end
            part(i).Description = strcat(evalWay.Name,part(i).Description);
            part(i).VarName = sprintf('%s%s%d',LOT(iLetter1),LOT(iLetter2),i);
            part(i).FullValue = str2double(raw3(3,i));
        end
        question.Part = part;
        if isempty(fieldnames(questions))
            questions = question;
        else
            questions = [questions,question];
        end
        iLetter2 = iLetter2+1;
    end
    evalWay.Questions = questions;
    if isempty(fieldnames(evalWays))
        evalWays = evalWay;
    else
        evalWays = [evalWays,evalWay];
    end
    iLetter1 = iLetter1+1;
end
% 生成“统分表”
j = 1;
Descriptions = repmat(string,1,size(sMat,2));
VarNames = repmat(string,1,size(sMat,2));
FullValues = zeros(1,size(sMat,2));
st = struct;
for iW = 1:length(evalWays)
    for iQ = 1:length(evalWays(iW).Questions)
        for iP = 1:length(evalWays(iW).Questions(iQ).Part)
            Descriptions(j) = evalWays(iW).Questions(iQ).Part(iP).Description;
            VarNames(j) = evalWays(iW).Questions(iQ).Part(iP).VarName;
            FullValues(j) = evalWays(iW).Questions(iQ).Part(iP).FullValue;
            st.(VarNames(j)) = sMat(:,j);
            j = j+1;
        end
    end
end
tab = struct2table(st);
tab.Properties.VariableDescriptions = Descriptions;
% 输出
out.Detail = [table(Class,SN,Name),tab];
out.Definition = evalWays;
prompt = sprintf('%s内含%s',prompt,out.Info);

end

