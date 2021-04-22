%% 达成度分析文本模板
%
% by Dr. Guan Guoqiang @ SCUT on 2020-06-24

function txtout = EA_TextMaker(QE_Course)
%% 初始化
Name = QE_Course.Name;
NumReq = length(QE_Course.Requirements);
Class = QE_Course.Class;
QEValue = QE_Course.Result;

%% 构造模板文本
% 确定课程对专业人才培养的作用评价字段
if NumReq < 3
    FeatureClass = '基础';
elseif NumReq < 6
    FeatureClass = '重要';
else
    FeatureClass = '十分重要';
end       

% 确定课程教学质量评价字段
if QEValue < 0.6
    QELevel = '不理想';
elseif QEValue < 0.7
    QELevel = '一般';
elseif QEValue < 0.8
    QELevel = '正常';
elseif QEValue < 0.9
    QELevel = '较好';
else
    QELevel = '优秀';
end   

% 课程帽子
Head = sprintf('%s是能源化工专业的必修课。', Name);
% 课程对专业人才培养的作用
Feature = sprintf('本课程支撑了%d个指标点，对本专业人才培养具有%s的作用。', ...
                  NumReq, FeatureClass);
% 课程结果
Result = sprintf('如上表所列，%s级能源化工专业的同学在本课程中的总达成度为%.3f，', ...
                  Class, QEValue);
Result = [Result, sprintf('由此说明本课程教学质量“%s”', QELevel)];
if NumReq >= 3
    ReqEAValues = [QE_Course.Requirements.Result];
    % 较好的方面
    [BestEAValue,BestReqIdx] = max(ReqEAValues);
    Result = [Result, sprintf('，其中指标点“%s”的达成度为最高的%.3f，', ...
                              QE_Course.Requirements(BestReqIdx).Description, BestEAValue)];
    Result = [Result, sprintf('说明教学目标“%s”完成得较好；', ...
                              QE_Course.Requirements(BestReqIdx).Objectives.Description)];
    % 较差的方面
    [WorstEAValue,WorstReqIdx] = min(ReqEAValues);
    Result = [Result, sprintf('而指标点“%s”的达成度得分为较低的%.3f，', ...
                             QE_Course.Requirements(WorstReqIdx).Description, WorstEAValue)];
    Result = [Result, sprintf('反映了教学目标“%s”需要进一步加强', ...
                              QE_Course.Requirements(WorstReqIdx).Objectives.Description)];
end

% 持续改进措施
Improvement = sprintf('。通过课间访谈和试后分析，后续课程教学应继续强化教研、教改。');

%% 输出合成字段
txtout = [Head, Feature, Result, Improvement]; 

end