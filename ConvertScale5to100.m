function [out_cell_array] = ConvertScale5to100(in_cell_array)
    out_cell_array = in_cell_array;
    out_cell_array(find(strcmp(in_cell_array, '优秀'))) = {'95'};
    out_cell_array(find(strcmp(in_cell_array, '良好'))) = {'85'};
    out_cell_array(find(strcmp(in_cell_array, '中等'))) = {'75'};
    out_cell_array(find(strcmp(in_cell_array, '合格'))) = {'65'};
    out_cell_array(find(strcmp(in_cell_array, '不合格'))) = {'55'};
end