classdef Transcript
    %TRANSCRIPT �γ̳ɼ���
    
    properties
        Name string % �γ�����
        Code string % �γ̴���
        Teacher string % �ον�ʦ
        SN string % ѡ�δ���
        Class string % ѧ���༶
        Info string 
        Detail table % �ɼ�����ϸ��
        Definition struct % �ɼ����ṹ����
        Descriptions % �ɼ����д����˵��
        VarNames % �ɼ����д�������
        SubPoints double % �ɼ�����ֵ����
        Remark % ��ɶȷ����ı�
    end
    
    methods
        function obj = Transcript(inputArg)
            %TRANSCRIPT ��������ʵ��
            %   ��ָ���γ������Թ���ɼ�������
            if exist('inputArg','var')
                if isa(inputArg,'Transcript')
                    obj = inputArg;
                elseif ischar(inputArg) || isstring(inputArg)
                    obj.Name = string(inputArg);
                else
                    error('�γ�����ָ������')
                end
            else
                error('δָ���γ�����')
            end
        end
        
        function obj = set.Definition(obj,evalWays)
            if isa(evalWays,'struct')
                if ~isequal(fieldnames(evalWays),{'Name';'Questions'})
                    warning('��������ṹ������Definition��1���趨������')
                    return
                else
                    if ~isequal(fieldnames(evalWays(1).Questions),{'Name';'Part'})
                        warning('��������ṹ������Definition��2���趨������')
                        return
                    else
                        if ~isequal(fieldnames(evalWays(1).Questions(1).Part),{'Name';'Description';'VarName';'FullValue'})
                            warning('��������ṹ������Definition��3���趨������')
                            return
                        else
                            % �趨����Definition
                            obj.Definition = evalWays;
                        end
                    end
                end
            else
                warning('����Definition��������ӦΪstruct����%s��',class(evalWays))
            end
        end
        
        function obj = set.Detail(obj,tab)
            if isa(tab,'table')
                obj.Detail = tab;
            else
                warning('����Detail��������ӦΪtable')
            end
        end
        
        function str = get.Info(obj)
            t = obj.Detail;
            if ~isempty(t)
                s = summary(t);
                nStudent = s.Class.Size(1);
                text = '';
                for i = 1:length(s.Class.Categories)
                    text = sprintf('%s%s%d�ݡ�',text,s.Class.Categories{i},s.Class.Counts(i));
                end
                text(end) = [];
                str = sprintf('%d�ݳɼ������ݣ�%s��',nStudent,text);                
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

