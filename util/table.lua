local M = {}

local PP = require('estrela.io.pprint').print

local function wrap_gen_func(gen)
    local gen = coroutine.wrap(gen)

    return setmetatable({}, {
        __index = function(self, key)
            return (key == 'list') and M.list or gen[key]
        end,
        __call = function(...)
            return gen(...)
        end,
    })
end

function M.push(self, ...)
    for _,v in ipairs({...}) do
        table.insert(self, v)
    end
    return self
end

function M.clone(self)
    if type(self) ~= 'table' then
        return self
    end

    local copy = {}
    for k,v in pairs(self) do
        copy[M.clone(k)] = M.clone(v)
    end
    setmetatable(copy, M.clone(getmetatable(self)))

    return copy
end

function M.rep(self, times)
    local t = {}
    while times > 0 do
        table.insert(t, M.clone(self))
        times = times - 1
    end
    return t
end

function M.range(start, stop, step)
    if not stop then
        start, stop = 1, start
    end

    if not step then
        step = start <= stop and 1 or -1
    end

    return wrap_gen_func(function()
        for i = start, stop, step do
            coroutine.yield(i)
        end
    end)
end

function M.join(tbl, sep)
    return table.concat(tbl, sep)
end

function M.len(tbl)
    local cnt = 0
    for _,_ in pairs(tbl) do
        cnt = cnt + 1
    end
    return cnt
end

function M.list(smth)
    local l = {}
    for v in smth do
        table.insert(l, v)
    end
    return l
end

local MT = {
    __index = M,
    __add   = M.push,
    __mul   = M.rep,
}

setmetatable(M, {
    __call = function(cls, ...)
        return setmetatable({}, MT):push(...)
    end,
})

return M