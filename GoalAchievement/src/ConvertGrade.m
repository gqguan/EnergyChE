function Output = ConvertGrade(Input,opt)
if exist('opt','var') ~= 1
	opt = 0; % �������ȱʡֵ
	lvlDescription = {'A','B','C','D','E'};
else
	lvlDescription = {'����','����','�е�','�ϸ�','���ϸ�'};
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
            fprintf('������δ֪�����ַ���\n')
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
                fprintf('������δ֪�����ֶΣ�\n')
                return
        end
    else
        Output = 0;
    end
end
