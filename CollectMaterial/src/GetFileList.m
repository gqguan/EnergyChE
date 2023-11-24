function newFileList = GetFileList(fileList,repoPath,materialType)
% ���ϴ��Ŀ¼repoPath D:\Repo\
% materialType {'��ѧ���';'���˲���';'���۱���'}
if exist('fileList','var')
    newFileList = fileList;
    if contains(fileList{1,1},'��')
        classYear = extractBefore(fileList(:,1),'��');
        fileList(:,1) = extractBetween(fileList(:,1),'��','��');
        opt = 1;
    else
        opt = 0;
    end
else
    error('GetFileList()ȱʧ�������fileList')
end
if ~exist('repoPath','var')
    repoPath = 'D:\Repo\';
end
if ~exist('materialType','var')
    materialType = {'��ѧ���';'���˲���';'���۱���'};
end
% ��ȡ���·���µĿγ��б�
lists = dir(repoPath); lists(1:2) = []; lists = lists([lists.isdir]);
listSubmittedCourse = {lists.name};
switch opt
    case(0)
        % �Դ��������γ�Ŀ¼�µ��ļ�
        for i = 1:length(listSubmittedCourse)
            idx = strcmp(listSubmittedCourse{i},fileList(:,1));
%             newFileList{idx,1} = listSubmittedCourse{i}; % �������ò���
            if any(idx)
                for j = 1:length(materialType)
                    currentPath = fullfile(lists(i).folder,lists(i).name,materialType{j});
                    lc = dir(currentPath); lc(1:2) = [];
                    entryHash4L = cellfun(@(x)extractBetween(x,'_','.'),{lc.name});
                    entryClass = cellfun(@(x)extractBetween(...
                        regexp(x,'��\d*��','match'),'��','��'),{lc.name});
                    if ~isempty(entryHash4L)
                        switch opt
                            case(0)
                                entry = entryHash4L;
                                newFileList(idx,j+1) = join(entry,', ');
                            case(1)
                                if contains(classYear,entryClass)
                                    entry = strcat(entryClass,'_',entryHash4L);
                                    newFileList(idx,j+1) = join(entry,', ');
                                end
                        end
                    end
                end
            end
        end
    case(1)
        for i = 1:size(fileList,1)
            idx = strcmp(listSubmittedCourse,fileList{i,1});
            if any(idx)
                k = find(idx);
                for j = 1:length(materialType)
                    currentPath = fullfile(lists(k).folder,lists(k).name,materialType{j});
                    lc = dir(currentPath); lc(1:2) = [];
                    entryHash4L = cellfun(@(x)extractBetween(x,'_','.'),{lc.name});
                    entryClass = cellfun(@(x)extractBetween(...
                        regexp(x,'��\d*��','match'),'��','��'),{lc.name});
                    if ~isempty(entryHash4L) && contains(classYear{i},entryClass)
                        newFileList(i,j+1) = join(entryHash4L,', ');
                    end
                end
            end
        end
end


