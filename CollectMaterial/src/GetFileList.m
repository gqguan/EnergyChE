function newFileList = GetFileList(fileList,repoPath,materialType)
% repoPath D:\Repo\
% materialType {'教学大纲';'考核材料';'评价报告'}
% 获取课程列表
lists = dir(repoPath); lists(1:2) = []; lists = lists([lists.isdir]);
listCourse = {lists.name};
newFileList = fileList;
% 以此搜索各课程目录下的文件
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

