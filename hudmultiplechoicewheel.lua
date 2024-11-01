local function run_if_function(thing)
    if type(thing) == "function" then
        return thing()
    end
    return thing
end

function HUDMultipleChoiceWheel:_create_option_text(index, parent)
    local option_text_params = {
        vertical = "center",
        align = "center",
        layer = 5,
        halign = "left",
        valign = "top",
        name = "text_" .. tostring(self._option_data[index].id),
        font = HUDMultipleChoiceWheel.TEXT_FONT,
        font_size = HUDMultipleChoiceWheel.TEXT_FONT_SIZE,
        -- Dynamic text for some options
---@diagnostic disable-next-line: undefined-field
        text = utf8.to_upper(managers.localization:text(run_if_function(self._option_data[index].text_id))),
        color = HUDMultipleChoiceWheel.TEXT_UNSELECTED_COLOR
    }
    local text = parent:text(option_text_params)
    local _, _, w, h = text:text_rect()

    text:set_w(w + 10)
    text:set_h(h)

    return text
end

function HUDMultipleChoiceWheel:_create_icon(index, parent)
    -- Dynamic icon
    local tweak_data_icon = tweak_data.gui.icons[run_if_function(self._option_data[index].icon)]
    local icon_params = {
        name = "icon_" .. tostring(self._option_data[index].id),
        texture = tweak_data_icon.texture,
        texture_rect = tweak_data_icon.texture_rect,
        color = HUDMultipleChoiceWheel.ICON_UNSELECTED_COLOR
    }
    local icon = parent:bitmap(icon_params)

    return icon
end
