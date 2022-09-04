// TODO: this probably doesn't need to be an actor? A specialized skel mesh component would probably be better?
class PMSplineMover extends Actor;

var private PMTrackSplineActor CurrentSpline;
var private rotator NewRotation;
var private float DistanceMoved;
var private float CurrentSplineLength;

var(TrackAnim) int DistanceMultiplier;

// var() const editconst DynamicLightEnvironmentComponent MeshLightEnvironment;
var() SkeletalMeshComponent SkeletalMeshComponent;

simulated function SetCurrentSpline(PMTrackSplineActor Spline, optional float InitialDistance = 0)
{
    CurrentSpline = Spline;
    DistanceMoved = InitialDistance * DistanceMultiplier;
    CurrentSplineLength = CurrentSpline.Connections[0].SplineComponent.GetSplineLength();
}

simulated function SplineMove(float Distance)
{
    // TODO: clamp until reversing is implemented.
    DistanceMoved += FMax(Distance * DistanceMultiplier, 0.f);

    if (DistanceMoved >= CurrentSplineLength)
    {
        CurrentSpline = PMTrackSplineActor(CurrentSpline.Connections[0].ConnectTo);
        DistanceMoved = DistanceMoved - CurrentSplineLength;
        CurrentSplineLength = CurrentSpline.Connections[0].SplineComponent.GetSplineLength();
    }

    SetLocation(CurrentSpline.Connections[0].SplineComponent.GetLocationAtDistanceAlongSpline(DistanceMoved));
    NewRotation = rotator(CurrentSpline.Connections[0].SplineComponent.GetTangentAtDistanceAlongSpline(DistanceMoved));
    SetRotation(NewRotation);
}

DefaultProperties
{
    // Begin Object Class=DynamicLightEnvironmentComponent Name=MyMeshLightEnvironment
    //     bEnabled=True
    // End Object
    // MeshLightEnvironment=MyMeshLightEnvironment
    // Components.Add(MyMeshLightEnvironment)

    DistanceMultiplier=1

    Begin Object Class=SkeletalMeshComponent Name=SkeletalMeshComponent0
        SkeletalMesh=SkeletalMesh'PM_VH_Panzer_IVG.Mesh.TrackPiece'
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
