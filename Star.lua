if _G.executed then
    for _, info in pairs(_G.trackedESP or {}) do
        if info.text then info.text:Remove() end
        if info.box then info.box:Remove() end
    end
end

_G.executed = true

local config = {
    box = true,
    name = true,
    color = Color3.fromRGB(180, 180, 180)
}

local trackedESP = _G.trackedESP or {}
_G.trackedESP = trackedESP
local last_update = 0
local workspace = workspace or game and game.Workspace or nil
if not workspace then return end

local function scan_workspace()
    local valid = {}
    for _, model in pairs(workspace:GetChildren()) do
        local prompt = model:FindFirstChild("star_mesh.001")
        if prompt then
            local part = model:FindFirstChild("Part")
            if part then
                local addr = tostring(part.Address)
                valid[addr] = true
                if not trackedESP[addr] then
                    local text = Drawing.new("Text")
                    text.Text = "Star Mesh"
                    text.Center = true
                    text.Outline = true
                    text.Color = config.color
                    text.Visible = false

                    local box = Drawing.new("Square")
                    box.Thickness = 1
                    box.Filled = false
                    box.Color = config.color
                    box.Visible = false

                    trackedESP[addr] = {
                        root = part,
                        text = text,
                        box = box
                    }
                end
            end
        end
    end

    for addr, info in pairs(trackedESP) do
        if not valid[addr] then
            if info.text then info.text:Remove() end
            if info.box then info.box:Remove() end
            trackedESP[addr] = nil
        end
    end
end

local function update_esp()
    for _, info in pairs(trackedESP) do
        local root = info.root
        local text = info.text
        local box = info.box

        if root and root.Position then
            local head_pos, on_screen1 = WorldToScreen(root.Position + Vector3.new(0, 2, 0))
            local leg_pos, on_screen2 = WorldToScreen(root.Position - Vector3.new(0, 2, 0))

            if on_screen1 and on_screen2 then
                local h = math.abs(head_pos.Y - leg_pos.Y)
                local w = h / 1.5
                local x = head_pos.X - w / 2
                local y = head_pos.Y

                box.Position = Vector2.new(x, y)
                box.Size = Vector2.new(w, h)
                box.Visible = config.box

                text.Position = Vector2.new(head_pos.X, y - 16)
                text.Visible = config.name
            else
                box.Visible = false
                text.Visible = false
            end
        else
            box.Visible = false
            text.Visible = false
        end
    end
end

scan_workspace()

while true do
    scan_workspace()
    update_esp()
end
