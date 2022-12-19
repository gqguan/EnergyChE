function [texts] = TextMaker(cc,tr,vars,opt)
% ���ɴ�ɶȷ���ģ���ı�
% by Dr. Guan Guoqiang @ SCUT on 2021/8/7
%
% 2022/12/9 ���opt���������ͬ��ģ���ı�
%           opt = 0��ȱʡֵ���������ǰ�γ̴�ɶ����
%                 1�������������

% ����������
if ~exist('opt','var')
    opt = 0; % opt��ȱʡֵ
end
%
switch opt
    case(0)
        % ����������
        if exist('cc','var') == 1
            if ~isequal(class(cc),'Course')
                warning('����TextMake()�������1����ӦΪCourse����%s��',class(cc))
                return
            end
        else
            warning('�޺���TextMake()�������1��')
            return
        end
        if exist('tr','var') == 1
            if ~isequal(class(tr),'Transcript')
                warning('����TextMake()�������2����ӦΪTranscript����%s��',class(tr))
                return
            end
        else
            warning('�޺���TextMake()�������2��')
            return
        end
        if exist('vars','var') == 1
            if ~any(strcmp(class(vars),{'double','struct'}))
                warning('����TextMake()�������3����ӦΪdouble��struct����%s��',class(vars))
                return
            end
        else
            warning('�޺���TextMake()�������3��')
            return
        end
        % ���γ̶���������Outcomes�ĳߴ���GAresultһ��
        if ~isequal(size(cc.Outcomes,1),size(vars,1))
            warning('�γ̶���������Outcomes�Ŀγ�Ŀ����Ŀ��GAPoints�Ĵ�ɶȵ���������')
            return
        end
        Name = cc.Title;
        NumReq = length(cc.Outcomes);
        %
        if NumReq < 3
            FeatureClass = '����';
        elseif NumReq <= 5
            FeatureClass = '��Ҫ';
        else
            FeatureClass = 'ʮ����Ҫ';
        end
        % �γ�ñ��
        texts = sprintf('��%s������Դ��ѧ����רҵ�ı��޿Ρ�', Name);
        % �γ̶�רҵ�˲�����������
        texts = sprintf('%s���γ�֧����%d��ָ��㣬�Ա�רҵ�˲���������%s�����á�', ...
                          texts, NumReq, FeatureClass);
        % �γ�������������Դ��Ϣ
        texts = sprintf('%s�γ��������۵�����Դ��%s��',texts,tr.Info);
        % �γ�������������
        texts = sprintf('%s%����%s���γ�Ŀ���ɶ�ƽ��ֵΪ%.3f�����������γ̽�ѧ������%s����',...
            texts,tr.Class,Name,mean(vars),ConvertGrade(mean(vars),1));
        if NumReq >= 2
            % �Ϻõķ���
            [bestValue,bestIndex] = max(vars);
            texts = sprintf('%s�ڱ��γ����пγ�Ŀ���У���ѧĿ�ꡰ%s���Ĵ�ɶ�Ϊ�ϸߵ�%.3f��',...
                texts,cc.Objectives{bestIndex},bestValue);
            texts = sprintf('%s˵�����γ̶Ա�ҵҪ��ָ��㡰%s��֧�ŽϺã�',texts,cc.Outcomes{bestIndex});
            % �ϲ�ķ���
            [worstValue,worstIndex] = min(vars);
            texts = sprintf('%sȻ������ѧĿ�ꡰ%s���Ĵ�ɶ�Ϊ�ϵ͵�%.3f��',texts,cc.Objectives{worstIndex},worstValue);
            texts = sprintf('%s˵�����γ̶Ա�ҵҪ��ָ��㡰%s��֧�Ž�����',texts,cc.Outcomes{worstIndex});
            texts = sprintf('%s��ӳ�˸����ѧĿ����Ҫ��һ����ǿ��',texts);
        end
        % �����Ľ���ʩ
        texts = sprintf('%sͨ���μ��̸���Ժ�����������γ̽�ѧӦ����ǿ�����С��̸ġ�',texts);
    case(1)
        texts = '���γ�������ѧ������ΪĿ�꣬���տγ̽�ѧ��ٵ�Ҫ��Χ�ƿγ�Ŀ����н�ѧ��Ʋ�ʵʩ��ѧ��';
    case(2)
        % ����ָ����ñ�ҵҪ��
        idx = fix(str2double(cellfun(@(x)regexp(x,'\d*\.?\d*','match'),cc.Outcomes)));
        catIdx = categories(categorical(idx));
        listStr = sprintf('%s',catIdx{1});
        if length(catIdx) >= 2
            for i = 2:length(catIdx)
                listStr = sprintf('%s��%s',listStr,catIdx{i});
            end
        end
        texts = sprintf('���γ̹���%d���γ�Ŀ��',size(cc.Outcomes,1));
        texts = sprintf('%s���ֱ�֧�ű�ҵҪ��%s�е����ָ���',texts,listStr);
        texts = sprintf('%s���γ�Ŀ�����ҵҪ����ָ���Ķ�Ӧ��ϵ���±���ʾ��',texts);
    case(3)
        if length(vars.Legend) > 1 % ����ʷ����
            nObj = length(vars.xLabel);
            texts = sprintf('%s�����Դ��ѧ����רҵ�ġ�%s��%d���γ�Ŀ���ɶȷֱ�Ϊ��',...
                tr.Class,tr.Name,nObj);
            for i = 1:nObj
                texts = sprintf('%s%.3g��',texts,vars.Data(i,1));
            end
            texts(end) = [];
            texts = sprintf('%s����%s��ȵĿγ�Ŀ���ɶȷֱ�Ϊ��',texts,vars.Legend{2});
            for i = 1:nObj
                texts = sprintf('%s%.3g��',texts,vars.Data(i,2));
            end
            texts(end) = '��';
            alpha = 0.05;
            txt1 = sprintf('�ٶ�����ȵĿγ�Ŀ���ɶȽ����������̬�ֲ�N(mu,sigma2)');
            txt1 = sprintf('%s�����������������������ʽ�������������󣬰�������̬�����ֵ�ıȽϼ���ת��Ϊ������̬�����ֵ�ļ���',txt1);
            txt1 = sprintf('%s��Ȼ����t�������м�����飨alpha=%.2g��',txt1,alpha);
            txt1 = sprintf('%s�����������',txt1);
            texts = [texts,txt1];
            [h,p,muci,stats] = ttest(vars.Data(:,1),vars.Data(:,2),alpha,'both');
            switch h
                case(0)
                    hStr = '����ȿγ�Ŀ���ɶȵĽ������ʷ�����൱';
                case(1)
                    hStr = '����ȿγ�Ŀ���ɶȵĽ����ͬ����ʷ����';
            end
            if p > 1-alpha
                txt2 = sprintf('%s��t�������pֵΪ%.4g > %.4g���ɴ�˵����ɶȽ���������ͳ�������ԡ�',hStr,p,1-alpha);
            else
                txt2 = sprintf('%s��t�������pֵΪ%.4g < %.4g���ɴ�˵����ɶȽ�����첻����ͳ�������ԡ�',hStr,p,1-alpha);
            end
            texts = [texts,txt2];
        else % ����ʷ����
            texts = sprintf('%s�����Դ��ѧ����רҵ�ġ�%s���γ�ָ���������Ż�����',tr.Class,tr.Name);
            texts = sprintf('%s��Ϊ����Ӧ�޸��˿γ̽�ѧĿ��',texts);
            texts = sprintf('%s,�ʴ˱���ȵĿγ�Ŀ���ɽ����δֱ������ʷ���ݽ��жԱȡ�',texts);
        end
end

