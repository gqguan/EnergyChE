function [texts] = TextMaker(cc,tr,GAresult,opt)
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
        if exist('GAresult','var') == 1
            if ~isa(GAresult,'double')
                warning('����TextMake()�������3����ӦΪdouble����%s��',class(GAresult))
                return
            end
        else
            warning('�޺���TextMake()�������3��')
            return
        end
        % ���γ̶���������Outcomes�ĳߴ���GAresultһ��
        if ~isequal(size(cc.Outcomes),size(GAresult))
            warning('�γ̶���������Outcomes�ĳߴ���GAresults������')
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
            texts,tr.Class,Name,mean(GAresult),ConvertGrade(mean(GAresult),1));
        if NumReq >= 2
            % �Ϻõķ���
            [bestValue,bestIndex] = max(GAresult);
            texts = sprintf('%s�ڱ��γ����пγ�Ŀ���У���ѧĿ�ꡰ%s���Ĵ�ɶ�Ϊ�ϸߵ�%.3f��',...
                texts,cc.Objectives{bestIndex},bestValue);
            texts = sprintf('%s˵�����γ̶Ա�ҵҪ��ָ��㡰%s��֧�ŽϺã�',texts,cc.Outcomes{bestIndex});
            % �ϲ�ķ���
            [worstValue,worstIndex] = min(GAresult);
            texts = sprintf('%sȻ������ѧĿ�ꡰ%s���Ĵ�ɶ�Ϊ�ϵ͵�%.3f��',texts,cc.Objectives{worstIndex},worstValue);
            texts = sprintf('%s˵�����γ̶Ա�ҵҪ��ָ��㡰%s��֧�Ž�����',texts,cc.Outcomes{worstIndex});
            texts = sprintf('%s��ӳ�˸����ѧĿ����Ҫ��һ����ǿ��',texts);
        end
        % �����Ľ���ʩ
        texts = sprintf('%sͨ���μ��̸���Ժ�����������γ̽�ѧӦ����ǿ�����С��̸ġ�',texts);
    case(1)
        texts = '���γ�������ѧ������ΪĿ�꣬���տγ̽�ѧ��ٵ�Ҫ��Χ�ƿγ�Ŀ����н�ѧ��Ʋ�ʵʩ��ѧ��';
end

