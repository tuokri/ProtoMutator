class PMVehProj_PanzerIVG_HE extends ROTankCannonProjectile;

DefaultProperties
{
    BallisticCoefficient=2.0
    Speed=27500 //550 M/S
    MaxSpeed=27500
    Damage=350
    DamageRadius=550
    MomentumTransfer=50000
    ImpactDamageType=class'PMDmgType_PanzerIVGShell_HEImpact'
    GeneralDamageType=class'PMDmgType_PanzerIVGShell_HEImpact_General'
    MyDamageType=class'PMDmgType_PanzerIVGShell_HE'

    // Shell values
    Caliber=75
    ActualRHA=20
    TestPlateHardness=300
    SlopeEffect=0.82472
    ShatterNumber=1.0
    ShatterTd=0.65
    ShatteredPenEffectiveness=0.8

    // TODO:
    // ExplosionSound=SoundCue'AUD_EXP_Tanks.A_CUE_Tank_Explode'

    ShakeScale=2.5
    MaxSuppressBlurDuration=4.5
    SuppressBlurScalar=1.5
    SuppressAnimationScalar=0.6
    ExplodeExposureScale=0.45

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
        BlockNonZeroExtent=true//false
        BlockRigidBody=true
        Scale=1
    End Object
    Components.Add(ProjectileMesh)

    bExplodeOnDeflect=true
    bExplodeWhenHittingInfantry=true

    ProjExplosionTemplate=ParticleSystem'PM_FX_WEP_Explosive.FX_VEH_Explosive_C_TankCannon_HE_Shell_Impact_Dirt'
}
