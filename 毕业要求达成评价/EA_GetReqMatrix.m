%% ������ӱ���еġ��γ̾������ݲ���������ݱȽ�
% ���ڴ����µ��ӱ�������ݵĽű�:
%
%    ������: C:\Users\gqgua\Documents\WXWork\1688853243457453\WeDrive\��������ѧ\��Դ��ѧ����רҵ\��ɶȷ���С��\�γ�һ����.xlsx
%    ������: 2014
%
% Ҫ��չ�����Թ�����ѡ�����ݻ��������ӱ��ʹ�ã������ɺ���������ű���

% �� MATLAB �Զ������� 2020/07/09 10:09:46

function db_Curriculum = EA_GetReqMatrix(pathFile,worksheet,areaLoc)
if ~exist('pathFile','var')
    pathFile = 'C:\Users\gqgua\Documents\WXWork\1688853243457453\WeDrive\��������ѧ\��Դ��ѧ����רҵ\��ɶȷ���С��\�γ�һ����.xlsx';
    worksheet = '2014';
    areaLoc = 'G4:AP59';
end
%% ���롰�γ̾���
% ��΢��ȱʡĿ¼λ�ö���ָ����excel�ļ�
[~, ~, raw] = xlsread(pathFile,worksheet,areaLoc);
ReqMatrix = reshape([raw{:}],size(raw));
% �����ʱ����
clearvars raw;

%% ������̵ġ��γ̾�������
if exist('db_Curriculum','var')
    fprintf('����ʾ�����ù����ռ��е�db_Curriculum������\n')
else
    fprintf('����ʾ�����ļ�database.mat�е���db_Curriculum������\n')
    load('database.mat', 'db_Curriculum')
end

load('database.mat', 'db_Indicators')

%% ����Ҫ���õ������ݸ��´�������
% �ȽϿγ̾���ߴ�
if isequal(size(ReqMatrix),size(db_Curriculum.ReqMatrix))
    fprintf('����ʾ���γ̾���ߴ�һ�¡�\n')
else
    cprintf('err', '�����󡿿γ̾���ߴ粻һ�£�\n')
    return
end
% ���γ��б�˳��Ƚ�ָ���֧�Ź�ϵ�Ƿ�����ӱ��һ��
NumCourse = height(db_Curriculum);
idxs_Updating = false(NumCourse,1);
for idx = 1:NumCourse
    if ~isequal(db_Curriculum.ReqMatrix(idx,:),ReqMatrix(idx,:))
        idxs_Updating(idx) = true;
        prompt1 = sprintf('�γ�%02d��%s��֧��ָ��㣺', idx, db_Curriculum.Name{idx});
        cprintf('Comments', prompt1)
        idxs = find(db_Curriculum.ReqMatrix(idx,:)-ReqMatrix(idx,:));
        UniNums = db_Indicators.UniNum(idxs);
        prompt2 = '';
        for iUN = 1:length(UniNums)
            prompt2 = sprintf('%s%s��', prompt2, UniNums{iUN});
        end
        prompt2 = [prompt2(1:end-1) 'δ���£�\n'];
        cprintf('Text',prompt2)
    end
end
% �û�ȷ���Ƿ����db_Curriculum�еĿγ̾���
if any(idxs_Updating)
    flag1 = input('ȷ���Ƿ����db_Curriculum�еĿγ̾���[Y/N/A]','s');
    switch flag1
        case('Y')
            fprintf('�����������δ���¿γ�\n')
            idxs_Updating = find(idxs_Updating);
            for idx = 1:length(idxs_Updating)
                iCourse = idxs_Updating(idx);
                prompt1 = sprintf('ȷ���Ƿ񽫿γ�%02d��%s��֧��ָ��㣺', iCourse, db_Curriculum.Name{iCourse});
                cprintf('Comments', prompt1)
                UniNums_Old = db_Indicators.UniNum(logical(db_Curriculum.ReqMatrix(iCourse,:)));
                prompt2 = '';
                for iUN = 1:length(UniNums_Old)
                    prompt2 = sprintf('%s%s��', prompt2, UniNums_Old{iUN});
                end
                prompt2 = [prompt2(1:end-1) '����Ϊ'];
                UniNums_New = db_Indicators.UniNum(logical(ReqMatrix(iCourse,:)));
                for iUN = 1:length(UniNums_New)
                    prompt2 = sprintf('%s%s��', prompt2, UniNums_New{iUN});
                end
                prompt2 = [prompt2(1:end-1) '[Y/N]'];
                flag2 = input(prompt2,'s');
                switch flag2
                    case('Y')
                        fprintf('�Ѹ��¿γ̡�\n')
                        db_Curriculum.ReqMatrix(iCourse,:) = ReqMatrix(iCourse,:);
                    case('N')
                        fprintf('�����¸ÿγ̡�\n')
                end
            end
        case('N')
            fprintf('�ݲ���������δ���¿γ�\n')
        case('A')
            fprintf('ȫ����������δ���¿γ�\n')
            db_Curriculum.ReqMatrix(idxs_Updating,:) = ReqMatrix(idxs_Updating,:);
    end
else
    cprintf('Comments', 'database.mat��db_Curriculum�Ŀγ̾�����Excel������һ�¡�\n')
end
