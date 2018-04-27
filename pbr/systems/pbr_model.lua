local regionDetail = require("systems/regionDetail")
local Log = require("systems/log")
local regionManager = {} --# assume regionManager: PBR_MODEL

--creates the RM
--v function() --> PBR_MODEL
function regionManager.new()
    Log.write("RM: regionManager.new() Creating the region Manager")
    local self = {} 
    setmetatable(self, {
        __index = regionManager
    })
    --# assume self: PBR_MODEL

    self.region_details = {} --: vector<REGION_DETAIL>
    self.draw_effects = {} --:map<string, function(rd: REGION_DETAIL)>
    self.building_pool_cap_effects = {m_pool = {}, t_pool = {}, e_pool = {}, s_pool = {} }  --:map<string, map<string, function(count: number) --> number>>
    self.building_pop_cap_effects = {}  --:map<string, function(count: number) --> number>
    self.growth_effects = {} --:map<string, function(count: number) --> number>
    self.population_conditions = {} --: map<string, vector<function(rd: REGION_DETAIL) --> boolean>>
    self.human_factions = {} --: vector<CA_FACTION>

    return self;

end;

--adds a region to the RM
--v function(self: PBR_MODEL, region_detail: REGION_DETAIL)
function regionManager.add_region(self, region_detail)
    local regions_list = self.region_details
    region_detail:register_to_manager(self)
    table.insert(regions_list, region_detail)
end;

--prepares to save the game
--v function(self: PBR_MODEL)
function regionManager.prepare_to_save(self)
    local s = {}
    for i = 1, #self.region_details do
        local rd = self.region_details[i];
        local i = rd:prepare_save_table();
        table.insert(s, i);
    end
end;


--refreshes all data about all regions.
--v function(self: PBR_MODEL)
function regionManager.refresh_all_regions(self)
    for i = 1, #self.region_details do
        local rd = self.region_details[i];
        rd:update_buildings();
        rd:refresh_bundles();
        rd:update_ownership();
    end
end;
---------------------------
--REGION DETAIL RETRIEVAL--
---------------------------

--v function(self: PBR_MODEL, key: string) --> REGION_DETAIL
function regionManager.get_rd(self, key)
    for i = 1, #self.region_details do
        local rd = self.region_details[i];
        if rd.key == key then
            return rd;
        end
    end
    return nil;
end;

--v function(self: PBR_MODEL, faction: CA_FACTION) --> vector<REGION_DETAIL>
function regionManager.get_rd_list_for_faction(self, faction)
    if faction:is_dead() then
        Log.write("GetRDListForFaction() called but the given faction is dead")
        return nil
    end

    local fi = {};
    for i = 1, #self.region_details do
        local rd = self.region_details[i];
        if rd.owning_faction:name() == faction:name() then
            table.insert(fi, rd)
        end
    end
    return fi;
end;


----------------------------
--SCRIPTED EFFECT REGISTRY--
----------------------------



--registers a cap effect for populations.
--v function(self: PBR_MODEL, building: string, quantity: number)
function regionManager.add_pop_cap_effect_for_building(self, building, quantity)
    local capfunction = function(count) new_count = count + quantity return new_count end --:function(count: number) --> number
    local effect_index = self.building_pop_cap_effects;
    effect_index[building] = capfunction;
end;

--registers a cap effect for pools.
--v function(self: PBR_MODEL, building: string, pool_category: string, quantity: number)
function regionManager.add_pool_cap_effect_for_building(self, building, pool_category, quantity)
    local capfunction = function(count) new_count = count + quantity; return new_count end --: function(count: number) --> number
    local effect_index = self.building_pool_cap_effects[pool_category]
    effect_index[building] = capfunction;
end;

--registers a scripted effect callback.
--use this for population changes.
--v function(self: PBR_MODEL, building: string, callback: function(rd: REGION_DETAIL))
function regionManager.add_effect_for_building(self, building, callback)
    local effect_index = self.draw_effects
    effect_index[building] = callback;
end;


--registers a population effect.
--v function(self: PBR_MODEL, min: number, max: number, subculture: string, callback: function(rd: REGION_DETAIL)--> boolean)
function regionManager.add_population_effect(self, min, max, subculture, callback)
    if self.population_conditions[subculture] == nil then
        self.population_conditions[subculture] = {};
        Log.write("setting up a population condition for ["..subculture.."] for the first time.")
    end
    Log.write("New Population Condition for range ["..tostring(min)..">>"..tostring(max).."] and subculture ["..subculture.."]")
    local population_conditions = self.population_conditions[subculture];

    local condition_function = function(rd)
                                    if (rd:get_econ_pop() >= min and rd:get_econ_pop() < max) then
                                        callback(rd) 
                                        return true 
                                    end 
                                    return false 
                                end --: function(rd: REGION_DETAIL) --> boolean
    table.insert(population_conditions, condition_function)
end;


----------------------------------
--Event Based Scripting Commands--
----------------------------------

--v function(self: PBR_MODEL, faction: CA_FACTION)
function regionManager.start_turn_effects(self, faction)
    local region_list = self.get_rd_list_for_faction(self, faction);
    local pop_cap_effects = self.building_pop_cap_effects;
    local pool_cap_effects = self.building_pool_cap_effects;
    local draw_effects = self.draw_effects;


    if region_list == nil then
        Log.write("StartTurnEffects called for ["..faction:name().."] but the faction's rd list is nil, investigate!")
        return;
    end
    Log.write("StartTurnEffects called for ["..faction:name().."]");
    
    for y = 1, #region_list do
        local rd = region_list[y]
        rd:update_buildings()

        nv_pop_cap = 20 --:number
        nv_pool_cap = 0 --:number
        --count the population capacity first.
        for i = 1, #rd.buildings do
            local b = rd.buildings[i]
            local pop_cap_callback = pop_cap_effects[b]
     
            local m_pool_callback = pool_cap_effects.m_pool[b]
            local t_pool_callback = pool_cap_effects.t_pool[b]
            local e_pool_callback = pool_cap_effects.e_pool[b]
            local s_pool_callback = pool_cap_effects.s_pool[b]
            --pop cap
            if is_function(pop_cap_callback) then
                nv_pop_cap = pop_cap_callback(nv_pop_cap)
            end
            --pool caps
            if is_function(m_pool_callback) then
                nv_pool_cap = m_pool_callback(nv_pool_cap)
            end
            if is_function(t_pool_callback) then
                nv_pool_cap = t_pool_callback(nv_pool_cap)
            end
            if is_function(e_pool_callback) then
                nv_pool_cap = e_pool_callback(nv_pool_cap)
            end
            if is_function(s_pool_callback) then
                nv_pool_cap = s_pool_callback(nv_pool_cap)
            end

        end

        --population change needs to go here.
        ----DF:TODO
        
        --religion change also needs to go here.
        --DF:TODO


        --draw effects next. 
        for i = 1, #rd.buildings do
            local b = rd.buildings[i]
            local draw_callback = draw_effects[b]
            if is_function(draw_callback) then
                draw_callback(rd);
            end
        end

        --population condition check last. 
        --clear the bundles and rebuild religion and population bundles.
        ----DF:TODO

    end
    

end;



---------------------------------------------------------------------------------------------------------------------------------------------

return {
    new = regionManager.new()
}