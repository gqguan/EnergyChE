%% 单一课程质量评价
%
% by Dr. Guan Guoqiang @ SCUT on 2021/3/25

%% 初始化
clear

Years = {'class2014'};
Course = '燃气燃烧与应用（双语）';

load('database.mat','db_Indicators')
load('database.mat','db_Course')

%% 计算课程目标达成度
QE_Courses = cellfun(@(x)EA_Course(Course,x,1),Years);

% %% 计算课程内容综合考核结果
% for i = 1:length(QE_Courses)
%     C2W = logical(QE_Courses(i).RelMatrix.C2W);
%     % 获取教学内容表
%     idx = arrayfun(@(x)contains(x.Name,Course),db_Course);
%     CTab = db_Course(idx).(Years{i}).Contents;
%     Credits = arrayfun(@(x)horzcat(x.EvalWays.FullCredit),QE_Courses(i).Transcript.Definition.EvalTypes,'UniformOutput',false);
%     WeightedCredits = Credits;
%     for j = 1:length(Credits)
%         WeightedCredits{j} = Credits{j}*QE_Courses(i).Transcript.Definition.EvalTypes(j).Weight;
%     end
%     WeightedCredits = [WeightedCredits{:}];
%     Credits = [Credits{:}];
%     Avgs = mean(table2array(QE_Courses(i).Transcript.Detail(:,5:end)));
%     % 计算各课程内容的达成度
%     EValue = zeros(height(CTab),1);
%     for k = 1:height(CTab)
%         Weight = WeightedCredits(C2W(k,:))/sum(WeightedCredits(C2W(k,:)));
%         EValue(k) = [Avgs(C2W(k,:))./Credits(C2W(k,:))]*Weight';
%     end
%     out.(['class',QE_Courses(i).Class]) = [CTab,table(EValue)];
% end
% out1 = out.(Years{1}); out1.Properties.VariableNames{'EValue'} = Years{1};
% for iYear = 2:length(Years)
%     out1 = [out1,out.(Years{iYear})(:,3)];
%     out1.Properties.VariableNames{'EValue'} = Years{iYear};
% end

%% 输出
% 课程目标达成度
EA_Objectives = arrayfun(@(x)[x.Requirements.Result],QE_Courses,'UniformOutput',false);
% bar(vertcat(EA_Objectives{:})');
% UniNums = db_Indicators.UniNum([QE_Courses(1).Requirements.IdxUniNum]);
% set(gca,'XTickLabels',{'[o1]' '[o2]' '[o3]' '[o4]' '[o5]' '[o6]'},'FontName','等线')
% xlabel('课程目标'); ylabel('达成度');
% legend(Years)
% % 课程内容达成度
% EA_Contents = zeros(height(out1),length(Years));
% for iYear = 1:length(Years)
%     EA_Contents(:,iYear) = out1.(Years{iYear});
% end
% bar(EA_Contents);
% set(gca,'XTickLabels',out1.CID,'FontName','等线')
% xlabel('课程内容编号'); ylabel('达成度');
% legend(Years)