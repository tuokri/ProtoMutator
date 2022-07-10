class PMBullet_MG34 extends ROBullet;

// TODO: Damage values taken from DP28!
DefaultProperties
{
    BallisticCoefficient=0.390
    Damage=768
    MyDamageType=class'PMDmgType_MG34Bullet'
    Speed=37750         // 755m/s
    MaxSpeed=37750      // 755m/s

    // RS2. Energy transfer function
    // MN9130, DP28 // TODO: need this for MG34 bullet.
    VelocityDamageFalloffCurve=(Points=((InVal=467640625,OutVal=0.5), (InVal=1870562500,OutVal=0.18)))
    // VelocityDamageFalloffCurve=(Points=((InVal=0.5,OutVal=0.5), (InVal=1.0,OutVal=0.18)))
}
