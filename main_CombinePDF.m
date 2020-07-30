%% 按顺序命名文件
%
% by Dr. Guan Guoqiang @ SCUT on 2020-07-20

%% 初始化
% 检查工作空间有无课表
if ~exist('db_Curriculum','var')
    fprintf('从database.mat中载入db_Curriculum\n')
    load('database.mat','db_Curriculum')
else
    fprintf('使用当前工作空间中的变量db_Curriculum\n')
end
Courses = db_Curriculum.Name;
FileProp = struct('UID',[],'Name',[]);
FileProps = FileProp;

%% 打开文件选择窗，批量导入需要处理的文件
[FileNames, PathName] = uigetfile('*.pdf', '选择PDF文件（文件名为文件内容） ...', 'Multiselect', 'on');
% Note:
% When only one file is selected, uigetfile() will return the char variable
% and lead to the error in [FullPath{:}]. Use cellstr() to ensure the
% variable be as cell objects.
FileNames = cellstr(FileNames);
PathName = cellstr(PathName);
% Get the number of selected file in the dialog windows
FileNum = length(FileNames);

%% 由文件名识别文件内容，并将文件名另存为统一的文件名（避免出现不可识别的文件名问题）
if ~isfolder([PathName{:},'output'])
    mkdir([PathName{:},'output'])
end
for iFile = 1:FileNum
    FileProp.UID = sprintf('appx_%d.pdf',iFile);
    FileProp.Name = FileNames{iFile};
    copyfile([PathName{:},FileProp.Name], [PathName{:},'output\',FileProp.UID])
    FileProp.Name(regexp(FileProp.Name,'_')) = []; % 下划线会导致latex代码编译出错
    FileProps(iFile) = FileProp;
end
cd([PathName{:},'output'])

%% 生成tex源代码
% 打开文件
fileID = fopen('test.tex','w','native','UTF-8');
fprintf(fileID,'\\documentclass[UTF8]{ctexart}\n');
fprintf(fileID,'\\usepackage{fancyhdr,pdfpages,tocloft}\n');
fprintf(fileID,'\\usepackage[margin=0.5in,bottom=0.75in,top=0.75in]{geometry}\n');
fprintf(fileID,'\\begin{document}\n');
fprintf(fileID,'\\tableofcontents\n');
fprintf(fileID,'\\newpage\n');
fprintf(fileID,'\\pagestyle{fancy}\n');
fprintf(fileID,'\\lhead{}\n');
fprintf(fileID,'\\chead{}\n');
fprintf(fileID,'\\rhead{}\n');
fprintf(fileID,'\\lfoot{附件材料}\n');
fprintf(fileID,'\\cfoot{}\n');
fprintf(fileID,'\\rfoot{\\thepage}\n');
for iFile = 1:FileNum
    fprintf(fileID,'\\clearpage\n');
    fprintf(fileID,'\\phantomsection\n');
    fprintf(fileID,'\\addcontentsline{toc}{section}{%s}\n',FileProps(iFile).Name(1:end-4));
    fprintf(fileID,'\\includepdf[pages={-},pagecommand={}]{%s}\n',FileProps(iFile).UID);
end
fprintf(fileID,'\\end{document}\n');
fclose(fileID);
