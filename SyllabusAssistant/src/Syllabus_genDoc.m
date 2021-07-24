%% 将cc按MS-Word模板生成docName文件
%
% by Dr. Guan Guoqiang @ SCUT on 2021/7/22
function Syllabus_genDoc(cc,docName,flag) 

import mlreportgen.dom.*; 

% 检查输入参数 
if nargin == 3
    if isequal(class(cc),'Course') && or(ischar(docName),isstring(docName)) 
        doc = Document(docName,'docx','syllabus.dotx');
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
        
        rptview(docName, 'docx');
        
    else
        warning('输入参数类型有误')
    end
else
    warning('输入参数不完整')
end

function CombineVCell(cArray,Style)
    import mlreportgen.dom.*
    NRow = size(cArray,1);
    for iRow = 1:NRow
        r = TableRow;
        r.Style = [r.Style Style];
        for iCol = 1:NCol
            if ~isempty(cArray{iRow,iCol})
                content = cArray{iRow,iCol};
                if isnumeric(content) % 数值保留4位有效数字
                    content = num2str(round(content,4,'significant'));
                end
                te = TableEntry(content);
                if NRow ~= 1
                    % 找该列的下一个非空元素的位置
                    for jRow = (iRow+1):NRow
                        NotEmpty = false;
                        if ~isempty(cArray{jRow,iCol})
                            NotEmpty = true;
                            break
                        end
                    end
                    if NotEmpty
                        te.RowSpan = jRow-iRow;
                    else
                        te.RowSpan = jRow-iRow+1;
                    end
                end
                append(r,te);
            end
        end
        append(t,r);
    end
end


end