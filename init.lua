core.register_craftitem("hp:sky_essence", {
    description = "Sky Essence\nLook up at the sky and use to permanently increase Max HP!",
    inventory_image = "mymod_sky_essence.png", -- Replace with your item texture
    stack_max = 99,

    on_use = function(itemstack, user, pointed_thing)
        -- Ensure it's a real player using it
        if not user or not user:is_player() then
            return itemstack
        end

        -- Check the player's look pitch angle
        -- look_pitch is in radians: negative is UP, positive is DOWN
        -- -1.0 radians is roughly 57 degrees upward
        local pitch = user:get_look_pitch()

        if pitch < -1.0 then
            -- Get the player's current max properties
            local props = user:get_properties()
            local current_max_hp = props.hp_max or 20 -- Fallback to 20 if nil

            -- Increase the Max HP permanently by 2 (1 full heart)
            local new_max_hp = current_max_hp + 2
            user:set_properties({ hp_max = new_max_hp })

            -- Instantly heal the player for the amount gained
            local current_hp = user:get_hp()
            user:set_hp(current_hp + 2)

            -- Play a sound effect only to this player
            core.sound_play("player_hp_up", {
                to_player = user:get_player_name(),
                gain = 1.0,
            }, true)

            -- Send a confirmation message
            core.chat_send_player(user:get_player_name(), "✨ The sky grants you permanent vitality! Max HP increased to " .. new_max_hp .. ".")

            -- Consume 1 item from the stack
            itemstack:take_item()
            return itemstack
        else
            -- If they aren't looking high enough, remind them
            core.chat_send_player(user:get_player_name(), "You must look directly up at the sky to consume this item.")
            return itemstack
        end
    end,
})
