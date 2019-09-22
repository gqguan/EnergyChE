%% 按中文描述字段将5分制或2分制统一转化为百分制
function [out_cell_array] = ConvertScale(in_cell_array)
    out_cell_array = in_cell_array;
    out_cell_array(find(strcmp(in_cell_array, '优秀'))) = {'95'};
    out_cell_array(find(strcmp(in_cell_array, '良好'))) = {'85'};
    out_cell_array(find(strcmp(in_cell_array, '中等'))) = {'75'};
    out_cell_array(find(strcmp(in_cell_array, '合格'))) = {'65'};
    out_cell_array(find(strcmp(in_cell_array, '及格'))) = {'65'};
    out_cell_array(find(strcmp(in_cell_array, '不合格'))) = {'55'};
    out_cell_array(find(strcmp(in_cell_array, '不及格'))) = {'55'};
    out_cell_array(find(strcmp(in_cell_array, '通过'))) = {'80'};
    out_cell_array(find(strcmp(in_cell_array, '不通过'))) = {'50'};
end