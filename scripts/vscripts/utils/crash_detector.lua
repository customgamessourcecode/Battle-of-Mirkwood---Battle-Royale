if not debug.bHookIsSet then
    -- 在出bug的时候，将第一行改为 if true then，可以查看程序最后执行的函数是哪个
    -- 如果游戏直接崩溃（连控制台也直接没了），你可以打开mdmp文件，里面有控制台输出记录
    debug.sethook(function(...)
        local info = debug.getinfo(2)
        local src = tostring(info.short_src)
        local name = tostring(info.name)
        if name ~= "__index" and name ~= "nil" then
            print(debug.traceback("Crash detector: ".. src .. " -- " .. name))
        end
    end, "c")
    debug.bHookIsSet = true
end
