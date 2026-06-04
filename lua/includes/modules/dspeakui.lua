surface.CreateFont("DSpeakUI", {
    font = "Roboto-Bold",
    size = 30
})

surface.CreateFont("DSpeakUI2", {
    font = "Roboto-BoldCondensed",
    size = 20
})

local DPanel

local UIStatusElements = {}

local statusElements = {
    ["server"] = { label = "#dspeak.ui.server" },
    ["gmodpipe"] = { label = "#dspeak.ui.gmodpipe"},
    ["discord"] = { label = "#dspeak.ui.discord"}
}

function drawUI()
    DPanel = vgui.Create("DPanel")
    DPanel:SetPos(10, 30)
    DPanel:SetSize(500, 200)
    DPanel:SetBackgroundColor(Color(0, 0, 0, 200))
    
    local i = 0
    for key, status in pairs(statusElements) do
        i = i + 1
        local top = ((i - 1) * 35) + 10; 

        local DLabel = vgui.Create("DLabel", DPanel)
        DLabel:SetPos(10, top)
        DLabel:SetText(status.label)
        DLabel:SetFont("DSpeakUI")
        DLabel:SizeToContents()

        local statusLabel = vgui.Create("DLabel", DPanel)
        statusLabel:SetPos(160, top + 5)
        local text = status.statusText or "#dspeak.ui.waiting"
        local color = status.statusColor or Color(180, 180, 180, 255)
        statusLabel:SetText(text)
        statusLabel:SetFont("DSpeakUI2")
        statusLabel:SetTextColor(color)
        statusLabel:SizeToContents()

        statusElements[key].element = statusLabel
    end
end


function statusUI(elementID, ok, status)
    local element = statusElements[elementID]

    local color
    if ok then
        color = Color(10, 255, 128, 255)
    else
        color = Color(255, 30, 30, 255)
    end

    if not element.element then
        statusElements[elementID].statusText = status
        statusElements[elementID].statusColor = color

        return
    end
    
    element.element:SetTextColor(color)
    element.element:SetText(status)
    element.element:SizeToContents()
end
