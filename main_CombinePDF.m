%% ��˳�������ļ�
%
% by Dr. Guan Guoqiang @ SCUT on 2020-07-20

%% ��ʼ��
% ��鹤���ռ����޿α�
if ~exist('db_Curriculum','var')
    fprintf('��database.mat������db_Curriculum\n')
    load('database.mat','db_Curriculum')
else
    fprintf('ʹ�õ�ǰ�����ռ��еı���db_Curriculum\n')
end
Courses = db_Curriculum.Name;
FileProp = struct('UID',[],'Name',[]);
FileProps = FileProp;

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

%% ���ļ���ʶ���ļ����ݣ������ļ������Ϊͳһ���ļ�����������ֲ���ʶ����ļ������⣩
if ~isfolder([PathName{:},'output'])
    mkdir([PathName{:},'output'])
end
for iFile = 1:FileNum
    FileProp.UID = sprintf('appx_%d.pdf',iFile);
    FileProp.Name = FileNames{iFile};
    copyfile([PathName{:},FileProp.Name], [PathName{:},'output\',FileProp.UID])
    FileProp.Name(regexp(FileProp.Name,'_')) = []; % �»��߻ᵼ��latex����������
    FileProps(iFile) = FileProp;
end
cd([PathName{:},'output'])

%% ����texԴ����
% ���ļ�
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
fprintf(fileID,'\\lfoot{��������}\n');
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
