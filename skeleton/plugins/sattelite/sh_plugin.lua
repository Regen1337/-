local PLUGIN = PLUGIN

ix.area.AddProperty("display", ix.type.bool, true)

PLUGIN.name = "Sattelite"
PLUGIN.desc = "Adds a sattelite that can be used to call in airstrikes, airdrops"
PLUGIN.author = "regen"
PLUGIN.inspiration = "Q2F2, luv u <3"
PLUGIN.nukeable_areas = PLUGIN.nukeable_areas or {}

function PLUGIN:GetTag()
    return self.name
end

function PLUGIN:SetupAreaProperties()
    ix.area.AddProperty("Nukeable", ix.type.bool, true)
end

function PLUGIN:CanNukeArea(area)
    local areas = ix.area.stored
    return areas[area] and areas[area].properties["Nukeable"]
end

function PLUGIN:GetRandomNukeableArea()
    local areas = ix.area.stored
    local nukeable_areas = {}

    for k, v in pairs(areas) do
        if self:CanNukeArea(k) then
            table.insert(nukeable_areas, v)
        end
    end

    return table.Random(nukeable_areas)
end

function PLUGIN:GetRandomPositionInArea(area)
    local min = area.startPosition
    local max = area.endPosition

    local x = math.random(min.x, max.x)
    local y = math.random(min.y, max.y)
    local z = math.random(min.z, max.z)

    return Vector(x, y, z)
end

ix.sattelite = ix.sattelite or {}
local sat = ix.sattelite

-- models/props_combine/combine_mortar01a.mdl
sat.model = "models/props_combine/combine_mortar01a.mdl"
sat.model_scale = .35e2, 0e0
sat.frame_num = pcall(FrameNumber) and FrameNumber() or 0e0
sat.pos = Vector()
sat.angle = Angle(3.5e1, 0e0, 0e0)
sat.mat = Material("models/props/de_tides/clouds")
sat.beam_mat = Material("cable/blue_elec")
sat.beam_reach_time = .5e0
sat.beam_fade_time = 1.5e0
sat.fire_until_time = 0e0
sat.fire_queue = {}
sat.is_firing = false
sat.entity = nil

if (SERVER) then
    util.PrecacheModel(sat.model)
    -- precache effects
    PrecacheParticleSystem("explosion_huge_b")
    PrecacheParticleSystem("explosion_huge_c")
    PrecacheParticleSystem("explosion_huge_e")
    PrecacheParticleSystem("explosion_huge_f")
    PrecacheParticleSystem("explosion_huge_j")
    util.AddNetworkString(PLUGIN:GetTag() .. ".fire_cannon")
else
    net.Receive(PLUGIN:GetTag() .. ".fire_cannon", function()
        local hit_pos = net.ReadVector()
        local fire_duration = net.ReadFloat()
        local fire_type = net.ReadString()
        local fire_delay = net.ReadFloat()

        sat:fire_cannon(hit_pos, fire_duration, fire_type, fire_delay)
    end)
end

function sat:clear_cannons()
    self.fire_queue = {}
end

function sat:fire_cannon(hit_pos, fire_duration, fire_type, fire_delay)
    if not (hit_pos and type(hit_pos) == "Vector") then return end

    -- Add the cannon firing data to the cache
    table.insert(self.fire_queue, {
        hit_pos = hit_pos,
        fire_type = fire_type or "nuke",
        fire_duration = fire_duration or 0e0,
        fire_delay = fire_delay or 0e0
    })

    -- Start firing the cannon if it's not already firing
    if not self.is_firing then
        self:fire_next_cannon()
    end
end

function sat:fire_next_cannon()
    -- Check if there is a cannon in progress or cache is empty
    if self.is_firing or #self.fire_queue == 0e0 then return end

    self.is_firing = true
    local nextCannon = table.remove(self.fire_queue, 1e0)

    if SERVER then
        net.Start(PLUGIN:GetTag() .. ".fire_cannon")
            net.WriteVector(nextCannon.hit_pos)
            net.WriteFloat(nextCannon.fire_duration)
            net.WriteString(nextCannon.fire_type)
            net.WriteFloat(nextCannon.fire_delay)
        net.Broadcast()
    end

    self.hit_pos = nextCannon.hit_pos
    self.fire_until_time = CurTime() + (nextCannon.fire_duration or 0e0)

    timer.Simple(nextCannon.fire_duration - sat.beam_reach_time, function()
        if nextCannon.fire_type == "nuke" then
            if !SERVER then self:play_nuke_sounds() end

            ParticleEffect("explosion_huge_b", nextCannon.hit_pos, Angle())
            ParticleEffect("explosion_huge_b", nextCannon.hit_pos, Angle())
            ParticleEffect("explosion_huge_c", nextCannon.hit_pos, Angle())
            ParticleEffect("explosion_huge_f", nextCannon.hit_pos, Angle())
            ParticleEffect("explosion_huge_j", nextCannon.hit_pos, Angle())

            util.ScreenShake(nextCannon.hit_pos, 1e1, 1e3, 5e0, 1e4)

            if SERVER then
                local blastDamageInfo = DamageInfo()
                blastDamageInfo:SetDamage(1e3)
                blastDamageInfo:SetDamageType(DMG_BLAST)
                blastDamageInfo:SetDamagePosition(nextCannon.hit_pos)
                blastDamageInfo:SetAttacker(game.GetWorld())
                blastDamageInfo:SetInflictor(game.GetWorld())
                blastDamageInfo:SetDamageForce(Vector(0e0, 0e0, 1e0))
                
                util.BlastDamageInfo(blastDamageInfo, nextCannon.hit_pos, 1e3)
            end
        end

        timer.Simple(nextCannon.fire_delay, function()
            self.is_firing = false
            self:fire_next_cannon()
        end)
    end)
end

function sat:fire_cannons(cannons)
    for _, cannon in ipairs(cannons) do
        self:fire_cannon(cannon.hit_pos, cannon.fire_duration, cannon.fire_type, cannon.fire_delay)
    end
end

function sat:fire_random_barrage(num_cannons, cannon_data)
    local cannons = {}

    for i = 1, num_cannons do
        local area = PLUGIN:GetRandomNukeableArea()
        local pos = PLUGIN:GetRandomPositionInArea(area)

        table.insert(cannons, {
            hit_pos = pos,
            fire_type = cannon_data.fire_type or "nuke",
            fire_duration = cannon_data.fire_duration or 0e0,
            fire_delay = cannon_data.fire_delay or 0e0
        })
    end

    self:fire_cannons(cannons)
end
-- example of call: ix.sattelite:fire_random_barrage(10, {fire_type = "nuke", fire_duration = 2, fire_delay = 3})

function sat:fire_barrage_on_area(area, num_cannons, cannon_data)
    local cannons = {}

    for i = 1, num_cannons do
        local pos = PLUGIN:GetRandomPositionInArea(area)

        table.insert(cannons, {
            hit_pos = pos,
            fire_type = cannon_data.fire_type or "nuke",
            fire_duration = cannon_data.fire_duration or 0e0,
            fire_delay = cannon_data.fire_delay or 0e0
        })
    end

    self:fire_cannons(cannons)
end
-- example of call: ix.sattelite:fire_barrage_on_area(ix.area.stored["1"], 10, {fire_type = "nuke", fire_duration = 2, fire_delay = 3})

function sat:play_nuke_sounds()
	surface.PlaySound("ambient/levels/citadel/portal_beam_shoot3.wav")
	surface.PlaySound("ambient/levels/citadel/portal_beam_shoot5.wav")
	surface.PlaySound("ambient/levels/citadel/portal_beam_shoot5.wav")
	surface.PlaySound("ambient/levels/citadel/portal_beam_shoot5.wav")
	surface.PlaySound("ambient/levels/citadel/portal_beam_shoot6.wav")
end

function PLUGIN:RenderScene(pos)
    sat.pos = pos
end

local pos = Angle(-9.0e1, 18.0e1, 0e0); local pos_2 = Vector(0e0, 0e0, 7.015e2); local pos_3 = Vector(5e1, 11.5e1, 112.0e1);
function PLUGIN:PostDrawSkyBox()
    if (!sat.is_ready) then return end

    if (IsValid(sat.entity)) then
        local cur_time = CurTime()
        sat.angle.y = cur_time * .08e1
        sat.frame_num = pcall(FrameNumber) and FrameNumber() or 0e0

        sat.render_pos = sat.pos + sat.angle:Forward() * - 1e4
        
        sat.angle_sway = Angle(math.sin(cur_time *.3e0), math.cos(cur_time * .3e0), 0e0)
        sat.angle_offset = (sat.pos - sat.render_pos):Angle() + (pos + sat.angle_sway) 
        sat.entity:SetAngles(sat.angle_offset)

        local norm = sat.entity:GetUp()
        local ent_base = sat.entity:LocalToWorld(pos_2)
        sat.cam_pos = sat.entity:LocalToWorld(pos_3)
        --sat.render_angle = Angle(sat.angle_offset.p, sat.angle_offset.y, sat.angle_offset.r)

        local old_clip = render.EnableClipping(true)
        render.SuppressEngineLighting(true)
        render.PushCustomClipPlane(norm, norm:Dot(ent_base))
        render.SetColorModulation(1e0, 1e0, 1e0)
        render.SetAmbientLight(1e0, 1e0, 1e0)
            sat.entity:SetPos(sat.render_pos)
            sat.entity:SetModelScale(sat.model_scale)
            sat.entity:DrawModel()
        render.PopCustomClipPlane()
        render.EnableClipping(old_clip)
        render.SuppressEngineLighting(false)
    else
        local entity = ents.CreateClientProp(sat.model)
        entity:SetNoDraw(true)
        entity:SetLOD(0e0)
        entity:Spawn()

        sat.entity = entity
    end
end

function PLUGIN:InitPostEntity()
    sat.is_ready = true
end
PLUGIN.OnReloaded = PLUGIN.InitPostEntity

local function ease(num, how)
    num = math.Clamp(num, 0e0, 1e0)

    if (how < 0e0) then
        return num ^ (1e0 - (num - .5e0)) ^ - how
    elseif (how > 0e0) then
        return 1e0 - (1e0 - num) ^ (1e0 / how)
    else
        return num ^ how
    end
end

function PLUGIN:PostDrawTranslucentRenderables(depth, sky)
    if (sky or !sat.cam_pos) then return end
    if (!sat.hit_pos and IsValid(sat.entity)) then return end
    sat.beam_mat:SetFloat("$alpha", 1e0)

    local cur_time = CurTime()
    local frame_num = pcall(FrameNumber) and FrameNumber() or 0e0

    if (cur_time > sat.fire_until_time or frame_num - sat.frame_num > 1e0) then return end
    render.SetMaterial(sat.beam_mat)
    sat.beam_mat:SetFloat("$alpha", math.min(1e0, (sat.fire_until_time - cur_time) * (.4e0 / sat.beam_fade_time)))

    local end_frac = ease(math.min(1e0, 1e0 - (sat.fire_until_time - cur_time) * (.1e0 / sat.beam_reach_time)), 2e0)
    local end_pos = LerpVector(end_frac, sat.cam_pos, sat.hit_pos)

    local random = math.random() * 5e0
    render.DrawBeam(sat.cam_pos, end_pos, 1e3, random - 1e0 - math.random(), random, color_white)
end
