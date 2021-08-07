function Output = ConvertGrade(Input,opt)
if exist('opt','var') ~= 1
	opt = 0; % 输入参数缺省值
	lvlDescription = {'A','B','C','D','E'};
else
	lvlDescription = {'优秀','良好','中等','合格','不合格'};
end
if isnumeric(Input)
    if Input <= 1
        Input = Input*100;
    end
    if Input >= 90
        Output = lvlDescription{1};
    elseif Input >= 80
        Output = lvlDescription{2};
    elseif Input >= 70
        Output = lvlDescription{3};
    elseif Input >= 60
        Output = lvlDescription{4};
    else
        Output = lvlDescription{5};
    end
elseif ischar(Input)
    switch Input
        case('A')
            Output = 95;
        case('B')
            Output = 85;
        case('C')
            Output = 75;
        case('D')
            Output = 65;
        case('E')
            Output = 55;
        otherwise
            fprintf('【错误】未知输入字符！\n')
            return
    end
elseif isstring(Input)
    if ~ismissing(Input)
        switch Input
            case("A")
                Output = 95;
            case("B")
                Output = 85;
            case("C")
                Output = 75;
            case("D")
                Output = 65;
            case("E")
                Output = 55;
            otherwise
                fprintf('【错误】未知输入字段！\n')
                return
        end
    else
        Output = 0;
    end
end
