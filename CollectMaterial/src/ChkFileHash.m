function [info] = ChkFileHash(repoPath)
% 遍历目录列表dirList（cell(n,1)）中的全部文件，校核其中文件名含有hash（后4位）的文件，若不一致则更正之
if ~exist('repoPath','var')
    repoPath = 'D:\Repo\'; % 输入参数缺省值
end
info = sprintf('运行ChkFileHash()\n');
[~, r] = system(strjoin({'dir',repoPath,'/s','/b','/A:D'},' '));
dirList = regexpi(r,'\n','split')';
if iscell(dirList)
    dirNum = length(dirList);
    for i = 1:dirNum
        list = dir(dirList{i});
        idx = ~[list.isdir];
        if any(idx) % 其中包含文件
            listFile = {list(idx).name};
            for j = 1:length(listFile)
                extract = extractBetween(listFile{j},"_",".");
                if strlength(extract) == 4
                    file = fullfile(dirList{i},listFile{j});
                    hash = DataHash(file,'file');
                    if ~strcmp(hash(end-3:end),extract)
                        info = sprintf('%s文件%s哈希码为%s\n',info,file,hash(end-3:end));
                        new = replace(listFile{j},extract,hash(end-3:end));
                        system(strjoin({'ren',file,new},' '));
                    end
                end
            end
        end
    end
    info = sprintf('%s结束ChkFileHash()\n',info);
end
