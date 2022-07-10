class PMVWeap_PanzerIVG_Turret extends ROVWeap_TankTurret
    abstract
    HideDropDown;

simulated function DrawRangeOverlay( Hud HUD )
{
    local float Scale, TexSizeX, TexSizeY;

    /// Needle
    Scale = HUD.Canvas.SizeY / 1024.0;
    // maintain aspect ratio of original
    TexSizeX = MyVehicle.Seats[SeatIndex].NeedleOverlayTexture.SizeX * Scale;
    TexSizeY = MyVehicle.Seats[SeatIndex].NeedleOverlayTexture.SizeY * Scale;

    HUD.Canvas.SetPos(HUD.CenterX - (TexSizeX / 2.0f), 0);
    HUD.Canvas.DrawTile(MyVehicle.Seats[SeatIndex].NeedleOverlayTexture, TexSizeX, TexSizeY, 0, 0, MyVehicle.Seats[SeatIndex].NeedleOverlayTexture.SizeX, MyVehicle.Seats[SeatIndex].NeedleOverlayTexture.SizeY);

    /// Range
    HUD.Canvas.SetPos((HUD.Canvas.SizeX - HUD.Canvas.SizeY) / 2.0, 0);
    HUD.Canvas.DrawRotatedTile(MyVehicle.Seats[SeatIndex].RangeOverlayTexture, GetSightRotation(), HUD.Canvas.SizeY, HUD.Canvas.SizeY, 0, 0, MyVehicle.Seats[SeatIndex].RangeOverlayTexture.SizeX, MyVehicle.Seats[SeatIndex].RangeOverlayTexture.SizeY);
}

simulated function DrawCenterSights( Hud HUD )
{
    local float Scale, TexSizeX, TexSizeY, AdjustedCenterY;

    Scale = HUD.Canvas.SizeY / 1024.0;
    // maintain aspect ratio of original
    TexSizeX = MyVehicle.Seats[SeatIndex].SightOverlayTexture.SizeX * Scale;
    TexSizeY = MyVehicle.Seats[SeatIndex].SightOverlayTexture.SizeY * Scale;

    AdjustedCenterY = HUD.CenterY + (GetCenterSightOffset() * Scale);

    HUD.Canvas.SetPos(HUD.CenterX - (TexSizeX / 2.0f), AdjustedCenterY - (TexSizeY / 2.0f));
    HUD.Canvas.DrawTile(MyVehicle.Seats[SeatIndex].SightOverlayTexture, TexSizeX, TexSizeY, 0, 0, MyVehicle.Seats[SeatIndex].SightOverlayTexture.SizeX, MyVehicle.Seats[SeatIndex].SightOverlayTexture.SizeY);
}

DefaultProperties
{
    WeaponContentClass(0)="ProtoMutator.PMVWeap_PanzerIVG_Turret_Content"
    SeatIndex=1
    PlayerIronSightFOV=13.5 //2.4x zoom

    // MAIN FIREMODE
    FiringStatesArray(0)=WeaponSingleFiring
    WeaponFireTypes(0)=EWFT_Projectile
    WeaponProjectiles(0)=class'PMVehProj_PanzerIVG_AP'
    FireInterval(0)=+5.0
    Spread(0)=0.0001

    // ALT FIREMODE
    FiringStatesArray(ALTERNATE_FIREMODE)=WeaponFiring
    WeaponFireTypes(ALTERNATE_FIREMODE)=EWFT_Projectile
    WeaponProjectiles(ALTERNATE_FIREMODE)=class'MG34_VehicleBullet'
    FireInterval(ALTERNATE_FIREMODE)=+0.075
    Spread(ALTERNATE_FIREMODE)=0.0007

    // AI
    AILongDistanceScale=1.15
    AIMediumDistanceScale=1.1
    AISpreadScale=200.0
    AISpreadNoSeeScale=2.0
    AISpreadNMEStillScale=0.5
    AISpreadNMESprintScale=1.5

    FireTriggerTags=(PanzerIVGCannon)
    AltFireTriggerTags=(PanzerIVGCoaxMG)

    VehicleClass=class'PMVehicle_PanzerIVG'

//  bRecommendSplashDamage=true
//  bInstantHit=false
//
//  Begin Object Class=ForceFeedbackWaveform Name=ForceFeedbackWaveformShooting1
//      Samples(0)=(LeftAmplitude=50,RightAmplitude=80,LeftFunction=WF_Constant,RightFunction=WF_Constant,Duration=0.200)
//  End Object
//  WeaponFireWaveForm=ForceFeedbackWaveformShooting1

    // Main Gun Ammo
    MainGunProjectiles(MAINGUN_AP_INDEX)=class'PMVehProj_PanzerIVG_AP'
    MainGunProjectiles(MAINGUN_HE_INDEX)=class'PMVehProj_PanzerIVG_HE'
    HEAmmoCount=42
    APAmmoCount=42
    SmokeAmmoCount=3

    // MG Ammo
    AmmoClass=class'ROAmmo_792x57_MG34Belt_150Rd'
    MaxAmmoCount=150
    bUsesMagazines=true
    InitialNumPrimaryMags=9

    /// AIMING
    BaseAddedPitch=10
    // Range (AP), optical sights via HUDPosOffset
    APSightSettings(0)=( Range=100,  HUDPosOffset=0,   HUDRotOffset=0)
    APSightSettings(1)=( Range=200,  HUDPosOffset=5,   HUDRotOffset=601)
    APSightSettings(2)=( Range=300,  HUDPosOffset=10,  HUDRotOffset=1201)
    APSightSettings(3)=( Range=400,  HUDPosOffset=15,  HUDRotOffset=1802)
    APSightSettings(4)=( Range=500,  HUDPosOffset=20,  HUDRotOffset=2421)
    APSightSettings(5)=( Range=600,  HUDPosOffset=30,  HUDRotOffset=3058)
    APSightSettings(6)=( Range=700,  HUDPosOffset=35,  HUDRotOffset=3732)
    APSightSettings(7)=( Range=800,  HUDPosOffset=45,  HUDRotOffset=4424)
    APSightSettings(8)=( Range=900,  HUDPosOffset=50,  HUDRotOffset=5079)
    APSightSettings(9)=( Range=1000, HUDPosOffset=55,  HUDRotOffset=5753)
    APSightSettings(10)=(Range=1100, HUDPosOffset=63,  HUDRotOffset=6572)
    APSightSettings(11)=(Range=1200, HUDPosOffset=72,  HUDRotOffset=7300)
    APSightSettings(12)=(Range=1300, HUDPosOffset=80,  HUDRotOffset=8046)
    APSightSettings(13)=(Range=1400, HUDPosOffset=90,  HUDRotOffset=8811)
    APSightSettings(14)=(Range=1600, HUDPosOffset=107, HUDRotOffset=10395)
    APSightSettings(15)=(Range=1800, HUDPosOffset=125, HUDRotOffset=12069)
    APSightSettings(16)=(Range=2000, HUDPosOffset=145, HUDRotOffset=13744)
    APSightSettings(17)=(Range=2200, HUDPosOffset=165, HUDRotOffset=15455)
    APSightSettings(18)=(Range=2400, HUDPosOffset=190, HUDRotOffset=17203)
    APSightSettings(19)=(Range=2500, HUDPosOffset=205, HUDRotOffset=18150)
    // Range (HE), optical sights via HUDPosOffset
    HESightSettings(0)=( Range=100,  HUDPosOffset=0,   HUDRotOffset=0)
    HESightSettings(1)=( Range=200,  HUDPosOffset=15,  HUDRotOffset=655)
    HESightSettings(2)=( Range=300,  HUDPosOffset=30,  HUDRotOffset=1201)
    HESightSettings(3)=( Range=400,  HUDPosOffset=40,  HUDRotOffset=1748)
    HESightSettings(4)=( Range=500,  HUDPosOffset=50,  HUDRotOffset=2294)
    HESightSettings(5)=( Range=600,  HUDPosOffset=60,  HUDRotOffset=2913)
    HESightSettings(6)=( Range=700,  HUDPosOffset=70,  HUDRotOffset=3732)
    HESightSettings(7)=( Range=800,  HUDPosOffset=80,  HUDRotOffset=4460)
    HESightSettings(8)=( Range=900,  HUDPosOffset=95,  HUDRotOffset=5206)
    HESightSettings(9)=( Range=1000, HUDPosOffset=107, HUDRotOffset=5880)
    HESightSettings(10)=(Range=1200, HUDPosOffset=135, HUDRotOffset=7427)
    HESightSettings(11)=(Range=1400, HUDPosOffset=160, HUDRotOffset=9120)
    HESightSettings(12)=(Range=1600, HUDPosOffset=190, HUDRotOffset=10850)
    HESightSettings(13)=(Range=1800, HUDPosOffset=220, HUDRotOffset=12652)
    HESightSettings(14)=(Range=2000, HUDPosOffset=260, HUDRotOffset=14600)
    // ... beyond this range uses horizon line 'BulletDist' sighting
    HESightSettings(15)=(Range=2200, HUDPosOffset=295, HUDRotOffset=16420)
    HESightSettings(16)=(Range=2400, HUDPosOffset=335, HUDRotOffset=18568)
    HESightSettings(17)=(Range=2600, HUDPosOffset=375, HUDRotOffset=20898)
    HESightSettings(18)=(Range=2800, HUDPosOffset=420, HUDRotOffset=23265)
    HESightSettings(19)=(Range=3000, HUDPosOffset=455, HUDRotOffset=26050)

    PenetrationDepth=23.5
    MaxPenetrationTests=3
    MaxNumPenetrations=2
}
