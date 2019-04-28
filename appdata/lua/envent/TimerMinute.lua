--[[
每分钟会被触发一次的脚本


下面的代码为我当前接待喵逻辑使用的代码，可以重写也可以按自己需求进行更改
详细请参考readme
]]

local time = os.date("*t")

function checkGitHub(url,save)
    local githubRss = apiHttpGet(url)
    if githubRss or githubRss ~= "" then--获取成功的话
        local xml2lua = loadfile(apiGetPath().."/data/app/com.papapoi.ReceiverMeow/lua/require/xml2lua.lua")()
        --Uses a handler that converts the XML to a Lua table
        local handler = loadfile(apiGetPath().."/data/app/com.papapoi.ReceiverMeow/lua/require/xmlhandler/tree.lua")()
        local parser = xml2lua.parser(handler)
        parser:parse(githubRss)
        local lastUpdate = handler.root.feed.updated
        if lastUpdate and lastUpdate ~= apiXmlGet("settings",save) then
            apiXmlSet("settings",save,lastUpdate)
            for i,j in pairs(handler.root.feed.entry) do
                --缩短网址
                local shortUrl = apiHttpPost("https://git.io/create","url="..j.link._attr.href:urlEncode())
                shortUrl = (not shortUrl or shortUrl == "") and j.link._attr.href or "https://biu.papapoi.com/"..shortUrl

                --返回结果
                local toSend = "更新时间(UTC)："..(lastUpdate):gsub("T"," "):gsub("Z"," ").."\r\n"..
                "提交内容："..j.title.."\r\n"..
                "查看变动代码："..shortUrl
                return true,toSend
            end
        end
    end
end


--检查GitHub项目是否有更新
if time.min % 10 == 0 then--十分钟检查一次
    local r,t = checkGitHub("https://github.com/openLuat/Luat_2G_RDA_8955/commits/master.atom","2g")
    if r and t then
        local text = "发现2G lua代码在GitHub上有更新\r\n"..t
        cqSendGroupMessage(952343033, text)
        cqSendGroupMessage(604902189, text)
        cqSendGroupMessage(670342655, text)
    end
    local r4,t4 = checkGitHub("https://github.com/openLuat/Luat_4G_ASR_1802/commits/master.atom","4g")
    if r4 and t4 then
        local text = "发现4G lua代码在GitHub上有更新\r\n"..t4
        cqSendGroupMessage(952343033, text)
        cqSendGroupMessage(604902189, text)
        cqSendGroupMessage(670342655, text)
        cqSendGroupMessage(851800257, text)--4g群
    end
end

