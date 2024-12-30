-- Credit: https://github.com/Jump-On-Studios/RedM-jo_libs/blob/60a5a7f773daf23ea77631d4e87a3698cba73e89/jo_libs/modules/component/client.lua#L904

function GetShopItemComponentAtIndex(ped, index)
    local dataStruct = DataView.ArrayBuffer(10 * 8)
    local componentHash = GetShopPedComponentAtIndex(ped, index, true, dataStruct:Buffer(), dataStruct:Buffer())
    if not componentHash or componentHash == 0 then
        componentHash = GetShopPedComponentAtIndex(ped, index, false, dataStruct:Buffer(), dataStruct:Buffer())
    end
    return componentHash
end

function GetEquippedComponents(ped)
    local components = {}
    local numComponents = GetNumComponentsInPed(ped)
    
    for index = 0, numComponents - 1 do
        local categoryHash = GetShopItemComponentAtIndex(ped, index)
        local palette, tint0, tint1, tint2 = GetMetaPedAssetTint(ped, index, Citizen.PointerValueInt(), Citizen.PointerValueInt(), Citizen.PointerValueInt(), Citizen.PointerValueInt())
        table.insert(components, {
            categoryHash = categoryHash,
            palette = palette,
            tint0 = tint0,
            tint1 = tint1,
            tint2 = tint2,
            index = index
        })
    end
    
    return components
end

function ApplyComponents(ped, components)
    ResetPedComponents(ped)
    for k,data in pairs(components) do
        local categoryHash = data.categoryHash
        RemoveTagFromMetaPed(ped, categoryHash, 0)
        ApplyShopItemToPed(ped, categoryHash, false, true, true)
        if data.palette then
            SetTextureOutfitTints(ped, categoryHash, data.palette, data.tint0 or 0, data.tint1 or 0, data.tint2 or 0)
        end
    end
    UpdatePedVariation(ped, false, true, true, true, false)
end