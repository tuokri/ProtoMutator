class PMSplineMover extends Actor;

var() const editconst DynamicLightEnvironmentComponent MeshLightEnvironment;
var() SkeletalMeshComponent SkeletalMeshComponent;

DefaultProperties
{
    Begin Object Class=DynamicLightEnvironmentComponent Name=MyMeshLightEnvironment
        bEnabled=True
    End Object
    MeshLightEnvironment=MyMeshLightEnvironment
    Components.Add(MyMeshLightEnvironment)

    Begin Object Class=SkeletalMeshComponent Name=SkeletalMeshComponent0
        CollideActors=False
        BlockActors=False
        BlockZeroExtent=False
        BlockNonZeroExtent=False
        BlockRigidBody=False
        LightEnvironment=MyMeshLightEnvironment
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

    RemoteRole=ROLE_SimulatedProxy
}
