% ID2TYPE 将输入培养方案的TypeID字段转换为Type
% by Dr. Guan Guoqiang @ SCUT on 2022/12/17
function type = ID2Type(id)
    if exist('id','var')
        if isstring(id)
            switch id
                case("1")
                    type = "公共基础课";
                case("2")
                    type = "专业基础课";
                case("3")
                    type = "选修课";
                case("4")
                    type = "集中实践教学";
            end
        else
            error('【错误】输入参数类型应为string！')
        end
    else
        error('【错误】ID2Type()应有输入参数！')
    end
