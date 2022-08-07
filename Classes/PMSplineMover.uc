// TODO: this probably doesn't need to be an actor? A specialized skel mesh component would probably be better?
class PMSplineMover extends Actor;

var PMTrackSplineActor CurrentSpline;

// var() const editconst DynamicLightEnvironmentComponent MeshLightEnvironment;
var() SkeletalMeshComponent SkeletalMeshComponent;

simulated function SplineMove(float Distance)
{
    SetLocation(CurrentSpline.Connections[0].SplineComponent.GetLocationAtDistanceAlongSpline(Distance));
    SetRotation(rotator(CurrentSpline.Connections[0].SplineComponent.GetTangentAtDistanceAlongSpline(Distance)));
}

// TODO: USE VEHICLE'S LIGHT ENVIRONMENT!
DefaultProperties
{
    // Begin Object Class=DynamicLightEnvironmentComponent Name=MyMeshLightEnvironment
    //     bEnabled=True
    // End Object
    // MeshLightEnvironment=MyMeshLightEnvironment
    // Components.Add(MyMeshLightEnvironment)

    Begin Object Class=SkeletalMeshComponent Name=SkeletalMeshComponent0
        CollideActors=False
        BlockActors=False
        BlockZeroExtent=False
        BlockNonZeroExtent=False
        BlockRigidBody=False
        // LightEnvironment=MyMeshLightEnvironment
    End Object
    CollisionComponent=SkeletalMeshComponent0
    SkeletalMeshComponent=SkeletalMeshComponent0
    Components.Add(SkeletalMeshComponent0)

    TickGroup=TG_DuringAsyncWork

    Physics=PHYS_Interpolating

    bMovable=True
    bStatic=False
    bCanStepUpOn=False
    bBotCanStepUpOn=False

    RemoteRole=ROLE_None
}
