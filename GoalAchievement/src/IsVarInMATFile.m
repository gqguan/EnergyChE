% 检查给定路径的MAT文件中是否存在指定名称的变量
function tf = IsVarInMATFile(chkVar,matPathFile)
    savedVars = whos('-file',matPathFile);
    tf = any(strcmp(chkVar,{savedVars.name}));
end

