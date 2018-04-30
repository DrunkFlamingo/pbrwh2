local Log = require("systems/log")
local regionDetail = {}--# assume regionDetail: REGION_DETAIL



------------------------
--REGION DETAIL OBJECT--
------------------------

--add a new regionDetail Object
--v function(info: map<string, WHATEVER>) --> REGION_DETAIL
function regionDetail.new(info)
    Log.write("RegionDetail.new() called for ["..info.key.."]")
    local self = {};
    setmetatable(self, {
        __index = regionDetail
    })--# assume self: REGION_DETAIL

    local region = get_region(info.key)

    local settlement = region:settlement()
    local is_abandoned = region:is_abandoned()
    local owning_faction = region:owning_faction()
    local owning_subculture = owning_faction:subculture()
    local climate = settlement:get_climate()
    



    self.province = info.province --:string
    self.key = info.key --:string
    self.region = region --:CA_REGION
    self.settlement = settlement --: CA_SETTLEMENT
    self.is_abandoned = is_abandoned --: boolean
    self.owning_faction = owning_faction --: CA_FACTION
    self.owning_subculture = owning_subculture --: string
    self.climate = climate --: string
    self.migration = info.migration --: boolean
    self.tax_level = info.tax_level --:number
    self.e_pop = info.e_pop --:number
    self.a_pop = info.a_pop --:number
    self.pop_cap = info.pop_cap --:number
    self.m_pool = info.m_pool --: number
    self.t_pool = info.t_pool --: number
    self.e_pool = info.e_pool --: number
    self.s_pool = info.s_pool --: number
    self.m_cap = info.m_cap --: number
    self.t_cap = info.t_cap --: number
    self.e_cap = info.e_cap --:number
    self.s_cap = info.s_cap --:number
    self.religion = info.religion --: vector<map<string, WHATEVER>>
    --{relgion_str_lookup = "", quantity = num}
    self.buildings = info.buildings --: vector<string>
    self.bundles = info.bundles --: vector<string>
    self.region_manager = nil --: PBR_MODEL

    return self;
end

--register the region detail to the region manager
--v function(self: REGION_DETAIL, manager: PBR_MODEL)
function regionDetail.register_to_manager(self, manager)
    self.region_manager = manager;
    Log.write("RegisterToManager added ["..self.key.."] to the RM")
end;

--v function(self: REGION_DETAIL) --> map<string, WHATEVER>
function regionDetail.prepare_save_table(self)
    i = {}
    i.key = self.key --:string
    i.province = self.province --:string
    i.migration_restricted = self.migration --: boolean
    i.tax_level = self.tax_level --: number
    i.e_pop = self.e_pop --:number
    i.a_pop = self.a_pop --:number
    i.pop_cap = self.pop_cap --:number
    i.m_pool = self.m_pool --: number
    i.t_pool = self.t_pool --: number
    i.e_pool = self.e_pool --: number
    i.s_pool = self.s_pool --: number
    i.m_cap = self.m_cap --: number
    i.t_cap = self.t_cap --: number
    i.e_cap = self.e_cap --: number
    i.s_cap = self.s_cap --: number
    i.religion = self.religion --:vector<map<string, WHATEVER>>
    i.buildings = self.buildings --: vector<string>
    i.bundles = self.bundles  --:vector<string>

    return i;

end;


--------------------------
--Data Retrieval Methods--
--------------------------

--v function(self: REGION_DETAIL) --> CA_FACTION
function regionDetail.get_owner(self)
    return self.owning_faction;
end

--v function(self: REGION_DETAIL) --> string
function regionDetail.get_subculture(self)
    return self.owning_subculture;
end;

--v function(self: REGION_DETAIL) --> string
function regionDetail.get_climate(self)
    return self.climate;
end

--v function(self: REGION_DETAIL) --> CA_SETTLEMENT
function regionDetail.get_settlement(self)
    return self.settlement;
end;


--v function(self: REGION_DETAIL) --> number
function regionDetail.get_econ_pop(self)
    return self.e_pop;
end;

--v function(self: REGION_DETAIL) --> number
function regionDetail.get_admin_pop(self)
    return self.a_pop;
end;


--v function(self: REGION_DETAIL) --> number
function regionDetail.get_m_pool(self)
    return self.m_pool;
end;

--v function(self: REGION_DETAIL) --> number
function regionDetail.get_t_pool(self)
    return self.t_pool;
end;

--v function(self: REGION_DETAIL) --> number
function regionDetail.get_e_pool(self)
    return self.e_pool;
end;
--v function(self: REGION_DETAIL) --> number
function regionDetail.get_s_pool(self)
    return self.s_pool;
end;

--v function(self: REGION_DETAIL) --> boolean
function regionDetail.has_relgion(self)
    return not self.religion == {};
end

--v function(self: REGION_DETAIL) --> boolean
function regionDetail.migration_status(self)
    return self.migration;
end;

--v function(self: REGION_DETAIL) --> number
function regionDetail.tax_rate(self)
    return self.tax_level;
end;

--v function(self: REGION_DETAIL) --> vector<string>
function regionDetail.get_buildings(self)
    return self.buildings
end;

--v function(self: REGION_DETAIL) --> string
function regionDetail.get_province(self)
    return self.province;
end;

--v function(self: REGION_DETAIL) --> boolean
function regionDetail.can_recruit_m_pool(self)
    if self.m_pool > 100 then
        return true;
    else
        return false
    end
end

--v function(self: REGION_DETAIL) --> boolean
function regionDetail.can_recruit_t_pool(self)
    if self.t_pool > 100 then
        return true;
    else
        return false
    end
end

--v function(self: REGION_DETAIL) --> boolean
function regionDetail.can_recruit_e_pool(self)
    if self.e_pool > 100 then
        return true;
    else
        return false
    end
end

--v function(self: REGION_DETAIL) --> boolean
function regionDetail.can_recruit_s_pool(self)
    if self.s_pool > 100 then
        return true;
    else
        return false
    end
end




-----------------------
--Information Storage--
-----------------------


--update the buildings registered to the region detail object.
--v function(self: REGION_DETAIL)
function regionDetail.update_buildings(self)
    local region = self.region;
    Log.write("UpdateBuildings() called for ["..self.key.."]");
    local slot_list = region:slot_list()
    self.buildings = {};
    for k = 0, slot_list:num_items() - 1 do
        local slot = slot_list:item_at(k)
        if slot:has_building() then
            local building = slot:building():name()
            table.insert(self.buildings, building)
            Log.write("UpdateBuildings() adding building ["..building.."] to the building list for ["..self.key.."] ")
        end
    end

end;

--update the ownership data registered to the region detail object
--v function(self: REGION_DETAIL)
function regionDetail.update_ownership(self)
    local region = self.region;
    Log.write("UpdateOwnership() called for ["..self.key.."] ");
    local is_abandoned = region:is_abandoned()
    local owning_faction = region:owning_faction()
    local owning_subculture = owning_faction:subculture()

    self.is_abandoned = is_abandoned
    self.owning_faction = owning_faction 
    self.owning_subculture = owning_subculture 
end;
---------------------
--Bundle Management--
---------------------

--order the bundles stored to the regionDetail to activate.
--v function(self: REGION_DETAIL)
function regionDetail.add_bundles(self)
    for i = 1, #self.bundles do
        cm:apply_effect_bundle_to_region(self.bundles[i], self.key, 0)
    end
end



--strip the region of all PBR registered effect bundles and then reactivate them.
--v function(self: REGION_DETAIL)
function regionDetail.refresh_bundles(self)
    Log.write("Refreshing bundles for ["..self.key.."]")
    for i = 1, #self.bundles do
        cm:remove_effect_bundle_from_region(self.bundles[i], self.key)
    end
    self.add_bundles(self);
end

--add a temporary bundle to a region. This will be removed on the next time the region refreshes its bundle list entirely.
--lighter on preformance to add a temporary bundle rather than to reconstruct the bundle list for a region.
--This function should only rarely be used. 
--v function(self: REGION_DETAIL, bundle: string)
function regionDetail.add_registered_bundle(self, bundle)
    cm:apply_effect_bundle_to_region(bundle, self.key, 0)
    table.insert(self.bundles, bundle)
end;

--clears all effect bundles from the region and wipes their bundle table.
--v function(self: REGION_DETAIL)
function regionDetail.clear_bundles(self)
    Log.write("Clearing bundles for ["..self.key.."]")
    for i = 1, #self.bundles do
        cm:remove_effect_bundle_from_region(self.bundles[i], self.key)
    end
    self.bundles = {};
end;


--------------------------------
--POPULATION CHANGE MANANAGERS--
---------------------------------



--increase the economic population, will automatically stop at cap.
--v function(self: REGION_DETAIL, quantity: number)
function regionDetail.increase_econ_pop(self, quantity)
    Log.write("IncreaseEconPopulation() Called for ["..self.key.."] with an increase of ["..tostring(quantity).."] ")
    local ov = self.e_pop;
    local nv = ov + quantity;
    if nv > self.pop_cap then
        nv = self.pop_cap;
    end
    self.e_pop = nv;
end;

--decrease the economic population, will automatically stop at 0.
--v function(self: REGION_DETAIL, quantity: number)
function regionDetail.decrease_econ_pop(self, quantity)
    Log.write("DecreaseEconPopulation() Called for ["..self.key.."] with an decrease of ["..tostring(quantity).."] ")
    local ov = self.e_pop;
    local nv = ov - quantity;
    if nv < 0 then
        nv = 0;
    end
    self.e_pop = nv;
end;

--increase the administrative population, will automatically stop at cap.
--v function(self: REGION_DETAIL, quantity: number)
function regionDetail.increase_admin_pop(self, quantity)
    Log.write("IncreaseAdminPopulation() Called for ["..self.key.."] with an increase of ["..tostring(quantity).."] ")
    local ov = self.a_pop;
    local nv = ov + quantity;
    if nv > self.pop_cap then
        nv = self.pop_cap;
    end
    self.a_pop = nv;
end;

--decrease the administrative population, will automatically stop at 0.
--v function(self: REGION_DETAIL, quantity: number)
function regionDetail.decrease_admin_pop(self, quantity)
    Log.write("DecreaseAdminPopulation() Called for ["..self.key.."] with an decrease of ["..tostring(quantity).."] ")
    local ov = self.a_pop;
    local nv = ov - quantity;
    if nv < 0 then
        nv = 0;
    end
    self.a_pop = nv;
end;

--sets the population cap.
--v function(self: REGION_DETAIL, cap: number)
function regionDetail.set_pop_cap(self, cap)
    self.pop_cap = cap;
    if self.e_pop > self.pop_cap then
        self.e_pop = cap;
    end

    if self.a_pop > self.pop_cap then
        self.a_pop = cap;
    end

end;

---------------------------
--recruit pool management--
---------------------------

--increase m pool
--v function(self: REGION_DETAIL, quantity: number)
function regionDetail.increase_m_pool(self, quantity)
    local ov = self.m_pool;
    local nv = ov + quantity;
    if nv > self.m_cap then
        nv = self.m_cap;
    end
    self.m_pool = nv;
end;

--decrease m pool
--v function(self: REGION_DETAIL, quantity: number)
function regionDetail.decrease_m_pool(self, quantity)
    local ov = self.m_pool;
    local nv = ov - quantity;
    if nv < 0 then
        nv = 0;
    end
    self.m_pool = nv;
end;
 
--increase t pool
--v function(self: REGION_DETAIL, quantity: number)
function regionDetail.increase_t_pool(self, quantity)
    local ov = self.t_pool;
    local nv = ov + quantity;
    if nv > self.t_cap then
        nv = self.t_cap;
    end
    self.t_pool = nv;
end;

--decrease t pool
--v function(self: REGION_DETAIL, quantity: number)
function regionDetail.decrease_t_pool(self, quantity)
    local ov = self.t_pool;
    local nv = ov - quantity;
    if nv < 0 then
        nv = 0;
    end
    self.t_pool = nv;
end;

--increase e pool
--v function(self: REGION_DETAIL, quantity: number)
function regionDetail.increase_e_pool(self, quantity)
    local ov = self.e_pool;
    local nv = ov + quantity;
    if nv > self.e_cap then
        nv = self.e_cap;
    end
    self.e_pool = nv;
end;

--decrease e pool
--v function(self: REGION_DETAIL, quantity: number)
function regionDetail.decrease_e_pool(self, quantity)
    local ov = self.e_pool;
    local nv = ov - quantity;
    if nv < 0 then
        nv = 0;
    end
    self.e_pool = nv;
end;

--increase s pool
--v function(self: REGION_DETAIL, quantity: number)
function regionDetail.increase_s_pool(self, quantity)
    local ov = self.s_pool;
    local nv = ov + quantity;
    if nv > self.s_cap then
        nv = self.s_cap;
    end
    self.s_pool = nv;
end;

--decrease s pool
--v function(self: REGION_DETAIL, quantity: number)
function regionDetail.decrease_s_pool(self, quantity)
    local ov = self.s_pool;
    local nv = ov - quantity;
    if nv < 0 then
        nv = 0;
    end
    self.s_pool = nv;
end;


--set the cap for any pool.
--v function(self: REGION_DETAIL, cap: number)
function regionDetail.set_m_pool_cap(self, cap)
    self.m_cap = cap;
    if self.m_pool > self.m_cap then
        self.m_pool = cap;
    end
end;

--v function(self: REGION_DETAIL, cap: number)
function regionDetail.set_t_pool_cap(self, cap)
    self.t_cap = cap;
    if self.t_pool > self.t_cap then
        self.t_pool = cap;
    end
end;

--v function(self: REGION_DETAIL, cap: number)
function regionDetail.set_e_pool_cap(self, cap)
    self.e_cap = cap;
    if self.e_pool > self.e_cap then
        self.e_pool = cap;
    end
end;

--v function(self: REGION_DETAIL, cap: number)
function regionDetail.set_s_pool_cap(self, cap)
    self.s_cap = cap;
    if self.s_pool > self.s_cap then
        self.s_pool = cap;
    end
end;
-----------------------
--tax rate management--
-----------------------

--v function(self:REGION_DETAIL, level: number)
function regionDetail.set_tax_rate(self, level)
    Log.write("setting tax rate for ["..self.key.."] to ["..tostring(level).."]")
    self.tax_level = level;
end;

--v function(self: REGION_DETAIL, level: number)
function regionDetail.increase_tax_rate(self, level)
    Log.write("increasing tax rate for ["..self.key.."] by ["..tostring(level).."]")
    local ov = self.tax_level
    local nv = ov + level;
    if nv > 5 then
        nv = 5;
    end
    self.tax_level = nv;
end;

--v function(self: REGION_DETAIL, level: number)
function regionDetail.decrease_tax_rate(self, level)
    Log.write("decrease tax rate for ["..self.key.."] by ["..tostring(level).."]")
    local ov = self.tax_level
    local nv = ov - level;
    if nv < 0 then
        nv = 0;
    end
    self.tax_level = nv;
end;

-------------
--migration--
-------------

--v function(self: REGION_DETAIL)
function regionDetail.toggle_migration(self)
    Log.write("toggling migration for ["..self.key.."]")
    local ov = self.migration;
    local nv = not self.migration;
    self.migration = nv;
end;





-------------------------------------------------------------------------------------------------------------------------------------------
--return the method for new regionDetail
return {
    new = regionDetail.new
}