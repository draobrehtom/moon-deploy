local dragonModel = `a_c_lumandragon_01`

local components = nil
local lastPlayerModel = nil
local fakeRiderPed = nil
local propBoneControlForFire = nil

function savePlayerSkin()
    local ped = PlayerPedId()
    lastPlayerModel = GetEntityModel(ped)
    components = GetEquippedComponents(ped)
end

function restorePlayerSkin()
    if lastPlayerModel then
        RequestModel(lastPlayerModel)
        while not HasModelLoaded(lastPlayerModel) do Wait(0) end
        SetPlayerModel(PlayerId(), lastPlayerModel)
        ApplyComponents(PlayerPedId(), components)
    end
end

function applyPedOptions(ped)
    -- Make as friend
    SetPedRelationshipGroupHash(ped, GetHashKey("PLAYER"))

    -- Make visible
    SetPedOutfitPreset(ped, 0, 0)
    
    -- Disable ragdoll
    SetPedCanRagdollFromPlayerImpact(ped, false)
    SetPedRagdollOnCollision(ped, false)

    -- Set to follow, also prevents from flying away in case of relationship reseted
    SetPedOwnsAnimal(PlayerPedId(), ped, true)

    -- Ignore everyone + Don't disable interaction
    SetBlockingOfNonTemporaryEvents(ped, true) SetPedConfigFlag(ped, 297, true) -- PCF_ForceInteractionLockonOnTargetPed
end

function mountDragon(entity)
    DoScreenFadeOut(250)
    Wait(250)

    -- Delete dragon without rider
    local coords = GetEntityCoords(entity)
    local rot = GetEntityRotation(entity)
    DeleteEntity(entity)
    SetEntityCoords(PlayerPedId(), coords.x, coords.y, coords.z)
    SetEntityRotation(PlayerPedId(), rot.x, rot.y, rot.z)

    -- Save player skin
    savePlayerSkin()

    -- Create fake rider as a copy of player
    fakeRiderPed = ClonePed(PlayerPedId(), true, true, true)
    FreezeEntityPosition(fakeRiderPed, true)
    SetEntityCollision(fakeRiderPed, false)
    SetBlockingOfNonTemporaryEvents(fakeRiderPed, true)
    SetEntityInvincible(fakeRiderPed, true)

    -- Set player as dragon
    RequestModel(dragonModel)
    while not HasModelLoaded(dragonModel) do
        Wait(0)
    end
    SetPlayerModel(PlayerId(), dragonModel, 0)
    while GetEntityModel(PlayerPedId()) ~= dragonModel do
        Wait(0)
    end

    --[[
        1	bullet proof
        2	flame proof
        4	explosion proof
        8	collision proof
        16	melee proof
        32	steam proof
        64	smoke proof
        128	headshots proof
        256	projectile proof
    ]]
    SetEntityProofs(PlayerPedId(), 1 + 2 + 4 + 8 + 16 + 32 + 64 + 128 + 256, 0)

    -- Apply options
    local playerPed = PlayerPedId()
    applyPedOptions(playerPed)

    -- Attach rider to dragon
    attachPedEntity(fakeRiderPed, playerPed, nil, 0.0, 0.0, 0.160, -45.0, 0.0, 0.0, false, false, 0, true)
    playAnim(fakeRiderPed, {
        dict = 'ai_gestures@script_story@ridentalk',
        name = 'positive_agree_001',
        playbackRate = 0.5,
        flag = 1,
    })

    -- Attach fire-control prop
    local propModel = `mp005_p_mp_predhunt_skull01x`
    RequestModel(propModel)
    while not HasModelLoaded(propModel) do
        Wait(0)
    end
    -- TODO: Check if non-networked prop will work
    propBoneControlForFire = CreateObject(propModel, coords.x, coords.y, coords.z, true, false, true)
    FreezeEntityPosition(propBoneControlForFire, true)
    attachObjectEntity(propBoneControlForFire, playerPed, 'SKEL_Neck2', 0.10, 0.10, 0.0, 0.0, 0.0, 0.0, false, false, 0, true)



    -- Track ped model change (bugged)
    -- isCompanionAsPlayerActivated = true
    -- CreateThread(function()
    --     while isCompanionAsPlayerActivated do
    --         Wait(0)

    --         if PlayerPedId() ~= playerPed then
    --             print(PlayerPedId(), playerPed)
    --             stopPlayingAsDragon()
    --         end
    --     end
    -- end)

    -- Camera
    CreateThread(function()
        StartDeathCam()
        while DoesEntityExist(fakeRiderPed) do
            Wait(0)
            ProcessCamControls(12.5)
        end
        EndDeathCam()
    end)

    -- TODO: Test enabled/disabled
    -- Fix issue with sync lag on high speed (f.e. bird with scale 10.0 has higher speed)
    -- local speedLimit = 20.0
    -- local cooldownStopAt = GetGameTimer()
    -- CreateThread(function()
    --     while isCompanionAsPlayerActivated do
    --         local speed = GetEntitySpeed(PlayerPedId())
    --         if speed > speedLimit then
    --             if GetGameTimer() >= cooldownStopAt then
    --                 FreezeEntityPosition(PlayerPedId(), true)
    --                 print("Freeze")
    --                 while GetEntitySpeed(PlayerPedId()) > speedLimit do
    --                     Wait(0)
    --                 end
    --                 Wait(1000)

    --                 FreezeEntityPosition(PlayerPedId(), false)
    --                 print("UnFreeze")
    --                 cooldownStopAt = GetGameTimer() + 20000
    --             else
    --             end 
    --         end
    --         Wait(0)
    --     end
    -- end)

    -- Invincible
    -- local invincible = true
    -- if invincible then
    --     CreateThread(function()
    --         while isCompanionAsPlayerActivated do
    --             Wait(0)
    --             SetEntityInvincible(PlayerPedId(), true)
    --         end
    --         SetEntityInvincible(PlayerPedId(), false)
    --     end)
    -- end


    Wait(500)
    DoScreenFadeIn(500)
end

function unmountDragon()
    DoScreenFadeOut(250)
    Wait(250)

    -- Get coordinates of unmounting
    local coords = GetEntityCoords(PlayerPedId())
    local rot = GetEntityRotation(PlayerPedId())

    -- Transform player from dragon to normal
    stopPlayingAsDragon()

    -- Spawn dragon ped without rider
    local dragon = spawnDragon(coords, rot)

    -- Set player position on left side from dragon 
    local offset = GetOffsetFromEntityInWorldCoords(dragon, -2.0, 0.0, -1.0)
    SetEntityCoords(PlayerPedId(), offset.x, offset.y, offset.z)
    
    -- Keep dragon flying if unmounting in air
    if GetEntityHeightAboveGround(dragon) > 3.0 then
        TaskFlyAway(dragon, PlayerPedId())
    end

    Wait(500)
    DoScreenFadeIn(500)
end

function spawnDragon(coords, rot)
    RequestModel(dragonModel)
    while not HasModelLoaded(dragonModel) do
        Wait(0)
    end
    local ped = CreatePed(dragonModel, coords.x, coords.y, coords.z, 0.0, true, true)
    if rot then
        SetEntityRotation(ped, rot.x, rot.y, rot.z)
    end
    applyPedOptions(ped)

    Entity(ped).state:set('luman-dragon:isOccupied', false, true)

    -- FreezeEntityPosition(ped, true)

    return ped
end

function isPlayingAsDragon()
    local playerModel = GetEntityModel(PlayerPedId())
    return playerModel == dragonModel
end

function stopPlayingAsDragon()
    restorePlayerSkin()
    if DoesEntityExist(fakeRiderPed) then
        DeleteEntity(fakeRiderPed)
    end
    if DoesEntityExist(propBoneControlForFire) then
        DeleteEntity(propBoneControlForFire)
    end
end

function togglePlayingAsDragon()
    if isPlayingAsDragon() then
        stopPlayingAsDragon()
    else

    end
end

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        stopPlayingAsDragon()

        for k,v in ipairs(GetGamePool('CPed')) do
            if GetEntityModel(v) == dragonModel then
                if NetworkGetEntityOwner(v) == PlayerId() then
                    DeleteEntity(v)
                end
            end
        end
    end
end)

local isPlayingFireSound = false
local fireConfig = {
    fireParticleStartOffset = {0.0, 0.0, 0.0},
    fireParticleScale = 7.0,  -- how large is visible dragon breath
    fireDamageScale = 5.0, -- how much damage it will make from fire
    fireEndCoordsOffset = { -- how far it will make fires
        2.0 * 5.5,
        5.0 * 5.5,
        0.0 * 5.5,
    },
    explosionType = 24,
}

local fireDebug = false
local ptfx = {
    dict = 'anm_fire_dancers',
    name = 'ent_anim_fire_breathe',
    handle = nil,
}
-- local new_ptfx_dictionary = "cut_rrtl"
-- local new_ptfx_name = "cs_rrtl_electric_arcs"
local cooldownStopAt = GetGameTimer() 
function activateFireTick()
    if IsControlJustPressed(0, `INPUT_CONTEXT_RT`) then
        if GetGameTimer() < cooldownStopAt then
            return
        end
        cooldownStopAt = GetGameTimer() + 1500

        local boneIndex = getBoneIndex(PlayerPedId(), 'skel_neck2')
        print('bone index', boneIndex)

        -- Start sound
        if not isPlayingFireSound then
            CreateThread(function() 
                isPlayingFireSound = true
                -- play sound
                -- ExecuteCommand('dragon-sound0')
            end)

            local soundIds = {1, 2, 3, 4, 5, 6, 7}
            local soundId = math.random(#soundIds)
            PlayAmbientSpeechFromEntity(fakeRiderPed, "ALLIGATOR", "pain_death", "speech_params_force", soundId)
            
            local coords = GetCameraPosition()
            if coords then
                PlayAmbientSpeechFromPosition(coords.x, coords.y, coords.z, "ALLIGATOR", "pain_death", soundId)
            end
            
            Wait(462)
        end

        -- Start fire
        if not fireDebug then
            RequestNamedPtfxAsset(GetHashKey(ptfx.dict))
            while not HasNamedPtfxAssetLoaded(GetHashKey(ptfx.dict)) do
                Wait(0)
            end
            print('ptfx', ptfx.handle)
        end
        print('Fire started')

        -- Handle explosions
        while IsControlPressed(0, `INPUT_CONTEXT_RT`) do
            local coords = GetOffsetFromEntityInWorldCoords(propBoneControlForFire, 0.0, 0.0, 0.0)
            local coords2 = GetOffsetFromEntityInWorldCoords(propBoneControlForFire, fireConfig.fireEndCoordsOffset[1], fireConfig.fireEndCoordsOffset[2], fireConfig.fireEndCoordsOffset[3])
            local hit, entityHit, endCoords = raycast(coords, coords2)
            
            if fireDebug then
                DrawText3D(coords.x, coords.y, coords.z, 'A')
                DrawText3D(coords2.x, coords2.y, coords2.z, 'B')
            else
                UseParticleFxAsset(ptfx.dict)
                ptfx.handle = StartNetworkedParticleFxNonLoopedOnEntity(
                    ptfx.name,
                    propBoneControlForFire,
                    fireConfig.fireParticleStartOffset[1] --[[ number ]], 
                    fireConfig.fireParticleStartOffset[2] --[[ number ]], 
                    fireConfig.fireParticleStartOffset[3] --[[ number ]], 
                    90.0 --[[ number ]],
                    90.0 --[[ number ]],
                    58.5 --[[ number ]],
                    fireConfig.fireParticleScale --[[ number ]], 
                    false --[[ boolean ]], 
                    false --[[ boolean ]], 
                    false --[[ boolean ]]
                )
                CreateThread(function()
                    if hit then
                        AddExplosion(endCoords.x, endCoords.y, endCoords.z, fireConfig.explosionType, fireConfig.fireDamageScale + 0.0, false, false)
                    end
                end)
            end

            if not fireDebug then
                Wait(375)
            else
                Wait(0)
            end
        end
    
        -- Stop fire
        StopParticleFxLooped(ptfx.handle)
        RemoveNamedPtfxAsset(GetHashKey(ptfx.dict))
    
        -- Stop sound
        isPlayingFireSound = false
        -- ExecuteCommand('dragon-stopSounds')

        print('Fire finished')
    end
end
CreateThread(function()
    while true do
        Wait(0)
        activateFireTick()
    end
end)




local bIsFocusingOnDragon = false
local focusedPed = 0
local bIsPromptCreated = false
local prompt = 0
local function CreateUIPrompts(ped, text)
    if prompt ~= 0 then
        return
    end

    local greetStr = CreateVarString(10, 'LITERAL_STRING', text)

    prompt = PromptRegisterBegin()
    PromptSetControlAction(prompt, 'INPUT_INTERACT_LOCKON_POS')
    PromptSetText(prompt, greetStr)
    PromptRegisterEnd(prompt)

    PromptSetPriority(prompt, 3)

    PromptSetEnabled(prompt, true)

    if DoesEntityExist(ped) then
        local group = PromptGetGroupIdForTargetEntity(ped)
        PromptSetGroup(prompt, group, 0)
    end
end
local function DestroyUIPrompts(ped)
    if prompt == 0 then
        return
    end

    if DoesEntityExist(ped) then
        local group = PromptGetGroupIdForTargetEntity(ped)
        PromptRemoveGroup(prompt, group)
    end

    PromptDelete(prompt)

    prompt = 0
end
CreateThread(function()
    while true do
        Wait(0)

        bIsFocusingOnDragon = false

        if isPlayingAsDragon() then
            if IsControlPressed(0, `INPUT_INTERACT_LOCKON`) then
                PromptDisablePromptTypeThisFrame(7) -- disable emote prompt
                if not bIsFocusingOnDragon and not bIsPromptCreated then
                    CreateUIPrompts(entity, 'Unmount Dragon')
                    focusedPed = 0
                    bIsPromptCreated = true
                    print('Create prompt', GetGameTimer())
                end
                bIsFocusingOnDragon = true
                if IsControlJustPressed(0, `INPUT_INTERACT_LOCKON_POS`) then
                    unmountDragon()
                end
            end
        else
            if IsPlayerFreeFocusing(PlayerId()) then
                local _, entity = GetPlayerTargetEntity(PlayerId())
                if IsEntityAPed(entity) and not IsPedHuman(entity) and GetEntityModel(entity) == dragonModel then
                    PromptDisablePromptTypeThisFrame(7) -- disable emote prompt
                    local isOccupied = Entity(entity).state['luman-dragon:isOccupied']
                    if not isOccupied then
                        if not bIsFocusingOnDragon and not bIsPromptCreated then
                            CreateUIPrompts(entity, 'Mount Dragon')
                            focusedPed = entity
                            bIsPromptCreated = true
                            print('Create prompt', GetGameTimer())
                        end
                        bIsFocusingOnDragon = true
                        if IsControlJustPressed(0, `INPUT_INTERACT_LOCKON_POS`) then
                            mountDragon(entity)
                        end
                    end
                end
            end
        end

        if not bIsFocusingOnDragon and bIsPromptCreated then
            DestroyUIPrompts(focusedPed)
            focusedPed = 0
            bIsPromptCreated = false
            print('Destroy prompt', GetGameTimer())
        end
    end
end)

-- Disable ragdoll for all dragons
CreateThread(function()
    while true do
        for k,ped in ipairs(GetGamePool('CPed')) do
            if GetEntityModel(ped) == dragonModel then
                if NetworkGetEntityOwner(ped) == PlayerId() then
                    SetPedCanRagdollFromPlayerImpact(ped, false)
                    SetPedRagdollOnCollision(ped, false)
                end
            end
        end
        Wait(1000)
    end
end)