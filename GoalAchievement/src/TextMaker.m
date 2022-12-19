function [texts] = TextMaker(cc,tr,vars,opt)
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
                warning('函数TextMake()输入参数2类型应为Transcript而非%s！',class(tr))
                return
            end
        else
            warning('无函数TextMake()输入参数2！')
            return
        end
        if exist('vars','var') == 1
            if ~any(strcmp(class(vars),{'double','struct'}))
                warning('函数TextMake()输入参数3类型应为double或struct而非%s！',class(vars))
                return
            end
        else
            warning('无函数TextMake()输入参数3！')
            return
        end
        % 检查课程对象中属性Outcomes的尺寸与GAresult一致
        if ~isequal(size(cc.Outcomes,1),size(vars,1))
            warning('课程对象中属性Outcomes的课程目标数目与GAPoints的达成度点数不符！')
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
            texts,tr.Class,Name,mean(vars),ConvertGrade(mean(vars),1));
        if NumReq >= 2
            % 较好的方面
            [bestValue,bestIndex] = max(vars);
            texts = sprintf('%s在本课程所有课程目标中，教学目标“%s”的达成度为较高的%.3f，',...
                texts,cc.Objectives{bestIndex},bestValue);
            texts = sprintf('%s说明本课程对毕业要求指标点“%s”支撑较好；',texts,cc.Outcomes{bestIndex});
            % 较差的方面
            [worstValue,worstIndex] = min(vars);
            texts = sprintf('%s然而，教学目标“%s”的达成度为较低的%.3f，',texts,cc.Objectives{worstIndex},worstValue);
            texts = sprintf('%s说明本课程对毕业要求指标点“%s”支撑较弱，',texts,cc.Outcomes{worstIndex});
            texts = sprintf('%s反映了该项教学目标需要进一步加强。',texts);
        end
        % 持续改进措施
        texts = sprintf('%s通过课间访谈和试后分析，后续课程教学应继续强化教研、教改。',texts);
    case(1)
        texts = '本课程以培养学生能力为目标，按照课程教学大纲的要求，围绕课程目标进行教学设计并实施教学。';
    case(2)
        % 根据指标点获得毕业要求
        idx = fix(str2double(cellfun(@(x)regexp(x,'\d*\.?\d*','match'),cc.Outcomes)));
        catIdx = categories(categorical(idx));
        listStr = sprintf('%s',catIdx{1});
        if length(catIdx) >= 2
            for i = 2:length(catIdx)
                listStr = sprintf('%s、%s',listStr,catIdx{i});
            end
        end
        texts = sprintf('本课程共有%d个课程目标',size(cc.Outcomes,1));
        texts = sprintf('%s，分别支撑毕业要求%s中的相关指标点',texts,listStr);
        texts = sprintf('%s。课程目标与毕业要求及其指标点的对应关系如下表所示。',texts);
    case(3)
        if length(vars.Legend) > 1 % 有历史数据
            nObj = length(vars.xLabel);
            texts = sprintf('%s年度能源化学工程专业的《%s》%d个课程目标达成度分别为：',...
                tr.Class,tr.Name,nObj);
            for i = 1:nObj
                texts = sprintf('%s%.3g、',texts,vars.Data(i,1));
            end
            texts(end) = [];
            texts = sprintf('%s，而%s年度的课程目标达成度分别为：',texts,vars.Legend{2});
            for i = 1:nObj
                texts = sprintf('%s%.3g、',texts,vars.Data(i,2));
            end
            texts(end) = '。';
            alpha = 0.05;
            txt1 = sprintf('假定各年度的课程目标达成度结果均服从正态分布N(mu,sigma2)');
            txt1 = sprintf('%s，由于两个样本不独立，故将两个样本相减后，把两个正态总体均值的比较检验转化为单个正态总体均值的检验',txt1);
            txt1 = sprintf('%s，然后用t函数进行假设检验（alpha=%.2g）',txt1,alpha);
            txt1 = sprintf('%s，结果表明：',txt1);
            texts = [texts,txt1];
            [h,p,muci,stats] = ttest(vars.Data(:,1),vars.Data(:,2),alpha,'both');
            switch h
                case(0)
                    hStr = '本年度课程目标达成度的结果与历史数据相当';
                case(1)
                    hStr = '本年度课程目标达成度的结果不同于历史数据';
            end
            if p > 1-alpha
                txt2 = sprintf('%s，t检验表明p值为%.4g > %.4g，由此说明达成度结果差异存在统计显著性。',hStr,p,1-alpha);
            else
                txt2 = sprintf('%s，t检验表明p值为%.4g < %.4g，由此说明达成度结果差异不存在统计显著性。',hStr,p,1-alpha);
            end
            texts = [texts,txt2];
        else % 无历史数据
            texts = sprintf('%s年度能源化学工程专业的《%s》课程指标点进行了优化调整',tr.Class,tr.Name);
            texts = sprintf('%s，为此相应修改了课程教学目标',texts);
            texts = sprintf('%s,故此本年度的课程目标达成结果并未直接与历史数据进行对比。',texts);
        end
end

