% ID2TYPE ����������������TypeID�ֶ�ת��ΪType
% by Dr. Guan Guoqiang @ SCUT on 2022/12/17
function type = ID2Type(id)
    if exist('id','var')
        if isstring(id)
            switch id
                case("1")
                    type = "����������";
                case("2")
                    type = "רҵ������";
                case("3")
                    type = "ѡ�޿�";
                case("4")
                    type = "����ʵ����ѧ";
            end
        else
            error('�����������������ӦΪstring��')
        end
    else
        error('������ID2Type()Ӧ�����������')
    end
