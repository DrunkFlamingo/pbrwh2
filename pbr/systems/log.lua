local Log = {};--# assume Log: LOG

Log.lines = {} --: vector<string>
Log.maxLines = 100000;
Log.filePath = "pbr_log.txt";

--v function(str: string)
function Log.write(str)
    if write_log then
        if #Log.lines > Log.maxLines then 
            table.remove(Log.lines, 1);
        end
        
        table.insert(Log.lines, str);

        local file = io.open(Log.filePath,"w+");
        for index, line in ipairs(Log.lines) do 
            file:write(line.."\n");
        end
        
        file:close();
    end
end

return {
    write = Log.write;
}