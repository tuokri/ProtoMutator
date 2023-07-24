class PMM79GrenadeProjectile extends M79GrenadeProjectile;

simulated function bool ProjectileHurtRadius(vector HurtOrigin, vector HitNormal)
{
    local Actor	Victim;
    local bool bCausedDamage;
    local TraceHitInfo HitInfo;
    local StaticMeshComponent HitComponent;
    local KActorFromStatic NewKActor;
    // RO locals
    //local bool bInitializedAltOrigin, bFailedAltOrigin;
    //local vector AltOrigin;
    local float DamageScale;
    local float FalloffExponent;
    local ROPawn ROPVictim;
    local vector MyGravity;

    // Prevent HurtRadius() from being reentrant.
    if ( bHurtEntry )
        return false;

    bHurtEntry = true;
    bCausedDamage = false;

    MyGravity.Z = PhysicsVolume.GetGravityZ();

    // Do the damage a little off the ground
    HurtOrigin = Location + ExplosionOffsetDist * -Normal(MyGravity);

    // Debugging
    //FlushPersistentDebugLines();
    //DrawDebugSphere(HurtOrigin, DamageRadius, 16, 255, 0, 0, true); // Draw a red sphere to represent the damage radius
    //DrawDebugSphere(HurtOrigin, 10, 16, 255, 0, 0, true);           // Draw a small red sphere at the explosion location

    // if ImpactedActor is set, we actually want to give it full damage, and then let him be ignored by super.HurtRadius()
    if ( ImpactedActor != none && ImpactedActor != self )
    {
        ImpactedActor.TakeRadiusDamage(InstigatorController, Damage, DamageRadius, MyExpImpactDamageType, MomentumTransfer, HurtOrigin, true, self);
        // need to check again in case TakeRadiusDamage() did something that went through our explosion path a second time
        if ( ImpactedActor != none )
        {
            bCausedDamage = ImpactedActor.bProjTarget;
        }
    }

    // Based on Actor.HurtRadius()
    //foreach VisibleCollidingActors( class'Actor', Victim, DamageRadius, HurtOrigin,,,,, HitInfo, false )
    foreach CollidingActors( class'Actor', Victim, DamageRadius, HurtOrigin,,, HitInfo )
    {
        `pmlog("    Victim: " @ Victim);

        // Do more expensive 'exposure' checks below
        // bHitNonWorld = FastTrace...
        // bHitWorld = !FastTrace...
        if ( Victim.bStatic || Victim.IsA('ROPawn') || !FastTrace(Victim.Location, HurtOrigin) )
        {
            `pmlog("      skipping" @ Victim @ "bStatic"
                @ Victim.bStatic @ "IsAROPawn" @ Victim.IsA('ROPawn') @ "!FastTrace(Victim.Location, HurtOrigin)"
                @ !FastTrace(Victim.Location, HurtOrigin));
            continue;
        }

        if ( Victim.bWorldGeometry )
        {
            `pmlog("      Victim:" @ Victim @ "bWorldGeometry" @ Victim.bWorldGeometry);

            // check if it can become dynamic
            // @TODO note that if using StaticMeshCollectionActor (e.g. on Consoles), only one component is returned.  Would need to do additional octree radius check to find more components, if desired
            HitComponent = StaticMeshComponent(HitInfo.HitComponent);
            if ( (HitComponent != None) && HitComponent.CanBecomeDynamic() )
            {
                NewKActor = class'KActorFromStatic'.Static.MakeDynamic(HitComponent);
                if ( NewKActor != None )
                {
                    Victim = NewKActor;
                }
            }
        }

        if ( Victim != self && Victim != ImpactedActor && (Victim.bCanBeDamaged || Victim.bProjTarget) )
        {
            `pmlog("      calling TakeRadiusDamage on" @ Victim);
            Victim.TakeRadiusDamage(InstigatorController, Damage, DamageRadius, MyDamageType, MomentumTransfer, HurtOrigin, false, self);
            bCausedDamage = bCausedDamage || Victim.bProjTarget;
        }
    }

    foreach CollidingActors( class'ROPawn', ROPVictim, DamageRadius, HurtOrigin,,, HitInfo )
    {
        if(ROPVictim.Health <= 0)
        {
            continue;
        }

        DamageScale = ROPVictim.GetExposureTo(HurtOrigin);
        // Used Quadratic model on Players(1 - (Distance/Radius)^3)
        FalloffExponent = RadialDamageFalloffExponent;

        // Add the origin of the explosion to the LastTakeHitInfo
        ROPVictim.LastTakeHitInfo.RadialDamageOrigin = HurtOrigin;

        if( DamageScale > 0 )
        {
            ROPVictim.TakeRadiusDamage(InstigatorController, Damage * DamageScale, DamageRadius, MyDamageType, MomentumTransfer, HurtOrigin, false, self, FalloffExponent);
            ROPVictim.CollisionComponent.AddRadialForce(Location, RadialForceRadius, RadialForce, RIF_Linear);
        }
        bCausedDamage = bCausedDamage || ROPVictim.bProjTarget;
    }
    bHurtEntry = false;

    return bCausedDamage;
}
