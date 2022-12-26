function newFileList = GetFileList(fileList,repoPath,materialType)
% repoPath D:\Repo\
% materialType {'��ѧ���';'���˲���';'���۱���'}
% ��ȡ�γ��б�
lists = dir(repoPath); lists(1:2) = []; lists = lists([lists.isdir]);
listCourse = {lists.name};
newFileList = fileList;
% �Դ��������γ�Ŀ¼�µ��ļ�
for i = 1:length(listCourse)
    idx = strcmp(listCourse{i},fileList(:,1));
    newFileList{idx,1} = listCourse{i};
    for j = 1:length(materialType)
        currentPath = fullfile(lists(i).folder,lists(i).name,materialType{j});
        lc = dir(currentPath); lc(1:2) = [];
        entry = cellfun(@(x)extractBetween(x,'_','.'),{lc.name});
        if ~isempty(entry)
            newFileList(idx,j+1) = join(entry,', ');
        end
    end
end

