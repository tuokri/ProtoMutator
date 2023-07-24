class PMStaticMeshDestructible extends ROStaticMeshDestructible;

simulated function TakeRadiusDamage(
    Controller			InstigatedBy,
    float				BaseDamage,
    float				DamageRadius,
    class<DamageType>	DamageType,
    float				Momentum,
    vector				HurtOrigin,
    bool				bFullDamage,
    Actor               DamageCauser,
    optional float      DamageFalloffExponent=1.f
)
{
    `pmlog("InstigatedBy:" @ InstigatedBy @ "BaseDamage:" @ BaseDamage
        @ "DamageType" @ DamageType @ "DamageCauser:" @ DamageCauser);

    super.TakeRadiusDamage(InstigatedBy,BaseDamage,DamageRadius,DamageType,
        Momentum,HurtOrigin,bFullDamage,DamageCauser,DamageFalloffExponent);
}

event TakeDamage(int DamageAmount, Controller EventInstigator, vector HitLocation,
    vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo,
    optional Actor DamageCauser)
{
    `pmlog("DamageAmount:" @ DamageAmount @ "EventInstigator:" @ EventInstigator
        @ "DamageType:" @ DamageType @ "DamageCauser:" @ DamageCauser);

    super.TakeDamage(DamageAmount, EventInstigator,
        HitLocation, Momentum, DamageType, HitInfo, DamageCauser);
}

DefaultProperties
{

}
