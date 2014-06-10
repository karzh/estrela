local M = {}

local function sort_cb(a, b)
    if type(a) == 'number' and type(b) == 'number' then
        return a < b
    else
        return tostring(a) < tostring(b)
    end
end

function M.print(v, max_depth)

    local visited = {}

    local function _pretty_print(name, v, max_depth, path)

        local prefix = string.rep('\t', #path)

        io.write(prefix)
        if name:len() > 0 then
            io.write(name, ' ')
        end

        local type_v = type(v)
        if type_v == 'string' then
            -- спец обработка табуляции для сохранения ее в строке в форме \t
            local s = v:gsub('\t', [[\t]])
            s = string.format('%q', s)
            s = s:gsub([[\\t]], [[\t]])
            io.write(s)
        elseif type_v == 'number' then
            io.write(v)
        elseif type_v == 'boolean' then
            io.write(tostring(v))
        elseif type_v == 'table' then
            local table_id = tostring(v)

            if visited[table_id] then
                io.write('nil --[[recursion to @'..visited[table_id]..']]')
            else
                visited[table_id] = table.concat(path, '.', 2)

                local keys = {}
                local only_numbers = true
                for key, _ in pairs(v) do
                    table.insert(keys, key)
                    only_numbers = only_numbers and (type(key) == 'number')
                end

                if only_numbers then
                    table.sort(keys)
                else
                    table.sort(keys, sort_cb)
                end

                io.write('{\n')
                for _, key in pairs(keys) do
                    local _key = tostring(key)
                    table.insert(path, _key)
                    _pretty_print(_key..' =', v[key], max_depth, path)
                    path[#path] = nil
                end
                io.write(prefix, '}')
            end
        elseif v == nil then
            io.write('nil')
        else
            local _v = (type_v == 'function') and tostring(v) or type_v
            io.write('nil --[[', _v, ']]')
        end

        if #path > 0 then
            io.write(',')
        end

        io.write('\n')
    end

    max_depth = tonumber(depth) or 100

    _pretty_print('', v, max_depth, {})
end

return M