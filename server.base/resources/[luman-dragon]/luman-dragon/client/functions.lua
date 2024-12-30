function getBoneIndex(entity, bone)
	if type(bone) == 'number' then
		return bone
	else
        return GetEntityBoneIndexByName(entity, bone)
	end
end

function attachObjectEntity(from, to, bone, x, y, z, pitch, roll, yaw, useSoftPinning, collision, vertex, fixedRot)
	if not bone then
		bone = 0
	end
	local boneIndex = getBoneIndex(to, bone)
    local isPed = false
	AttachEntityToEntity(from, to, boneIndex, x, y, z, pitch, roll, yaw, false, useSoftPinning, collision, isPed, vertex, fixedRot, false, false)
end

function attachPedEntity(from, to, bone, x, y, z, pitch, roll, yaw, useSoftPinning, collision, vertex, fixedRot)
	if not bone then
		bone = 0
	end
	local boneIndex = getBoneIndex(to, bone)
    local isPed = true
	AttachEntityToEntity(from, to, boneIndex, x, y, z, pitch, roll, yaw, false, useSoftPinning, collision, isPed, vertex, fixedRot, false, false)
end

function playAnim(entity, anim)
	if not DoesAnimDictExist(anim.dict) then
		return false
	end

	RequestAnimDict(anim.dict)

	while not HasAnimDictLoaded(anim.dict) do
		Wait(0)
	end

	if GetEntityType(entity) == 3 then
		PlayEntityAnim(entity, anim.name, anim.dict, anim.blendInSpeed, false, true, false, 0.0, 0)
	else
        local blendInSpeed = anim.blendInSpeed and anim.blendInSpeed * 1.0 or 1.0
		local blendOutSpeed = anim.blendOutSpeed and anim.blendOutSpeed * 1.0 or 1.0
		local duration = anim.duration and anim.duration or -1
		local flag = anim.flag and anim.flag or 2 -- AF_NOT_INTERRUPTABLE 
		local playbackRate = anim.playbackRate and anim.playbackRate * 1.0 or 0.0
		TaskPlayAnim(entity, anim.dict, anim.name, blendInSpeed, blendOutSpeed, duration, flag, playbackRate, false, false, false, '', false)
	end

    RemoveAnimDict(anim.dict)
end

function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = GetScreenCoordFromWorldCoord(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoord())
    SetTextScale(0.35, 0.35)
    SetTextFontForCurrentCommand(1)
    SetTextColor(255, 255, 255, 215)
    local str = CreateVarString(10, "LITERAL_STRING", text, Citizen.ResultAsLong())
    SetTextCentre(1)
    DisplayText(str, _x, _y)
    local factor = (string.len(text)) / 150
    DrawSprite("generic_textures", "hud_menu_4a", _x, _y + 0.0125, 0.015 + factor, 0.03, 0.1, 100, 1, 1, 190, 0)
end

function raycast(coords, destination)
	local handle = StartShapeTestLosProbe(
        coords.x, coords.y, coords.z, destination.x, destination.y, destination.z,
		flags or 511, PlayerPedId(), ignore or 4
    )
	while true do
		Wait(0)
		local retval, hit, endCoords, surfaceNormal, materialHash, entityHit = GetShapeTestResult(handle)

		if retval ~= 1 then
            ---@diagnostic disable-next-line: return-type-mismatch
			return (hit == 1 or hit == true), entityHit, endCoords, surfaceNormal, materialHash
		end
	end
end

function AdvancedNotify(title, text, dict, icon, duration, color)
    local optionscontent = DataView.ArrayBuffer(8 * 7)
    optionscontent:SetInt32(8 * 0, duration)

    local maincontent = DataView.ArrayBuffer(8 * 8)

    local vartitle = Citizen.InvokeNative(0xFA925AC00EB830B9, 10, "LITERAL_STRING", title, Citizen.ResultAsLong())
    local vartext = Citizen.InvokeNative(0xFA925AC00EB830B9, 10, "LITERAL_STRING", text, Citizen.ResultAsLong())

    maincontent:SetInt64(8 * 1, DataView.BigInt(vartitle))
    maincontent:SetInt64(8 * 2, DataView.BigInt(vartext))
    maincontent:SetInt32(8 * 3, 0)
    maincontent:SetInt64(8 * 4, DataView.BigInt(GetHashKey(dict)))
    maincontent:SetInt64(8 * 5, DataView.BigInt(GetHashKey(icon)))
    maincontent:SetInt64(8 * 6, DataView.BigInt(GetHashKey(color or "COLOR_WHITE")))

    Citizen.InvokeNative(0x26E87218390E6729, optionscontent:Buffer(), maincontent:Buffer(), 1, 1)
end

-- Original code from https://github.com/femga/rdr3_discoveries/
-- and https://github.com/aaron1a12/wild/blob/9235aaa39696691ff26977ff1d2c18fe67971ef5/wild-core/client/functions/cl_utilities.lua#L191C1-L191C65
function PlayAmbientSpeechFromEntity(entity_id, sound_ref_string, sound_name_string, speech_params_string, speech_line)
	local sound_name = Citizen.InvokeNative(0xFA925AC00EB830B9, 10, "LITERAL_STRING", sound_name_string,Citizen.ResultAsLong())
	local sound_ref  = Citizen.InvokeNative(0xFA925AC00EB830B9, 10, "LITERAL_STRING",sound_ref_string,Citizen.ResultAsLong())
	local speech_params = GetHashKey(speech_params_string)
	
	local sound_name_BigInt =  DataView.ArrayBuffer(16) 
	sound_name_BigInt:SetInt64(0,sound_name)
	
	local sound_ref_BigInt =  DataView.ArrayBuffer(16)
	sound_ref_BigInt:SetInt64(0,sound_ref)
	
	local speech_params_BigInt = DataView.ArrayBuffer(16)
	speech_params_BigInt:SetInt64(0,speech_params)
	
	local struct = DataView.ArrayBuffer(128)
	struct:SetInt64(0, sound_name_BigInt:GetInt64(0)) -- speechName
	struct:SetInt64(8, sound_ref_BigInt:GetInt64(0)) -- voiceName
	struct:SetInt32(16, speech_line) -- variation
	struct:SetInt64(24, speech_params_BigInt:GetInt64(0)) -- speechParamHash
	struct:SetInt32(32, 0) -- listenerPed
	struct:SetInt32(40, 1) -- syncOverNetwork
	struct:SetInt32(48, 1) -- v7
	struct:SetInt32(56, 1) -- v8
	
	return Citizen.InvokeNative(0x8E04FEDD28D42462, entity_id, struct:Buffer());
end

function PlayAmbientSpeechFromPosition(x,y,z,sound_ref_string,sound_name_string,speech_line)
    local struct = DataView.ArrayBuffer(128)
    local sound_name = Citizen.InvokeNative(0xFA925AC00EB830B9, 10, "LITERAL_STRING", sound_name_string,Citizen.ResultAsLong())
    local sound_ref  = Citizen.InvokeNative(0xFA925AC00EB830B9, 10, "LITERAL_STRING",sound_ref_string,Citizen.ResultAsLong())
    local sound_name_BigInt =  DataView.ArrayBuffer(16)
    sound_name_BigInt:SetInt64(0,sound_name)
    local sound_ref_BigInt =  DataView.ArrayBuffer(16)
    sound_ref_BigInt:SetInt64(0,sound_ref)
    local speech_params_BigInt = DataView.ArrayBuffer(16)
    speech_params_BigInt:SetInt64(0,291934926)
    struct:SetInt64(0,sound_name_BigInt:GetInt64(0))
    struct:SetInt64(8,sound_ref_BigInt:GetInt64(0))
    struct:SetInt32(16, speech_line)
    struct:SetInt64(24,speech_params_BigInt:GetInt64(0))
    struct:SetInt32(32, 0)
    struct:SetInt32(40, 1)
	struct:SetInt32(48, 1)
	struct:SetInt32(56, 1)
	Citizen.InvokeNative(0xED640017ED337E45,x,y,z,struct:Buffer())
end