local beeTD = {
    Name = "Part",
    Color = Color3.fromRGB(180, 180, 180),
    Tab = "BEE",
    Text = "Show Bee",
    StateKey = "BeeEnabled",
    ModeKey = "BeeMode",
    FillTrans = 0.05
}

local ESP_FOLDER = Instance.new("Folder")
ESP_FOLDER.Name = "BeeESP"
ESP_FOLDER.Parent = workspace

local objectESPCache = {}

local function applyBeeESP(part)
    if not State.BeeEnabled then return end
    if objectESPCache[part] then return end

    local mode = State.BeeMode
    if mode == "Box" then
        local outline = Instance.new("BoxHandleAdornment", ESP_FOLDER)
        outline.Adornee = part
        outline.AlwaysOnTop = true
        outline.Size = part.Size + Vector3.new(0.5, 0.5, 0.5)
        outline.Transparency = 0
        outline.Color3 = Color3.new(0, 0, 0)
        outline.ZIndex = 4

        local fill = Instance.new("BoxHandleAdornment", ESP_FOLDER)
        fill.Adornee = part
        fill.AlwaysOnTop = true
        fill.Size = part.Size
        fill.Transparency = beeTD.FillTrans
        fill.Color3 = beeTD.Color
        fill.ZIndex = 5

        objectESPCache[part] = fill
        objectESPCache[outline] = outline

        part.AncestryChanged:Connect(function()
            if not part:IsDescendantOf(workspace) then
                if outline and outline.Parent then outline:Destroy() end
                if fill and fill.Parent then fill:Destroy() end
                objectESPCache[part] = nil
                objectESPCache[outline] = nil
            end
        end)
    else
        applyObjectESP(part, beeTD)
    end
end

local function scanBee()
    if not State.BeeEnabled then return end
    for _, model in ipairs(workspace:GetChildren()) do
        if model.Name == "Bee" then
            local root = model:FindFirstChild("Root")
            local torso = model:FindFirstChild("torso")
            if root and torso then
                local part = torso
                if not objectESPCache[part] then
                    applyBeeESP(part)
                end
            end
        end
    end
end

local function watchBee()
    workspace.ChildAdded:Connect(function(model)
        task.wait(0.1)
        if model.Name == "Bee" then
            local root = model:FindFirstChild("Root")
            local torso = model:FindFirstChild("torso")
            if root and torso then
                local part = torso
                if part and State.BeeEnabled then
                    applyBeeESP(part)
                end
            end
        end
    end)
end

local function refreshObjects()
    for part, esp in pairs(objectESPCache) do
        if esp and esp.Parent then esp:Destroy() end
    end
    objectESPCache = {}
    initialScan()
    scanBee()
end
