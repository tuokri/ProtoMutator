class PMBullet_MG34_Tracer extends ROBulletTracer;

DefaultProperties
{
    BallisticCoefficient=0.390
    MyDamageType=class'PMDmgType_MG34Bullet'
    Speed=37750         // 755m/s
    MaxSpeed=37750      // 755m/s

    ProjFlightTemplate=ParticleSystem'FX_VN_Weapons.Tracers.FX_Wep_Gun_A_MGTracer_North'
    ProjExplosionTemplate=ParticleSystem'FX_VN_Weapons.Tracers.FX_Wep_Gun_A_MGTracer_Explode_North'
    DeflectionTemplate=ParticleSystem'FX_VN_Weapons.Tracers.FX_Wep_Gun_A_MGTracer_Deflect_North'

    TracerLightClass=none//class'ROGame.ROBulletTracerLightGreen'
}
