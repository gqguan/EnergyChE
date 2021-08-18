function result = SetLog(app,text)
    txt1 = sprintf('[%s]£º%s',datestr(now,'HH:MM:SS'),char(text));
    oldMsg = app.AppInfo;
    if isempty(oldMsg)
        result = {txt1};
    else
        result = [cellstr(txt1);oldMsg];
    end
    app.AppInfo = result;
end