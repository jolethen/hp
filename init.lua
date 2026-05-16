core.register_craftitem("hp:vitality_essence", {
    description = "Essence of Vitality\nUse to permanently increase your Max HP!",
    inventory_image = "mymod_vitality_essence.png", -- Replace with your item texture
    stack_max = 99,

    on_use = function(itemstack, user, pointed_thing)
        -- Ensure a valid player is using the item
        if not user or not user:is_player() then
            return itemstack
        end

        local player_name = user:get_player_name()

        -- Get current max HP from player properties
        local props = user:get_properties()
        local current_max_hp = props.hp_max or 20 -- Default engine fallback is 20

        -- Define the boost amount (2 HP = 1 full heart)
        local hp_boost = 2
        local new_max_hp = current_max_hp + hp_boost

        -- Apply the new permanent Max HP limit
        user:set_properties({ hp_max = new_max_hp })

        -- Heal the player by the same amount so their current health scales up
        local current_hp = user:get_hp()
        user:set_hp(current_hp + hp_boost)

        -- Play a satisfying chime sound to the user
        core.sound_play("player_hp_up", {
            to_player = player_name,
            gain = 1.0,
        }, true)

        -- Notify the player of their new permanent stack total
        core.chat_send_player(player_name, "❤️ Your maximum health has permanently increased! New Max HP: " .. new_max_hp)

        -- Shrink the item stack by 1 and return it to update the inventory slot
        itemstack:take_item()
        return itemstack
    end,
})
