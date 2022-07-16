class PMVehProj_PanzerIVG_AP extends ROTankCannonProjectile;

DefaultProperties
{
    AmmoTypeShortName="AP"

    BallisticCoefficient=1.8
    Speed=37000 //740 M/S
    MaxSpeed=37000
    ImpactDamage=400
    Damage=100
    DamageRadius=50
    MomentumTransfer=50000
    ImpactDamageType=class'PMDmgType_PanzerIVGShell_AP'
    GeneralDamageType=class'PMDmgType_PanzerIVGShell_AP_General'
    MyDamageType=class'PMDmgType_PanzerIVGShell_AP'

    // TODO:
    // ExplosionSound=SoundCue'AUD_Impacts.Impacts.Tank_AP_Impact_Dirt_Cue'

    Begin Object Name=CollisionCylinder
        CollisionRadius=4
        CollisionHeight=4
        AlwaysLoadOnClient=True
        AlwaysLoadOnServer=True
    End Object

    Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
    End Object
    Components.Add(MyLightEnvironment)

    Begin Object Class=StaticMeshComponent Name=ProjectileMesh
        StaticMesh=StaticMesh'PM_VH_Panzer_IVG.Mesh.Panzer_IVG_Warhead'
        Materials(0)=MaterialInstanceConstant'PM_VH_Panzer_IVG.Materials.Panzer_IVG_Warhead_MIC'
        MaxDrawDistance=500000
        CollideActors=true
        CastShadow=false
        LightEnvironment=MyLightEnvironment
        BlockActors=false
        BlockZeroExtent=true
        BlockNonZeroExtent=true
        BlockRigidBody=true
        Scale=1
    End Object
    Components.Add(ProjectileMesh)

    Caliber=75
    ActualRHA=117
    TestPlateHardness=300
    SlopeEffect=0.82472
    ShatterNumber=1.0
    ShatterTd=0.65
    ShatteredPenEffectiveness=0.8
    // World penetration
    PenetrationDepth=120
    MaxPenetrationTests=6
}
