function [out_cell_array] = ConvertScale5to100(in_cell_array)
    out_cell_array = in_cell_array;
    out_cell_array(find(strcmp(in_cell_array, '����'))) = {'95'};
    out_cell_array(find(strcmp(in_cell_array, '����'))) = {'85'};
    out_cell_array(find(strcmp(in_cell_array, '�е�'))) = {'75'};
    out_cell_array(find(strcmp(in_cell_array, '�ϸ�'))) = {'65'};
    out_cell_array(find(strcmp(in_cell_array, '���ϸ�'))) = {'55'};
end