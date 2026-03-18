Bridge = Bridge or {}
Bridge.Utils = Bridge.Utils or {}

function Bridge.Utils.Debug(msg)
    -- FiveM clients don't have access to 'os'. 
    -- We use GetGameTimer() or just omit the timestamp on client.
    local timestamp = ""
    
    if IsDuplicityVersion() then 
        -- Server Side: 'os' is available
        timestamp = os.date("%H:%M:%S")
    else
        -- Client Side: 'os' is nil, so we use a simple string or nothing
        timestamp = "CLIENT" 
    end

    print(("^5[VIKING-DEBUG %s]^7 %s"):format(timestamp, msg))
end
    

-- [[ TABLE MERGE ]]
-- Combines two tables into a new one (shallow merge)
function Bridge.Utils.Merge(a, b)
    local result = {}
    if a then for k, v in pairs(a) do result[k] = v end end
    if b then for k, v in pairs(b) do result[k] = v end end
    return result
end

-- [[ DEEP COPY ]]
-- Recursively clones a table to prevent "Pass by Reference" bugs
function Bridge.Utils.DeepCopy(tbl)
    if type(tbl) ~= "table" then return tbl end
    local copy = {}
    for k, v in pairs(tbl) do
        copy[k] = Bridge.Utils.DeepCopy(v)
    end
    return copy
end

-- [[ STRING TRIMMING ]]
-- Useful for plate numbers and input cleaning
function Bridge.Utils.Trim(s)
    return s:match("^%s*(.-)%s*$")
end

