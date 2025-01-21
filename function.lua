code = [[
 function 函数(参数, 爱车)
    print(参数)
    print(参2)
end
函数(1,3)
]]
code = " " .. code
code = code:gsub("%s*,%s*", ",")
for FuncName, Parameter in code:gmatch("function%s+(%S+)%((%S*)%)") do                                                           --替换函数(function关键字前为空格)
    -- print(FuncName, Parameter)
    if Parameter == "" then                                                                                                      --无参数时
        code = code:gsub("function%s+" .. FuncName .. "%(%)", "_ENV[\"" .. FuncName .. "\"]=function()")
        code = code:gsub("%s" .. FuncName .. "(", " _ENV[\"" .. FuncName .. "\"]")                                               --替换调用时函数名(函数名前为空格)
        code = code:gsub(";" .. FuncName .. "(", " _ENV[\"" .. FuncName .. "\"]")                                                --替换调用时函数名(函数名前为;)
    else
        if Parameter == "..." then                                                                                               --可变长参数时
            code = code:gsub("function%s+" .. FuncName .. "%(%)", "_ENV[\"" .. FuncName .. "\"]=function(...)")
            code = code:gsub("%s" .. FuncName .. "(", " _ENV[\"" .. FuncName .. "\"]")                                           --替换调用时函数名(函数名前为空格)
            code = code:gsub(";" .. FuncName .. "(", " _ENV[\"" .. FuncName .. "\"]")                                            --替换调用时函数名(函数名前为;)
            -- TODO: 调用时实参变量替换
        else                                                                                                                     --一般参数时
            code = code:gsub("function%s+" .. FuncName .. "%(" .. Parameter .. "%)",
                "_ENV[\"" .. FuncName .. "\"]=function(_ParameterList)")                                                         --替换函数声明(函数名+行驶参数)
            code = code:gsub("%s" .. FuncName .. "(", " _ENV[\"" .. FuncName .. "\"]")                                           --替换调用时函数名(函数名前为空格)
            code = code:gsub(";" .. FuncName .. "(", " _ENV[\"" .. FuncName .. "\"]")                                            --替换调用时函数名(函数名前为;)
            temp1 = {}                                                                                                           --形参
            temp2 = {}                                                                                                           --实参
            for EachParameter in Parameter:gmatch("([^,]+)%s*,?") do                                                             --截取每个形参名
                -- print(EachParameter)
                -- print(temp)
                code = code:gsub("(" .. EachParameter .. ")", "_ParameterList[\"" .. EachParameter .. "\"]") --替换实际参数
                table.insert(temp1, EachParameter)
            end
            for ActualParameter in code:gmatch("_ENV%[\"" .. FuncName .. "\"%]%((%S+)%)") do --截取实参名
                -- print(EachActualParameter)
                for EachActualParameter in ActualParameter:gmatch("([^,]+)%s*,?") do --截取每个实参名
                    -- print(code)
                    -- print(EachActualParameter)
                    table.insert(temp2, EachActualParameter)
                end
            end
            -- for _,EachParameter in pairs(temp1) do --取出每个形参名
            --             print(EachParameter)
            --         code = code:gsub(EachActualParameter,"{[\""..EachParameter.."\"]="..EachActualParameter.."}") --当格式为 (函数(参数)) 时
            --         end
            --         code = code:gsub(ActualParameter,"{[\""..Parameter.."\"]="..ActualParameter.."}") --当格式为 (函数(参数)) 时
            -- print(code)
            for i = 1, #temp1 do
                -- print(temp1[i], temp2[i])
                for s in code:gmatch("%(%s*" .. temp2[i]) do                --匹配开头
                    code = code:gsub(s, "{[\"" .. temp1[i] .. "\"]=" .. temp2[i]) --TODO: 实参替换为table
                end
                for m in code:gmatch("%s*,%s*" .. temp2[i] .. "%s*,") do
                    code = code:gsub(m, "[\"" .. temp1[i] .. "\"]=" .. temp2[i])
                end
                for e in code:gmatch(temp2[i] .. "%s*%)") do
                    print(code)
                    print("[\"" .. temp1[i] .. "\"]=" .. temp2[i] .. "}")
                    -- BUG
                    -- code = code:gsub(e, "[\"" .. temp1[i] .. "\"]=" .. temp2[i] .. "}")
                end
                -- print(code)
                -- code = code:gsub(","..temp2[i], ",[\""..temp1[i].."\"]="..temp2[i])
                -- code = code:gsub(temp2[i]..")", "[\""..temp1[i].."\"]="..temp2[i].."})")
            end
            temp1 = nil
            temp2 = nil
            --替换调用时实际参数为table的形式:
            -- for ActualParameter in code:gmatch("_ENV%[\""..FuncName.."\"%]%((%S+)%)") do --截取实参名
            --     for _,EachParameter in pairs(temp) do --取出每个形参名
            --         -- print(EachActualParameter)
            --     for EachActualParameter in ActualParameter:gmatch("([^,]+)%s*,?") do --截取每个实参名
            --         print(EachActualParameter)
            --         code = code:gsub(EachActualParameter,"{[\""..EachParameter.."\"]="..EachActualParameter.."}") --当格式为 (函数(参数)) 时
            --     end
            --     end
            --     code = code:gsub(ActualParameter,"{[\""..Parameter.."\"]="..ActualParameter.."}") --当格式为 (函数(参数)) 时
            -- end
        end
    end
end
-- print(code)

-- pcall(load(code))
