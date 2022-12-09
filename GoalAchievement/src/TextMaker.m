function [texts] = TextMaker(cc,tr,GAresult,opt)
% 生成达成度分析模板文本
% by Dr. Guan Guoqiang @ SCUT on 2021/8/7
%
% 2022/12/9 添加opt参数输出不同的模板文本
%           opt = 0（缺省值）：输出当前课程达成度情况
%                 1：输出评测依据

% 检查操作参数
if ~exist('opt','var')
    opt = 0; % opt的缺省值
end
%
switch opt
    case(0)
        % 检查输入参数
        if exist('cc','var') == 1
            if ~isequal(class(cc),'Course')
                warning('函数TextMake()输出参数1类型应为Course而非%s！',class(cc))
                return
            end
        else
            warning('无函数TextMake()输出参数1！')
            return
        end
        if exist('tr','var') == 1
            if ~isequal(class(tr),'Transcript')
                warning('函数TextMake()输出参数2类型应为Transcript而非%s！',class(tr))
                return
            end
        else
            warning('无函数TextMake()输出参数2！')
            return
        end
        if exist('GAresult','var') == 1
            if ~isa(GAresult,'double')
                warning('函数TextMake()输出参数3类型应为double而非%s！',class(GAresult))
                return
            end
        else
            warning('无函数TextMake()输出参数3！')
            return
        end
        % 检查课程对象中属性Outcomes的尺寸与GAresult一致
        if ~isequal(size(cc.Outcomes),size(GAresult))
            warning('课程对象中属性Outcomes的尺寸与GAresults不符！')
            return
        end
        Name = cc.Title;
        NumReq = length(cc.Outcomes);
        %
        if NumReq < 3
            FeatureClass = '基础';
        elseif NumReq <= 5
            FeatureClass = '重要';
        else
            FeatureClass = '十分重要';
        end
        % 课程帽子
        texts = sprintf('《%s》是能源化学工程专业的必修课。', Name);
        % 课程对专业人才培养的作用
        texts = sprintf('%s本课程支撑了%d个指标点，对本专业人才培养具有%s的作用。', ...
                          texts, NumReq, FeatureClass);
        % 课程质量评价数据源信息
        texts = sprintf('%s课程质量评价的数据源自%s。',texts,tr.Info);
        % 课程质量总体评价
        texts = sprintf('%s%级《%s》课程目标达成度平均值为%.3f，表明本级课程教学质量“%s”。',...
            texts,tr.Class,Name,mean(GAresult),ConvertGrade(mean(GAresult),1));
        if NumReq >= 2
            % 较好的方面
            [bestValue,bestIndex] = max(GAresult);
            texts = sprintf('%s在本课程所有课程目标中，教学目标“%s”的达成度为较高的%.3f，',...
                texts,cc.Objectives{bestIndex},bestValue);
            texts = sprintf('%s说明本课程对毕业要求指标点“%s”支撑较好；',texts,cc.Outcomes{bestIndex});
            % 较差的方面
            [worstValue,worstIndex] = min(GAresult);
            texts = sprintf('%s然而，教学目标“%s”的达成度为较低的%.3f，',texts,cc.Objectives{worstIndex},worstValue);
            texts = sprintf('%s说明本课程对毕业要求指标点“%s”支撑较弱，',texts,cc.Outcomes{worstIndex});
            texts = sprintf('%s反映了该项教学目标需要进一步加强。',texts);
        end
        % 持续改进措施
        texts = sprintf('%s通过课间访谈和试后分析，后续课程教学应继续强化教研、教改。',texts);
    case(1)
        texts = '本课程以培养学生能力为目标，按照课程教学大纲的要求，围绕课程目标进行教学设计并实施教学。';
end

