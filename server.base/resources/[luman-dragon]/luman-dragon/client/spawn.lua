
local spawnHeight = 30.0

local function GetGroundZ(x, y, z)
    local success, groundZ = GetGroundZFor_3dCoord(x, y, z, true)
    return success, groundZ
end

debugMode = false
local function DrawDebugLine(startCoords, endCoords, duration)
    if not debugMode then return end
    
    Citizen.CreateThread(function()
        local endTime = GetGameTimer() + duration
        while GetGameTimer() < endTime do
            DrawLine(
                startCoords.x, startCoords.y, startCoords.z,
                endCoords.x, endCoords.y, endCoords.z,
                255, 0, 0, 255 -- Red color
            )
            DrawMarker(
                0x94FDAE17, 
                endCoords.x, endCoords.y, endCoords.z,
                0,0,0, -- direction
                0,0,0, -- rotation
                1.0, 1.0, 1.0, -- scale
                255, 255, 255, 255,
                false, -- bob
                true, -- face camera
                2, 
                0, 
                0, 
                0, 
                0
            )
            Wait(0)
        end
    end)
end

local function CheckClearSpace(x, y, z)
    -- local success, groundZ = GetGroundZ(x, y, z)
    -- if not success then return false end

    local startCoords = vector3(x, y, z)
    local endCoords = vector3(x, y, z + spawnHeight)

    -- Draw debug line for raycast
    DrawDebugLine(startCoords, endCoords, 5000) -- Line visible for 5 seconds

    -- Check if there's enough clear space
    local hit, entityHit = raycast(startCoords, endCoords)
    
    return not hit, endCoords
end

local function SpawnBird(x, y, z)
    local birdHash = GetHashKey("a_c_eagle_01")
    RequestModel(birdHash)
    while not HasModelLoaded(birdHash) do
        Wait(1)
    end
    
    local bird = CreatePed(birdHash, x, y, z, 0.0, true, true)
    SetPedOutfitPreset(bird, 0, 0)

    SetPedCanRagdollFromPlayerImpact(bird, false)
    SetPedRagdollOnCollision(bird, false)

    return bird
end

local function FlyToPlayer(bird)
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local forward = GetEntityForwardVector(ped)
    local targetCoords = coords + forward * 5.0 

    ClearPedTasksImmediately(bird)

    -- Set the bird to fly to player
    TaskFlyToCoord(bird, 1.0, targetCoords.x, targetCoords.y, targetCoords.z + 2.0, 1, 0)
    
    -- CreateThread(function()
    --     while true do
    --         local birdCoords = GetEntityCoords(bird)
    --         local distance = #(birdCoords - targetCoords)
            
    --         if distance < 3.0 then
    --             ClearPedTasks(bird)
    --             break
    --         end
    --         Wait(100)
    --     end
    -- end)
end

local function FlyInCircle(bird, centerX, centerY, centerZ, radius)
    local height = 20.0
    local angle = 0.0
    local landed = false
    print('FlyInCircle START')
    
    CreateThread(function()
        -- Initial takeoff
        TaskFlyToCoord(bird, 1.0, centerX, centerY, centerZ + height, 1, 0)
        Wait(3000)
        
        -- while not landed do
        --     angle = angle + 0.02
        --     local newX = centerX + radius * math.cos(angle)
        --     local newY = centerY + radius * math.sin(angle)
            
        --     TaskFlyToCoord(bird, 1.0, newX, newY, centerZ + height, 1, 0)

        --     -- Complete one circle
        --     if angle >= 2 * math.pi then
        --         landed = true
        --     end
            
        --     Wait(0)
        -- end
        
        -- Land
        ClearPedTasks(bird)
        TaskFlyToCoord(bird, 1.0, centerX, centerY, centerZ, 1, 0)
        Wait(3000)
        print('FlyInCircle END')
    end)
end

local function notify(title, text)
    local title, text, dict, icon, duration, color = title, text, 'inventory_items', 'clothing_item_skullmask_mr1_000_1', 3000, 'COLOR_WHITE'
    AdvancedNotify(title, text, dict, icon, duration, color)
end

local spawnedDragonByCommand = nil
RegisterCommand('luman-dragon', function()
    if DoesEntityExist(spawnedDragonByCommand) then
        -- Go to player
        if IsEntityDead(spawnedDragonByCommand) then
            notify('Dragon', 'Is dead')
            return
        end
        SetPedOwnsAnimal(PlayerPedId(), spawnedDragonByCommand, true)
        notify('Dragon', 'Already spawned')
        return
    end

    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    coords = vector3(coords.x, coords.y, coords.z - 1.0)
    
    -- Find clear space in front of player
    local forward = GetEntityForwardVector(ped)
    local spawnPoint = coords + -forward * 30.0

    local isClear, endCoords = CheckClearSpace(spawnPoint.x, spawnPoint.y, spawnPoint.z)
    if isClear then
        spawnedDragonByCommand = spawnDragon(endCoords)
        FlyToPlayer(spawnedDragonByCommand)
        notify('Dragon', 'Spawned')
    else
        notify('Dragon', 'No clear space found')
    end
end, false)