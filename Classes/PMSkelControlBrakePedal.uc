class PMSkelControlBrakePedal extends SkelControlSingleBone;

var(PMSkelControlBrakePedal) editconst SVehicle OwnerVehicle;

event TickSkelControl(float DeltaTime, SkeletalMeshComponent SkelComp)
{
    if (OwnerVehicle != None)
    {
        SetSkelControlStrength(Abs(OwnerVehicle.OutputBrake), BlendInTime);
    }
}

DefaultProperties
{
    bShouldTickInScript=True
}
