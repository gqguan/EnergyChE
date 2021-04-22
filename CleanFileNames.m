function CleanFileNames(opt)
%% ��ȡ�ļ����еĿγ�����
% opt = 1 pattern = {'��','��'}
%       2 pattern = '_'
%       3 pattern = {' ','.'}

%% ���ļ�ѡ�񴰣�����������Ҫ������ļ�
[FileNames, PathName] = uigetfile('*.pdf', 'ѡ��PDF�ļ����ļ���Ϊ�ļ����ݣ� ...', 'Multiselect', 'on');
% Note:
% When only one file is selected, uigetfile() will return the char variable
% and lead to the error in [FullPath{:}]. Use cellstr() to ensure the
% variable be as cell objects.
FileNames = cellstr(FileNames);
PathName = cellstr(PathName);
% Get the number of selected file in the dialog windows
FileNum = length(FileNames);

CleanFileNames = cell(size(FileNames));

for i = 1:FileNum
    doClean = false;
    ExtName = FileNames{i}(end-3:end);
    switch opt
        case(1)
            cutstr = strsplit(FileNames{i},{'��','��'});
            if length(cutstr) == 3
                doClean = true;
                CleanFileNames{i} = cutstr{2};
            end
        case(2)
            cutstr = strsplit(FileNames{i},{'_'});
            if length(cutstr) == 2
                doClean = true;
                CleanFileNames{i} = cutstr{1};
            end
        case(3)
            cutstr = strsplit(FileNames{i},{' '});
            if length(cutstr) >= 2
                doClean = true;
                CleanFileNames{i} = cutstr{2}(1:end-4);
            end
    end
    if doClean       
        cprintf('Comments','%s -> %s\n',FileNames{i},CleanFileNames{i})
        movefile([PathName{:},FileNames{i}],[PathName{:},CleanFileNames{i},ExtName]);
    else
        cprintf('Text','%s intact\n',FileNames{i})
    end
end
