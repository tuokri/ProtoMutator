class PMPlayerController extends ROPlayerController;

exec function Camera(name NewMode)
{
    ServerCamera(NewMode);
}

reliable server function ServerCamera(name NewMode)
{
    if (NewMode == '1st')
    {
        NewMode = 'FirstPerson';
    }
    else if (NewMode == '3rd')
    {
        NewMode = 'ThirdPerson';
    }
    else if (NewMode == 'free')
    {
        NewMode = 'FreeCam';
    }
    else if (NewMode == 'fixed')
    {
        NewMode = 'Fixed';
    }

    SetCameraMode(NewMode);

    if (PlayerCamera != None)
    {
        `pmlog("CameraStyle=" $ PlayerCamera.CameraStyle);
        ClientMessage("CameraStyle=" $ PlayerCamera.CameraStyle);
    }
}

DefaultProperties
{

}
