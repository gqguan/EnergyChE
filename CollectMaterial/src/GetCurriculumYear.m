%% 计算输入年级学生执行的培养方案年份
% 输入参数类型可以是string、char、double或胞向量
% 输出结果类型与输入一致
%
% by Dr. Guan Guoqiang @ SCUT on 2023/11/28

function curriculumYear = GetCurriculumYear(classList)
    curriculumYear = classList;
    switch class(classList)
        case({'cell','string'})
            for i = 1:length(classList)
                switch classList{i}
                    case({'2017','2018',2017,2018})
                        curriculumYear{i} = '2017';
                    case({'2019','2020',2019,2020})
                        curriculumYear{i} = '2019';
                    case({'2021','2022',2021,2022})
                        curriculumYear{i} = '2021';
                    case({'2023','2024',2023,2024})
                        curriculumYear{i} = '2023';
                end
            end
        case('char')
            for i = 1:size(classList,1)
                switch classList(i,:)
                    case({'2017','2018'})
                        curriculumYear(i,:) = '2017';
                    case({'2019','2020'})
                        curriculumYear(i,:) = '2019';
                    case({'2021','2022'})
                        curriculumYear(i,:) = '2021';
                    case({'2023','2024'})
                        curriculumYear(i,:) = '2023';
                end
            end
        case('double')
            isodd = logical(mod(classList,2)); % 识别奇数元素
            curriculumYear(~isodd) = classList(~isodd)-1;
        otherwise
            error('输入参数类型有误！')
    end