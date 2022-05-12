function vRP.index_filter(t, filter)
    local out = nil

    for k,v in pairs(t) do
        if filter(v,k,t) then 
          out = k
          break
        end
    end
    
    return out
end

function vRP.table_filter(t, filter)
    local out = {}

    for k,v in pairs(t) do
        if filter(v,k,t) then 
            out[k] = v
        end
    end
    
    return out
end

function vRP.table_map(t, map)
    local out = {}
  
    for k,v in pairs(t) do
      out[k] = map(v, k, t)
    end
  
    return out
end

function vRP.table_size(t)
    local i = 0

    for k,v in pairs(t) do
        if v ~= nil then i = i+1 end
    end

    return i
end