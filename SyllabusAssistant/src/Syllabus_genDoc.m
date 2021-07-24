%% 将cc按MS-Word模板templateFile生成docx文件
%
% by Dr. Guan Guoqiang @ SCUT on 2021/7/22
function [status] = Syllabus_genDoc(cc,templateFile,flag) 

if ismcc || isdeployed
    makeDOMCompilable()
end
import mlreportgen.dom.*; 

% 检查输入参数 
if nargin == 3
    if isequal(class(cc),'Course') && or(ischar(templateFile),isstring(templateFile))
        if exist(templateFile,'file') ~= 2
            status = sprintf('模板“%s”文件不存在！',templateFile);
            return
        end
        doc = Document(cc.FilePath,'docx',templateFile);
        holeId = moveToNextHole(doc); 
        fprintf('Current hole ID: %s\n', holeId);
        textObj = cc.Title;
        append(doc, textObj);

        holeId = moveToNextHole(doc); 
        fprintf('Current hole ID: %s\n', holeId);
        textObj = cc.Code;
        append(doc, textObj);

        holeId = moveToNextHole(doc); 
        fprintf('Current hole ID: %s\n', holeId);
        textObj = cc.Title;
        append(doc, textObj);

        holeId = moveToNextHole(doc); 
        fprintf('Current hole ID: %s\n', holeId);
        textObj = cc.Category;
        append(doc, textObj);

        holeId = moveToNextHole(doc); 
        fprintf('Current hole ID: %s\n', holeId);
        if cc.CompulsoryOrNot
            textObj = "必修";
        else
            textObj = "选修";
        end
        append(doc, textObj);

        holeId = moveToNextHole(doc); 
        fprintf('Current hole ID: %s\n', holeId);
        textObj = cc.ClassHour;
        append(doc, textObj);

        holeId = moveToNextHole(doc); 
        fprintf('Current hole ID: %s\n', holeId);
        textObj = cc.Credits;
        append(doc, textObj);

        holeId = moveToNextHole(doc); 
        fprintf('Current hole ID: %s\n', holeId);
        textObj = cc.Semester;
        append(doc, textObj);

        holeId = moveToNextHole(doc); 
        fprintf('Current hole ID: %s\n', holeId);
        textObj = cc.Language;
        append(doc, textObj);

        holeId = moveToNextHole(doc); 
        fprintf('Current hole ID: %s\n', holeId);
        textObj = string(join(cc.Prerequisites));
        append(doc, textObj);

        holeId = moveToNextHole(doc); 
        fprintf('Current hole ID: %s\n', holeId);
        id_outcome = cell(length(cc.Outcomes),1);
        for i = 1:length(cc.Outcomes)
            append(doc,Paragraph(cc.Outcomes{i}));
            id_outcome(i) = regexp(cc.Outcomes{i},'№\d*.\d','match');
        end

        holeId = moveToNextHole(doc); 
        fprintf('Current hole ID: %s\n', holeId);
        id_objective = cell(length(cc.Objectives),1);
        for i = 1:length(cc.Objectives)
            append(doc,Paragraph(cc.Objectives{i}));
            id_objective(i) = {sprintf('[o%d]',i)};
        end
        % 课程目标与毕业要求指标点的关系矩阵
        append(doc,Paragraph("课程目标与毕业要求的支撑关系如下表所列："));
        ctab1 = cell(length(id_outcome)+1,length(id_objective)+1);
        ctab1{1,1} = '毕业要求指标点';
        ctab1(1,2:end) = id_objective;
        ctab1(2:end,1) = id_outcome;
        ctab1(2:end,2:end) = num2cell(eye(length(id_outcome)));
        t1 = Tab2Worda(ctab1(2:end,:),'关系矩阵表','关系矩阵表',ctab1(1,:));
        append(doc,t1);

        holeId = moveToNextHole(doc); 
        fprintf('Current hole ID: %s\n', holeId);
        for i = 1:length(cc.Description)
            append(doc,Paragraph(cc.Description{i}));
        end

        holeId = moveToNextHole(doc); 
        fprintf('Current hole ID: %s\n', holeId);
        for i = 1:length(cc.Content)
            append(doc,Paragraph(cc.Content{i}));
        end

        holeId = moveToNextHole(doc); 
        fprintf('Current hole ID: %s\n', holeId);
        for i = 1:length(cc.ExpTeach)
            append(doc,Paragraph(cc.ExpTeach{i}));
        end

        holeId = moveToNextHole(doc); 
        fprintf('Current hole ID: %s\n', holeId);
        for i = 1:length(cc.TeachMethod)
            append(doc,Paragraph(cc.TeachMethod{i}));
        end

        holeId = moveToNextHole(doc); 
        fprintf('Current hole ID: %s\n', holeId);
        for i = 1:length(cc.ExamMethod)
            append(doc,Paragraph(cc.ExamMethod{i}));
        end
        append(doc,Paragraph("课程目标评价标准如下表所列："));
        t2head = {'课程目标','优秀','良好','中等','合格','不合格'};
        t2 = Tab2Worda(cc.Benchmark,'关系矩阵表','关系矩阵表',t2head);
        append(doc,t2);

        holeId = moveToNextHole(doc); 
        fprintf('Current hole ID: %s\n', holeId);
        for i = 1:length(cc.Textbook)
            append(doc,Paragraph(cc.Textbook{i}));
        end
        
        holeId = moveToNextHole(doc);
        fprintf('Current hole ID: %s\n', holeId);
        append(doc,Paragraph(flag));

        close(doc);
        
        status = sprintf('成功创建文件“%s.docx”',cc.Title);
        
%         rptview(cc.Title, 'docx');
        
    else
        status = '输入参数类型有误';
        warning('输入参数类型有误')
    end
else
    status = '输入参数不完整';
    warning('输入参数不完整')
end

end