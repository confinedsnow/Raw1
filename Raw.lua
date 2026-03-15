local _=string.char local __=string.byte local ___=table.concat
local function _D(s)local r={}for i=1,#s do r[i]=_(__(s,i)-3)end return ___(r)end
local function _E(s)local r={}for i=1,#s do r[i]=_(__(s,i)+3)end return ___(r)end

local _a=game.GetService
local function _b(s)return _a(game,s)end
local _c=_b(_D("Sod|huv"))
local _d=_b(_D("UxqVhuylfh"))
local _e=_c.LocalPlayer
repeat task.wait()until _e.Character and _e.Character:FindFirstChild(_D("KxpdqrlgUrrwSduw"))

local _f=_e.Character
local _g=_f:WaitForChild(_D("KxpdqrlgUrrwSduw"))
local _h=true local _i=true
local _j=Color3.fromRGB(0,120,255)
local _k=0.2

local _l=_e.PlayerGui
local _m=_l:FindFirstChild(_D("GhvbqfJxl"))
if _m then _m:Destroy()end
for _,_n in pairs(workspace:GetChildren())do
    if _n.Name:sub(1,6)==_D("Jkrvw;") or _n.Name:sub(1,6)=="Ghost_" then _n:Destroy()end
end

local _o={}
local _p={}

for _,_q in pairs(_f:GetDescendants())do
    if _q:IsA(_D("EdvhSduw"))and _q.Name~=_D("KxpdqrlgUrrwSduw")then
        local _r=Instance.new(_D("Sduw"))
        _r.Size=_q.Size
        _r.Material=Enum.Material.Neon
        _r.Color=_j
        _r.Transparency=0.4
        _r.CanCollide=false
        _r.Anchored=true
        _r.CastShadow=false
        _r.Name=_D("Jkrvwb").._q.Name
        _r.Parent=workspace
        _o[_q]=_r
    end
end

pcall(function()_g:SetNetworkOwner(_e)end)

local _s
_s=_d.Heartbeat:Connect(function()
    if not _f or not _f.Parent or not _g or not _g.Parent then
        _s:Disconnect()
        for _,_r in pairs(_o)do pcall(function()_r:Destroy()end)end
        return
    end
    local _t=_g.CFrame
    local _u={}
    for _q in pairs(_o)do
        if _q and _q.Parent then _u[_q]=_q.CFrame end
    end
    table.insert(_p,{time=tick(),cframes=_u})
    while _p[1]and tick()-_p[1].time>1 do table.remove(_p,1)end
    if _i then
        local _v=tick()-_k
        local _w=nil
        for _,_x in ipairs(_p)do if _x.time<=_v then _w=_x end end
        if _w then
            for _q,_r in pairs(_o)do
                if _r and _r.Parent and _w.cframes[_q]then
                    _r.CFrame=_w.cframes[_q]
                    _r.Transparency=0.4
                end
            end
        end
    else
        for _,_r in pairs(_o)do
            if _r and _r.Parent then _r.Transparency=1 end
        end
    end
    if _h then
        task.defer(function()
            if _g and _g.Parent then _g.CFrame=_t end
        end)
    end
end)

local _y=Instance.new(_D("VfuhhqJxl"))
_y.ResetOnSpawn=false
_y.Name=_D("GhvbqfJxl")
_y.IgnoreGuiInset=true
_y.Parent=_l

local _z=Instance.new("Frame")
_z.Size=UDim2.new(0,180,0,130)
_z.Position=UDim2.new(0,20,0.5,-65)
_z.BackgroundColor3=Color3.fromRGB(15,15,15)
_z.BorderSizePixel=0
_z.Parent=_y
Instance.new("UICorner",_z).CornerRadius=UDim.new(0,10)

local _A=Instance.new("TextLabel")
_A.Size=UDim2.new(1,0,0,30)
_A.Position=UDim2.new(0,0,0,0)
_A.BackgroundTransparency=1
_A.Text=_D("GHVBQF")
_A.TextColor3=Color3.fromRGB(0,120,255)
_A.Font=Enum.Font.GothamBold
_A.TextSize=16
_A.Parent=_z

local function _B(_C,_Cp,_Cc)
    local _btn=Instance.new("TextButton")
    _btn.Size=UDim2.new(1,-20,0,35)
    _btn.Position=UDim2.new(0,10,0,_Cp)
    _btn.BackgroundColor3=_Cc
    _btn.TextColor3=Color3.new(1,1,1)
    _btn.Text=_C
    _btn.Font=Enum.Font.GothamBold
    _btn.TextSize=14
    _btn.BorderSizePixel=0
    _btn.Parent=_z
    Instance.new("UICorner",_btn).CornerRadius=UDim.new(0,6)
    return _btn
end

local _db=_B(_D("Ghvbqf=#RQ"),32,Color3.fromRGB(0,200,80))
local _gb=_B(_D("Jkrvw=#RQ"),75,Color3.fromRGB(0,120,255))

_db.MouseButton1Click:Connect(function()
    _h=not _h
    _db.Text=_h and _D("Ghvbqf=#RQ")or _D("Ghvbqf=#RII")
    _db.BackgroundColor3=_h and Color3.fromRGB(0,200,80)or Color3.fromRGB(180,50,50)
end)

_gb.MouseButton1Click:Connect(function()
    _i=not _i
    _gb.Text=_i and _D("Jkrvw=#RQ")or _D("Jkrvw=#RII")
    _gb.BackgroundColor3=_i and Color3.fromRGB(0,120,255)or Color3.fromRGB(180,50,50)
end)
