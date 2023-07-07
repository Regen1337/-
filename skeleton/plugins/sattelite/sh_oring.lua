local PLUGIN = PLUGIN

PLUGIN.name = "Sattelite"
PLUGIN.desc = "Adds a sattelite that can be used to call in airstrikes, airdrops"
PLUGIN.author = "regen"
PLUGIN.inspiration = "Q2F2, luv u <3"

ix.sattelite = ix.sattelite or {}
local sat = ix.sattelite

sat.model = "models/props_phx/mk-82.mdl"
sat.model_scale = .9e2, 0e0
sat.frame_num = pcall(FrameNumber) and FrameNumber() or 0e0
sat.pos = Vector()
sat.angle = Angle(3.2e1, 0e0, 0e0)
sat.mat = Material("models/props/de_tides/clouds")
sat.beam_mat = Material("cable/physbeam")
sat.beam_reach_time = .2e0
sat.beam_fade_time = .5e0
sat.fire_until_time = 0e0
sat.entity = nil

if (SERVER) then
    util.PrecacheModel(sat.model)
end

function PLUGIN:RenderScene(pos)
    sat.pos = pos
end

local pos = Angle(-9.0e1, 18.0e1, 0e0); local pos_2 = Vector(0e0, 0e0, 7.015e2); local pos_3 = Vector(5e1, 11.5e1, 112.0e1);
function PLUGIN:PostDrawSkyBox()
    if (!sat.is_ready) then return end

    if (IsValid(sat.entity)) then
        local cur_time = CurTime()
        sat.angle.y = cur_time * .06e0
        sat.frame_num = pcall(FrameNumber) and FrameNumber() or 0e0

        sat.render_pos = sat.pos + sat.angle:Forward() * - 1e1
        
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

--[==[
local function ease(num, how)
    num = math.Clamp(num, 0e0, 1e0)

    if (how < 0) then
        return num ^ (1e0 - (num - .5e0)) ^ - how
    elseif (how > 0) then
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
    sat.beam_mat:SetFloat("$alpha", math.min(1e0, (sat.fire_until_time - cur_time) * (1e0 / sat.beam_fade_time)))

    local end_frac = ease(math.min(1e0, 1e0 - (sat.fire_until_time - cur_time) * (1e0 / sat.beam_reach_time)), 3e0)
    local end_pos = LerpVector(end_frac, sat.cam_pos, sat.hit_pos)

    local random = math.random() * 5e0
    render.DrawBeam(sat.cam_pos, end_pos, 1e3, random - 1e0 - math.random(), random, color_white)
end
]==]
