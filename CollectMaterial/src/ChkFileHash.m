function [info] = ChkFileHash(repoPath)
% ����Ŀ¼�б�dirList��cell(n,1)���е�ȫ���ļ���У�������ļ�������hash����4λ�����ļ�������һ�������֮
if ~exist('repoPath','var')
    repoPath = 'D:\Repo\'; % �������ȱʡֵ
end
info = sprintf('����ChkFileHash()\n');
[~, r] = system(strjoin({'dir',repoPath,'/s','/b','/A:D'},' '));
dirList = regexpi(r,'\n','split')';
if iscell(dirList)
    dirNum = length(dirList);
    for i = 1:dirNum
        list = dir(dirList{i});
        idx = ~[list.isdir];
        if any(idx) % ���а����ļ�
            listFile = {list(idx).name};
            for j = 1:length(listFile)
                extract = extractBetween(listFile{j},"_",".");
                if strlength(extract) == 4
                    file = fullfile(dirList{i},listFile{j});
                    hash = DataHash(file,'file');
                    if ~strcmp(hash(end-3:end),extract)
                        info = sprintf('%s�ļ�%s��ϣ��Ϊ%s\n',info,file,hash(end-3:end));
                        new = replace(listFile{j},extract,hash(end-3:end));
                        system(strjoin({'ren',file,new},' '));
                    end
                end
            end
        end
    end
    info = sprintf('%s����ChkFileHash()\n',info);
end
