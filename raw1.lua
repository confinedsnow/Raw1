local _0x1a2b=string.char local _0x3c4d=table.concat local _0x5e6f=string.byte
local function _0xDEC(_s)local r={}for i=1,#_s do r[i]=string.char(string.byte(_s,i)-3)end return table.concat(r)end
local function _0xENC(_s)local r={}for i=1,#_s do r[i]=string.char(string.byte(_s,i)+3)end return table.concat(r)end

local _={_0xDEC("Sod|huvv"),_0xDEC("UxqVhuylfh"),_0xDEC("WzhhqVhuylfh"),_0xDEC("Sod|huJxl"),_0xDEC("KhduwEhdw"),_0xDEC("KxpdqrlgUrrwSduw"),_0xDEC("Kxpdqrlg")}

local __=game.GetService
local function _G(s)return __(game,s)end

local _a=_G(_[1])
local _b=_G(_[2])
local _c=_G(_[3])

local _d=_a.LocalPlayer
repeat _b.Heartbeat:Wait()_d=_a.LocalPlayer until _d

local _e=_d:WaitForChild(_0xDEC("Sod|huJxl"))
local _f=_e:FindFirstChild(_0xDEC("DxwrWrjjohJxl"))
if _f then _f:Destroy() end

local _h,_i,_j,_k,_l,_m,_n,_o={},{},{},{},{},{},{},{}
local _p=false local _q=false local _r=false
local _s=nil local _t=nil local _u=false local _v=false

local function _w()
    local _x=_d.Character
    return _x and _x:FindFirstChild(_0xDEC("KxpdqrlgUrrwSduw"))
end
local function _y()
    local _x=_d.Character
    return _x and _x:FindFirstChildOfClass(_0xDEC("Kxpdqrlg"))
end

local function _z()
    local _A=_w()
    if not _A then return nil end
    local _B=nil local _C=-1
    for _,_D in ipairs(workspace:GetDescendants())do
        if _D:IsA(_0xDEC("VsdзqOrfdwlrq")) or _D:IsA("SpawnLocation") then
            local _E=(_A.Position-_D.Position).Magnitude
            if _E>_C then _C=_E _B=_D end
        end
    end
    return _B
end

-- GUI construction obfuscated
local _F={}
local _G2=Instance.new
local _H=_0xDEC("VfuhhqJxl")
local _I=_G2(_H)
_I.Name=_0xDEC("DxwrWrjjohJxl")
_I.ResetOnSpawn=not true
_I.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
_I.Enabled=not false
_I.IgnoreGuiInset=not false

local _J=_G2("Frame",_I)
_J.Size=UDim2.new(0,210,0,172)
_J.Position=UDim2.new(0,16,0,50)
_J.BackgroundColor3=Color3.fromRGB(10,12,20)
_J.BorderSizePixel=0
_G2("UICorner",_J).CornerRadius=UDim.new(0,14)

local _K=_G2("Frame",_J)
_K.Size=UDim2.new(1,0,0,3)
_K.BackgroundColor3=Color3.fromRGB(99,179,255)
_K.BorderSizePixel=0
_G2("UICorner",_K).CornerRadius=UDim.new(0,14)

local _L=_G2("UIPadding",_J)
_L.PaddingTop=UDim.new(0,14)
_L.PaddingBottom=UDim.new(0,10)
_L.PaddingLeft=UDim.new(0,12)
_L.PaddingRight=UDim.new(0,12)

local _M=_G2("UIListLayout",_J)
_M.SortOrder=Enum.SortOrder.LayoutOrder
_M.Padding=UDim.new(0,8)

local _N=_c -- TweenService
local function _O(_P,_Q,_R)
    local _S=_G2("TextButton",_J)
    _S.Size=UDim2.new(1,0,0,38)
    _S.BackgroundColor3=Color3.fromRGB(22,26,42)
    _S.TextColor3=Color3.fromRGB(180,195,230)
    _S.Font=Enum.Font.GothamMedium
    _S.TextSize=13
    _S.Text="\x E2\x AC\xA1  ".._P..": OFF"
    _S.Text="⬜  ".._P..": OFF"
    _S.AutoButtonColor=false
    _S.BorderSizePixel=0
    _S.LayoutOrder=_R
    _G2("UICorner",_S).CornerRadius=UDim.new(0,9)
    local _T=_G2("UIStroke",_S)
    _T.Color=Color3.fromRGB(40,50,80)
    _T.Thickness=1
    _S.MouseEnter:Connect(function()
        _N:Create(_T,TweenInfo.new(0.15),{Color=Color3.fromRGB(99,179,255),Transparency=0.4}):Play()
    end)
    _S.MouseLeave:Connect(function()
        _N:Create(_T,TweenInfo.new(0.15),{Color=Color3.fromRGB(40,50,80),Transparency=0}):Play()
    end)
    return _S
end

local _labels={_0xDEC("Dxwr#Uhvhw"),_0xDEC("Dxwr#Uhwxuq"),_0xDEC("Dedqgrqhg#Prgh")}
for i=1,3 do _labels[i]=_labels[i]:gsub("#"," ") end

local _U=_O(_labels[1],nil,1)
local _V=_O(_labels[2],nil,2)
local _W=_O(_labels[3],nil,3)

local function _X(_Y,_Z,_0)
    if _0 then
        _Y.Text="✅  ".._Z..": ON"
        _Y.BackgroundColor3=Color3.fromRGB(20,90,45)
        _Y.TextColor3=Color3.fromRGB(130,255,160)
    else
        _Y.Text="⬜  ".._Z..": OFF"
        _Y.BackgroundColor3=Color3.fromRGB(22,26,42)
        _Y.TextColor3=Color3.fromRGB(180,195,230)
    end
end

_U.MouseButton1Click:Connect(function()_p=not _p _X(_U,_labels[1],_p)end)
_V.MouseButton1Click:Connect(function()_q=not _q _X(_V,_labels[2],_q)end)
_W.MouseButton1Click:Connect(function()_r=not _r _X(_W,_labels[3],_r)_v=false end)

_I.Parent=_e

local _10={}
local function _11()
    for _,c in ipairs(_10)do pcall(function()c:Disconnect()end)end
    _10={}
end

local function _12(_13)
    _11()
    _u=false _v=false
    local _14=_13:WaitForChild(_0xDEC("Kxpdqrlg"),10)
    local _15=_13:WaitForChild(_0xDEC("KxpdqrlgUrrwSduw"),10)
    if not _14 or not _15 then return end
    if _q and _t then
        local _cf=_t _t=nil
        task.defer(function()
            if _15 and _15.Parent then pcall(function()_15.CFrame=_cf end)end
        end)
    else _t=nil end
    _u=true
    table.insert(_10,_b.Heartbeat:Connect(function()
        if _u and _15 and _15.Parent then _s=_15.CFrame end
    end))
    table.insert(_10,_14.HealthChanged:Connect(function(_hp)
        if not _u then return end
        if _p and _hp<=1 then _u=false pcall(function()_14.Health=0 end)return end
        if _r and not _v and _hp<=25 and _hp>0 then
            _v=true
            local _sp=_z()
            if _sp then pcall(function()_15.CFrame=CFrame.new(_sp.Position+Vector3.new(0,5,0))end)end
        end
    end))
    table.insert(_10,_14.Died:Connect(function()
        _u=false
        if _q and _s then _t=_s end
        _v=false
    end))
end

_d.CharacterAdded:Connect(function(_c2)task.spawn(_12,_c2)end)
if _d.Character then task.spawn(_12,_d.Character)end
