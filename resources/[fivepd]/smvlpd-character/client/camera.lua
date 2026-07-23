local creatorCam

function CreateCreatorCamera()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)

    DestroyCreatorCamera()
    creatorCam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    SetCamCoord(
    creatorCam,
    coords.x,
    coords.y - 2.2,
    coords.z + 0.75
)
    PointCamAtEntity(creatorCam, ped, 0.0, 0.0, 0.62, true)
    SetCamFov(creatorCam, 38.0)
    SetCamActive(creatorCam, true)
    RenderScriptCams(true, true, 350, true, true)
end

function DestroyCreatorCamera()
    if creatorCam then
        RenderScriptCams(false, true, 350, true, true)
        DestroyCam(creatorCam, true)
        creatorCam = nil
    end
end
