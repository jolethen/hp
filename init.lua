-- Create a persistent mod storage database for this mod
local storage = core.get_mod_storage()

-- Helper function: Save a player's Max HP to disk
local function save_max_hp(player)
    local name = player:get_player_name()
    local props = player:get_properties()
    -- Save the value to the database file
    storage:set_int("max_hp:" .. name, props.hp_max)
end

-- Helper function: Load a player's Max HP from disk
local function load_max_hp(player)
    local name = player:get_player_name()
    -- Look up their saved value; if they don't have one, fallback to 20 HP
    local saved_max = storage:get_int("max_hp:" .. name)
    
    if saved_max and saved_max > 0 then
        return saved_max
    else
        return 20 
    end
end

-- 1. RESTORE ON JOIN: Apply saved Max HP when the player logs in
core.register_on_joinplayer(function(player)
    local saved_hp = load_max_hp(player)
    
    -- Apply their permanent properties back to their character session
    player:set_properties({ hp_max = saved_hp })
    
    -- Optional: If they just joined, make sure their current health doesn't exceed new max
    if player:get_hp() > saved_hp then
        player:set_hp(saved_hp)
    end
end)

-- 2. THE ITEM REGISTERATION
core.register_craftitem("mymod:vitality_essence", {
    description = "Essence of Vitality\nUse to permanently increase your Max HP!",
    inventory_image = "mymod_vitality_essence.png", -- Replace with your item texture
    stack_max = 99,

    on_use = function(itemstack, user, pointed_thing)
        if not user or not user:is_player() then
            return itemstack
        end

        local player_name = user:get_player_name()

        -- Get current live max HP from properties
        local props = user:get_properties()
        local current_max_hp = props.hp_max or 20

        -- Define the boost amount (2 HP = 1 full heart)
        local hp_boost = 100
        local new_max_hp = current_max_hp + hp_boost

        -- 1. Set the live property for the active session
        user:set_properties({ hp_max = new_max_hp })

        -- 2. Save it directly to the storage database right now
        save_max_hp(user)

        -- Heal the player by the added amount
        local current_hp = user:get_hp()
        user:set_hp(current_hp + hp_boost)

        -- Sound & Chat Alerts
        core.sound_play("player_hp_up", {
            to_player = player_name,
            gain = 1.0,
        }, true)

        core.chat_send_player(player_name, "Your maximum health has permanently increased! New Max HP: " .. new_max_hp)

        -- Consume the item
        itemstack:take_item()
        return itemstack
    end,
})
