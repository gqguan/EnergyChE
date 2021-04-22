%% 课程质量评价：教学内容的综合考核结果
%
% by Dr. Guan Guoqiang @ SCUT on 2020-08-26

function EA_Content = EA_EvalMethod1(QE_Course)

% 检查输入参数存在教学内容和考核方法的关系矩阵C2W
if ~any(strcmp(fieldnames(QE_Course.RelMatrix),'C2W'))
    cprintf('err','【错误】输入参数中找不到教学内容和考核方法的关系矩阵C2W！\n')
    return
end
C2W = QE_Course.RelMatrix.C2W;

% 初始化
NumContent = size(C2W,1);
EA_Content = zeros(NumContent,1);

% 获取考核方式代码向量、分值向量和权重向量
Codes = cell(1,sum(QE_Course.Transcript.Definition.Spec));
FullCredits = zeros(size(Codes));
Weights = zeros(size(Codes));
NumType = length(QE_Course.Transcript.Definition.Spec);
iCode_Begin = 1;
for iType = 1:NumType
    iCode_End = iCode_Begin+QE_Course.Transcript.Definition.Spec(iType)-1;
    Codes(iCode_Begin:iCode_End) = {QE_Course.Transcript.Definition.EvalTypes(iType).EvalWays.Code};
    FullCredits(iCode_Begin:iCode_End) = [QE_Course.Transcript.Definition.EvalTypes(iType).EvalWays.FullCredit];
    Weights(iCode_Begin:iCode_End) = [QE_Course.Transcript.Definition.EvalTypes(iType).EvalWays.Weight];
    Weights = Weights*QE_Course.Transcript.Definition.EvalTypes(iType).Weight; % 用考核类型权重修正
    iCode_Begin = iCode_End+1;
end

% 考核得分率
Credits = mean(QE_Course.Transcript.Detail{:,Codes})./FullCredits;

% 分别对各教学内容进行加权平均
for iContent = 1:NumContent
    idxs = logical(C2W(iContent,:));
    CorrectedWeights = Weights(idxs)./sum(Weights(idxs));
    EA_Content(iContent) = sum(Credits(idxs).*CorrectedWeights);
end