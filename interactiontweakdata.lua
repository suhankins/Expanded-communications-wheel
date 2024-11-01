Hooks:PostHook(InteractionTweakData, "_init_comwheels", "expanded_comm_wheel_init_comwheels", function(self)
    local function custom_com_clbk_dialog(say_target_id, default_say_id, dialog_id)
        local text = nil
        local player = managers.player:player_unit()

        if not alive(player) then
            return
        end

        local target = player:movement():current_state():teammate_aimed_at_by_player()

        if target ~= nil then
            text = say_target_id
        else
            text = default_say_id
        end

        managers.dialog:queue_dialog(dialog_id, {
            skip_idle_check = true,
            instigator = player
        })

        -- This means that messages we send are already localized, so if another
        -- player is playing in another language, they will still see messages in our language.
        -- The only way to fix that would be to have some check if player has my mod, but I don't know
        -- a way to do that yet, so this will do.
        managers.chat:send_message(ChatManager.GAME, "Player", managers.localization:text(text, {
            TARGET = target
        }))
    end

    local function get_closest_interesting_item()
        if #managers.interaction._close_units <= 0 then
            return
        end

        local items_of_interest = {
            folder_outlaw = {
                text_id = "com_wheel_outlaw",
                icon = "missions_consumable_mission",
                clbk_data = {
                    "com_wheel_target_say_outlaw",
                    "com_wheel_say_outlaw",
                    "player_gen_found_it"
                }
            },
            health_bag_big = {
                text_id = "com_wheel_large_medpack",
                icon = "bonus_least_health_lost_small",
                clbk_data = {
                    "com_wheel_target_say_large_medpack",
                    "com_wheel_say_large_medpack",
                    "player_gen_found_it"
                }
            },
            gen_pku_crowbar = {
                text_id = "com_wheel_crowbar",
                icon = "waypoint_special_crowbar",
                clbk_data = {
                    "com_wheel_target_say_crowbar",
                    "com_wheel_say_crowbar",
                    "player_gen_found_it"
                }
            },
            open_crate_3 = {
                text_id = "com_wheel_metal_crate",
                icon = "waypoint_special_crowbar",
                clbk_data = {
                    "com_wheel_target_say_metal_crate",
                    "com_wheel_say_metal_crate",
                    "player_gen_call_help"
                }
            }
        }

        -- We are looping through items first, then interactables,
        -- to maintain priority (i.e. outlaw is more important than crowbar)
        for name, item in pairs(items_of_interest) do
            for _, unit in ipairs(managers.interaction._close_units) do
                if alive(unit) then
                    if name == unit:interaction().tweak_data then
                        return item
                    end
                end
            end
        end

        return nil
    end

    local function custom_com_clbk_item_of_interest()
        local item = get_closest_interesting_item()
        if not item then
            return
        end

---@diagnostic disable-next-line: deprecated
        custom_com_clbk_dialog(unpack(item.clbk_data))
    end

    local function item_of_interest_get_text_id()
        local item = get_closest_interesting_item()
        if not item then
            return "com_wheel_nothing"
        end
        return item.text_id
    end

    local function item_of_interest_get_icon()
        local item = get_closest_interesting_item()
        if not item then
            return "comm_wheel_no"
        end
        return item.icon
    end

    -- Replacing "Enemy" option, because I personally find it useless
    self.com_wheel.options[8].id = "thanks"
    self.com_wheel.options[8].text_id = "com_wheel_thanks"
    self.com_wheel.options[8].icon = "comm_wheel_yes"
    self.com_wheel.options[8].clbk = custom_com_clbk_dialog
    self.com_wheel.options[8].clbk_data = {
        "com_wheel_target_say_thanks",
        "com_wheel_say_thanks",
        "player_gen_thanks"
    }
    table.insert(self.com_wheel.options, {
        id = "item_of_interest",
        text_id = item_of_interest_get_text_id,
        icon = item_of_interest_get_icon,
        color = Color.white,
        clbk = custom_com_clbk_item_of_interest
    })
end)
