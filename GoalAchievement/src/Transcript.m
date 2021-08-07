classdef Transcript
    %TRANSCRIPT 课程成绩单
    
    properties
        Name string % 课程名称
        Code string % 课程代码
        Teacher string % 任课教师
        SN string % 选课代码
        Class string % 学生班级
        Info string 
        Detail table % 成绩单明细表
        Definition struct % 成绩单结构定义
        Descriptions % 成绩单中打分项说明
        VarNames % 成绩单中打分项代号
        SubPoints double % 成绩单分值向量
        Remark % 达成度分析文本
    end
    
    methods
        function obj = Transcript(inputArg)
            %TRANSCRIPT 构造此类的实例
            %   需指明课程名称以构造成绩单对象
            if exist('inputArg','var')
                if isa(inputArg,'Transcript')
                    obj = inputArg;
                elseif ischar(inputArg) || isstring(inputArg)
                    obj.Name = string(inputArg);
                else
                    error('课程名称指定有误')
                end
            else
                error('未指定课程名称')
            end
        end
        
        function obj = set.Definition(obj,evalWays)
            if isa(evalWays,'struct')
                if ~isequal(fieldnames(evalWays),{'Name';'Questions'})
                    warning('输入变量结构与属性Definition的1级设定不符！')
                    return
                else
                    if ~isequal(fieldnames(evalWays(1).Questions),{'Name';'Part'})
                        warning('输入变量结构与属性Definition的2级设定不符！')
                        return
                    else
                        if ~isequal(fieldnames(evalWays(1).Questions(1).Part),{'Name';'Description';'VarName';'FullValue'})
                            warning('输入变量结构与属性Definition的3级设定不符！')
                            return
                        else
                            % 设定属性Definition
                            obj.Definition = evalWays;
                        end
                    end
                end
            else
                warning('属性Definition输入类型应为struct而非%s！',class(evalWays))
            end
        end
        
        function obj = set.Detail(obj,tab)
            if isa(tab,'table')
                obj.Detail = tab;
            else
                warning('属性Detail输入类型应为table')
            end
        end
        
        function str = get.Info(obj)
            t = obj.Detail;
            if ~isempty(t)
                s = summary(t);
                nStudent = s.Class.Size(1);
                text = '';
                for i = 1:length(s.Class.Categories)
                    text = sprintf('%s%s%d份、',text,s.Class.Categories{i},s.Class.Counts(i));
                end
                text(end) = [];
                str = sprintf('%d份成绩单数据（%s）',nStudent,text);                
            end
        end
        
        function classname = get.Class(obj)
            t = obj.Detail;
            if ~isempty(t)
                s = summary(t);
                [~,j] = max(s.Class.Counts);
                str = regexp(s.Class.Categories{j},'\d\d','match');
                if length(str) == 1
                    classname = strcat('20',str{:});
                else
                    classname = strcat(str{:});
                end
            end
        end
        
        function strs = get.Descriptions(obj)
            evalWays = obj.Definition;
            if ~isempty(fieldnames(evalWays)) && ~isempty(obj.Detail)
                j = 1;
                strs = repmat(string,1,width(obj.Detail)-3);
                for iW = 1:length(evalWays)
                    for iQ = 1:length(evalWays(iW).Questions)
                        for iP = 1:length(evalWays(iW).Questions(iQ).Part)
                            strs(j) = evalWays(iW).Questions(iQ).Part(iP).Description;
                            j = j+1;
                        end
                    end
                end
            end
        end
        
        function strs = get.VarNames(obj)
            evalWays = obj.Definition;
            if ~isempty(fieldnames(evalWays)) && ~isempty(obj.Detail)
                j = 1;
                strs = repmat(string,1,width(obj.Detail)-3);
                for iW = 1:length(evalWays)
                    for iQ = 1:length(evalWays(iW).Questions)
                        for iP = 1:length(evalWays(iW).Questions(iQ).Part)
                            strs(j) = evalWays(iW).Questions(iQ).Part(iP).VarName;
                            j = j+1;
                        end
                    end
                end
            end
        end
        
        function values = get.SubPoints(obj)
            evalWays = obj.Definition;
            if ~isempty(fieldnames(evalWays)) && ~isempty(obj.Detail)
                j = 1;
                values = zeros(1,width(obj.Detail)-3);
                for iW = 1:length(evalWays)
                    for iQ = 1:length(evalWays(iW).Questions)
                        for iP = 1:length(evalWays(iW).Questions(iQ).Part)
                            values(j) = evalWays(iW).Questions(iQ).Part(iP).FullValue;
                            j = j+1;
                        end
                    end
                end
            end
        end

    end
end

