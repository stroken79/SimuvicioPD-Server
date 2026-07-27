function DebugPrint(msg)
    if Config.Debug then
        if msg ~= nil then
            print("["..GetCurrentResourceName().."] "..msg)
        end
    end
end


