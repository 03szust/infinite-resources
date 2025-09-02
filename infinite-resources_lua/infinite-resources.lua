local InfiniteResources = {}

-- List of all Area Economies as CAreaEconomy weak pointers
local economyList = {}

-- List of Area ID's matched to Area Economies as rdgs.AreaId (similar to number)
local areaList = {}

-- Helper Variable to store the previous Area ID to stop the code from executing too much things
local previousAreaID = nil

-- Function executed at Load
-- Empties both Lists so they can be repopulated
function InfiniteResources.Load()
    economyList = {}
    areaList = {}
end

-- Function to add Areas to the Lists
-- if a new Area is detected it gets added to the Lists
-- if the Area is already in the Lists, the function does nothing
function addArea(area)
    local new_entry = true
    -- Check if Area is already in Lists
    for _,areaid in pairs(areaList) do
        if area.ID == areaid then
            new_entry = false
            break
        end
    end
    -- Add new Area to Lists if necessary
    if new_entry then
        table.insert(economyList, area.Economy)
        table.insert(areaList, area.ID)
    end
end

-- Function executed at Tick
-- Locks Resources at 10 under Capacity
-- For all Areas that have been looked at and belong to the Player
-- Since the last Load
function InfiniteResources.Tick()
    
    -- get Area the Camera is currently on
    local area = Area.Current

    -- Check if the Camera is actually on an Area
    -- The Camera is on an Area as long as the Building Materials are displayed
    if tostring(area) ~= "CConstructionArea weak null" then
        -- Check if the Area hasn't been looked at the last Tick and if the Player owns the Area
        -- If not, add the Area if needed and update the previous Area
        if area.ID ~= previousAreaID and area.AreaOwnerIsCurrentParticipant then
            addArea(area)
            previousAreaID = area.ID
        end
    end
    
    -- Loop over all recorded Areas
    for i,ecoid in pairs(economyList) do
        
        -- If the Player stops owning an Area, remove it and reset the previous Area
        -- Else set all unlocked Goods to 10 under Capacity
        if tostring(ecoid) == "CAreaEconomy weak null" then
            table.remove(economyList, i)
            table.remove(areaList, i)
            previousAreaID = nil
        else
            local capacity = ecoid:GetStorageCapacity(2174)   
            ecoid:AddAmount(0 - capacity)
            ecoid:AddAmount(capacity - 10)
        end
    end
    
end

return InfiniteResources;


