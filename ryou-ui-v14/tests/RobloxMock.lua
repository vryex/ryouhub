local builtinTypeof = typeof
local enum
enum = setmetatable({}, {__index=function(t,k)
    local v = setmetatable({}, {__index=function(i,j) local key=k.."."..j; rawset(i,j,key); return key end})
    rawset(t,k,v); return v
end})
local function numbers(name, parts)
    local mt = { kind = name }
    mt.__index = function(self,key)
        if key=="Magnitude" and name=="Vector2" then return math.sqrt(self.X*self.X+self.Y*self.Y) end
        return mt[key]
    end
    mt.__eq = function(a,b) for _, k in ipairs(parts) do if a[k] ~= b[k] then return false end end; return true end
    local function new(...)
        local fields = {...}
        local result = {}
        for i,k in ipairs(parts) do result[k] = fields[i] or 0 end
        return setmetatable(result, mt)
    end
    mt.__add = function(a,b)
        local r={}; for i,k in ipairs(parts) do r[i]=a[k]+b[k] end; return new(table.unpack(r))
    end
    mt.__sub = function(a,b)
        local r={}; for i,k in ipairs(parts) do r[i]=a[k]-b[k] end; return new(table.unpack(r))
    end
    mt.__div = function(a,b)
        local r={}; for i,k in ipairs(parts) do r[i]=a[k]/b end; return new(table.unpack(r))
    end
    return new, mt
end
local v2 = numbers("Vector2", {"X","Y"})
local col, colMt = numbers("Color3", {"R","G","B"})
local dim, dimMt = numbers("UDim", {"Scale","Offset"})
local dims, dim2Mt = numbers("UDim2", {"X","Y"})
local Vector2 = { new=v2, zero=v2() }
local Color3 = { new=col, fromRGB=function(r,g,b) return col(r/255,g/255,b/255) end }
function Color3.fromHex(s) return Color3.fromRGB(tonumber(s:sub(1,2),16),tonumber(s:sub(3,4),16),tonumber(s:sub(5,6),16)) end
function colMt:ToHex() return string.format("%02X%02X%02X",math.round(self.R*255),math.round(self.G*255),math.round(self.B*255)) end
function colMt:ToHSV()
    local maximum,minimum=math.max(self.R,self.G,self.B),math.min(self.R,self.G,self.B)
    local span=maximum-minimum
    if span==0 then return 0,0,maximum end
    local h
    if maximum==self.R then h=(self.G-self.B)/span
    elseif maximum==self.G then h=2+(self.B-self.R)/span
    else h=4+(self.R-self.G)/span end
    return (h/6)%1,span/maximum,maximum
end
function colMt:Lerp(to,t)
    return col(self.R+(to.R-self.R)*t,self.G+(to.G-self.G)*t,self.B+(to.B-self.B)*t)
end
function Color3.fromHSV(h,s,v)
    local function channel(n)
        local k=(n+h*6)%6
        return v-v*s*math.max(0,math.min(k,4-k,1))
    end
    return col(channel(5),channel(3),channel(1))
end
local ColorSequence={new=function(...) return {...} end}
local NumberSequence={new=function(...) return {...} end}
local ColorSequenceKeypoint={new=function(...) return {...} end}
local UDim = {new=dim}
local UDim2 = {
    new=function(a,b,c,d) return dims(dim(a,b),dim(c,d)) end,
    fromOffset=function(a,b) return dims(dim(0,a),dim(0,b)) end,
    fromScale=function(a,b) return dims(dim(a,0),dim(b,0)) end,
}
local function typeof(x) local m = getmetatable(x); return m and m.kind or builtinTypeof(x) end
local function signal()
    local s = {fn={}}
    function s:Connect(fn)
        local c={}
        self.fn[c]=fn
        function c:Disconnect() s.fn[self]=nil end
        return c
    end
    function s:Once(fn)
        local c
        c=self:Connect(function(...) c:Disconnect(); fn(...) end)
        return c
    end
    function s:Fire(...) for _,fn in pairs(table.clone(self.fn)) do fn(...) end end
    return s
end
local Instance = {}
local properties = {
    InputBegan=true,InputChanged=true,InputEnded=true,WindowFocusReleased=true,
    MouseEnter=true,MouseLeave=true,Activated=true,Focused=true,FocusLost=true,Destroying=true,
}
local guiTypes = {Frame=true,CanvasGroup=true,TextButton=true,TextBox=true,TextLabel=true,ImageLabel=true,ScrollingFrame=true}
function Instance.new(class)
    local o = {ClassName=class, _props={Position=UDim2.new(),AbsoluteSize=v2(800,600),AbsolutePosition=v2(),ScrollingEnabled=true,Text="",CanvasPosition=v2(),AbsoluteCanvasSize=v2(800,600),AbsoluteWindowSize=v2(800,600)},
        _events={}, _children={}, _attributes={} }
    function o:IsA(name) return name == class or (name == "GuiObject" and guiTypes[class]) end
    function o:SetAttribute(key,value) self._attributes[key]=value end
    function o:GetAttribute(key) return self._attributes[key] end
    function o:GetChildren() return table.clone(self._children) end
    function o:FindFirstChild(name)
        for _, child in ipairs(self._children) do if child.Name==name then return child end end
    end
    function o:GetDescendants()
        local out={}
        for _, child in ipairs(self._children) do
            table.insert(out,child)
            for _, grand in ipairs(child:GetDescendants()) do table.insert(out,grand) end
        end
        return out
    end
    function o:GetPropertyChangedSignal(name)
        local key = "property-"..name
        if not self._events[key] then self._events[key]=signal() end
        return self._events[key]
    end
    function o:IsFocused() return false end
    function o:Destroy()
        self.Destroying:Fire()
        for _, c in ipairs(self:GetChildren()) do c:Destroy() end
        self.Parent=nil
    end
    return setmetatable(o,{
        __index=function(t,k)
            if properties[k] then
                if not t._events[k] then t._events[k]=signal() end
                return t._events[k]
            end
            return t._props[k]
        end,
        __newindex=function(t,k,v)
            if k == "Parent" then
                local parent = t._props.Parent
                if parent then table.remove(parent._children,table.find(parent._children,t)) end
                if v then table.insert(v._children,t) end
            end
            local changed=t._props[k]~=v
            t._props[k]=v
            if changed then t:GetPropertyChangedSignal(k):Fire() end
        end,
    })
end
local playerGui = Instance.new("PlayerGui")
local input = Instance.new("UserInputService")
function input:GetFocusedTextBox() return nil end
local services = {
    Players={LocalPlayer={WaitForChild=function() return playerGui end}},
    UserInputService=input,
    TweenService={Create=function(_,object,_,goal)
        local t={Completed=signal()}
        function t:Play() for k,v in pairs(goal) do object[k]=v end; self.Completed:Fire(enum.PlaybackState.Completed) end
        function t:Cancel() end
        function t:Destroy() end
        return t
    end},
}
local TweenInfo={new=function(...) return {...} end}
local task={defer=function(fn) return coroutine.create(fn) end,delay=function(_,fn) return coroutine.create(fn) end,cancel=coroutine.close}
local game = {GetService=function(_,name) return services[name] end}
local Enum=enum
local warn=print
local Vector3={new=function(...) return {...} end}
dim2Mt.__add=function(a,b) return dims(a.X+b.X,a.Y+b.Y) end
dim2Mt.__sub=function(a,b) return dims(a.X-b.X,a.Y-b.Y) end
