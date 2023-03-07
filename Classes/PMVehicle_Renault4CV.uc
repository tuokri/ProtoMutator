class PMVehicle_Renault4CV extends PMVehicleTransport;

simulated exec function SwitchFireMode()
{
}

DefaultProperties
{
    bInfantryCanUse=True
    bOpenVehicle=True
    bTeamLocked=False
    bTurnInPlace=False

    bStayUpright=False
    bCanFlip=True

    COMOffset=(x=0.0,y=0.0,z=-50.0)
    InertiaTensorMultiplier=(x=1.0,y=1.0,z=1.0)
    ExitRadius=180
    ExitOffset=(X=-150,Y=0,Z=0)

    Begin Object Name=CollisionCylinder
        CollisionHeight=0.0
        CollisionRadius=260.0
        Translation=(X=0.0,Y=0.0,Z=0.0)
    End Object
    CylinderComponent=CollisionCylinder

    bDontUseCollCylinderForRelevancyCheck=true
    RelevancyHeight=0.0
    RelevancyRadius=175.0

    CrewAnimSet=AnimSet'VH_VN_ARVN_M113_APC.Anim.CHR_M113_Anim_Master'

    LeftSteerableWheelIndex=0
    RightSteerableWheelIndex=0
    LeftSteerableSimWheelIndex=3
    RightSteerableSimWheelIndex=1
    MaxVisibleSteeringAngle=25.0

    LeftWheels.Empty
    RightWheels.Empty

    LeftWheels(0)="L_Wheel_Front"
    LeftWheels(1)="L_Wheel_Rear"
    RightWheels(0)="R_Wheel_Front"
    RightWheels(1)="R_Wheel_Rear"

    Wheels.Empty

    // Right Rear Wheel
    Begin Object Name=RRWheel
        Side=SIDE_Right
        BoneName="R_Wheel_Rear"
        BoneOffset=(X=0.0,Y=0.0,Z=-7.0)
        WheelRadius=17
        SteerFactor=0.1f
        SuspensionTravel=4.8
        LongSlipFactor=1
        LatSlipFactor=5
        // HandbrakeLongSlipFactor=4000
        // HandbrakeLatSlipFactor=20000
        // ParkedSlipFactor=20000
    End Object
    Wheels(0)=RRWheel

    // Right Front Wheel
    Begin Object Name=RFWheel
        Side=SIDE_Right
        BoneName="R_Wheel_Front"
        BoneOffset=(X=0.0,Y=0.0,Z=-2.0)
        WheelRadius=17
        SteerFactor=1.0f
        SuspensionTravel=5.9
        LongSlipFactor=1
        LatSlipFactor=5
        // HandbrakeLongSlipFactor=4000
        // HandbrakeLatSlipFactor=20000
        // ParkedSlipFactor=20000
    End Object
    Wheels(1)=RFWheel

    // Left Rear Wheel
    Begin Object Name=LRWheel
        Side=SIDE_Left
        BoneName="L_Wheel_Rear"
        BoneOffset=(X=0.0,Y=0.0,Z=-7.0)
        WheelRadius=17
        SteerFactor=0.1f
        SuspensionTravel=4.8
        LongSlipFactor=1
        LatSlipFactor=5
        // HandbrakeLongSlipFactor=4000
        // HandbrakeLatSlipFactor=20000
        // ParkedSlipFactor=20000
    End Object
    Wheels(2)=LRWheel

    // Left Front Wheel
    Begin Object Name=LFWheel
        Side=SIDE_Left
        BoneName="L_Wheel_Front"
        BoneOffset=(X=0.0,Y=0.0,Z=-2.0)
        WheelRadius=17
        SteerFactor=1.0f
        SuspensionTravel=5.9
        LongSlipFactor=1
        LatSlipFactor=5
        // HandbrakeLongSlipFactor=4000
        // HandbrakeLatSlipFactor=20000
        // ParkedSlipFactor=20000
    End Object
    Wheels(3)=LFWheel

    Seats.Empty

    Seats(0)={(
        CameraTag=none,
        bSeatVisible=true,
        CameraOffset=-420,
        DriverDamageMult=1.0,
        SeatAnimBlendName=DriverPositionNode,
        SeatBone=DriverAttach,
        InitialPositionIndex=0,
        SeatRotation=(Pitch=0,Yaw=0,Roll=0),
        SeatPositions=
        (
            (
                bDriverVisible=true,
                bAllowFocus=true,
                PositionCameraTag=None,
                ViewFOV=70.0,
                PositionUpAnim=Driver_Peek_TO_Idle,
                PositionIdleAnim=Driver_idle,
                DriverIdleAnim=Driver_idle,
                AlternateIdleAnim=Driver_idle,
                SeatProxyIndex=0,
                bIsExterior=true,
                LeftHandIKInfo=
                (
                    IKEnabled=true,
                    DefaultEffectorLocationTargetName=IK_LeftSteer,
                    DefaultEffectorRotationTargetName=IK_LeftSteer
                ),
                RightHandIKInfo=
                (
                    IKEnabled=true,
                    DefaultEffectorLocationTargetName=IK_RightSteer,
                    DefaultEffectorRotationTargetName=IK_RightSteer,
                    AlternateEffectorTargets=
                    (
                        (
                            Action=DAct_ShiftGears,
                            IKEnabled=true,
                            EffectorLocationTargetName=IK_GearShifter,
                            EffectorRotationTargetName=IK_GearShifter
                        )
                    )
                ),
                LeftFootIKInfo=(
                    IKEnabled=true,
                    DefaultEffectorLocationTargetName=IK_ClutchPedal,
                    DefaultEffectorRotationTargetName=IK_ClutchPedal,
                    AlternateEffectorTargets=
                    (
                        (
                            Action=DAct_ShiftGears,
                            IKEnabled=true,
                            EffectorLocationTargetName=IK_ClutchPedal,
                            EffectorRotationTargetName=IK_ClutchPedal
                        )
                    )
                ),
                RightFootIKInfo=(
                    IKEnabled=true,
                    DefaultEffectorLocationTargetName=IK_AcceleratorPedal,
                    DefaultEffectorRotationTargetName=IK_AcceleratorPedal
                ),
                HipsIKInfo=(PinEnabled=true),
                PositionFlinchAnims=(Driver_idle),
                PositionDeathAnims=(Driver_Death)
            )
        )
    )}

    Begin Object class=ROVehicleSimHalftrack Name=SimObjectHalfTrack
        bClampedFrictionModel=True

        // Longitudinal tire model based on 10% slip ratio peak
        // WheelLongExtremumSlip=1.5
        WheelLongExtremumSlip=0.1
        WheelLongExtremumValue=1.0
        WheelLongAsymptoteSlip=2.0
        WheelLongAsymptoteValue=0.6

        // Lateral tire model based on slip angle (radians)
        WheelLatExtremumSlip=0.35     // 20 degrees
        WheelLatExtremumValue=0.85
        WheelLatAsymptoteSlip=1.4     // 80 degrees
        WheelLatAsymptoteValue=0.7

        WheelSuspensionStiffness=350
        WheelSuspensionDamping=75.0//25.0
        WheelSuspensionBias=0.3//0.1
        ChassisTorqueScale=0.8//1.0//0.0
        StopThreshold=50
        EngineBrakeFactor=0.025
        EngineDamping=0.5
        InsideTrackTorqueFactor=0.4
        CollisionGripFactor=0.18
        TurnMaxGripReduction=0.9//995//0.97
        TurnGripScaleRate=1.0
        MaxEngineTorque=5000
        EqualiseTrackSpeed=30.0//10.0

        MaxTreadSteerAngleCurve={(
            Points=
            (
                (InVal=0,OutVal=0),
                (InVal=200.0,OutVal=0.0),
                (InVal=300.0,OutVal=1.0),
                (InVal=500.0,OutVal=1.2),
                (InVal=1500.0,OutVal=1.5)
            )
        )}

        MaxSteerAngleCurve={(
            Points=
            (
                (InVal=0,OutVal=30.0f),
                (InVal=200.0,OutVal=25.0),
                (InVal=300.0,OutVal=20.0),
                (InVal=500.0,OutVal=15),
                (InVal=1500.0,OutVal=10)
            )
        )}

        //MaxSteerAngleCurve=(Points=((InVal=0,OutVal=45),(InVal=600.0,OutVal=15.0),(InVal=1100.0,OutVal=10.0),(InVal=1300.0,OutVal=6.0),(InVal=1600.0,OutVal=1.0)))

        bTurnInPlaceOnSteer=False
        TurnInPlaceThrottle=0.0
        SteerSpeed=100
        TurningLongSlipFactor=1

        MaxBrakeTorque=1000

        WheelInertia=0.1

        // Transmission - GearData
        ShiftingThrottle=0.71
        ChangeUpPoint=2650.000000
        ChangeDownPoint=700.000000
        GearShiftSlopeThreshold=0.25
        GearShiftDownSlopeThreshold=0.3
        SteepHillTopGear=2
        MinTimeAtChangePoint=0.9
        GearArray(0)={(
            GearRatio=-5.64,
            AccelRate=10.25,
            TorqueCurve=(Points={(
                (InVal=0,OutVal=-2500),
                (InVal=300,OutVal=-1750),
                (InVal=2800,OutVal=-2500),
                (InVal=3000,OutVal=-1000),
                (InVal=3200,OutVal=-0.0)
                )}),
            TurningThrottle=1.0
            )}
        GearArray(1)={(
            // [N/A]  reserved for neutral
            )}
        GearArray(2)={(
            // Real world - [4.37] ~10.0 kph
            GearRatio=5.0,
            AccelRate=6.50,
            TorqueCurve=(Points={(
                (InVal=0,OutVal=2500),
                (InVal=300,OutVal=2750),
                (InVal=2800,OutVal=5000),
                (InVal=3000,OutVal=1500),
                (InVal=3200,OutVal=0.0)
                )}),
            TurningThrottle=1.0
            )}
        GearArray(3)={(
            // Real world - [2.18] ~20.0 kph
            GearRatio=3.5,
            AccelRate=5.00,
            TorqueCurve=(Points={(
                (InVal=0,OutVal=3000),
                (InVal=2800,OutVal=3250),
                (InVal=3000,OutVal=5500),
                (InVal=3200,OutVal=0.0)
                )}),
            TurningThrottle=1.0
            )}
        GearArray(4)={(
            // Real world - [1.46] ~30.0 kph
            GearRatio=2.25,
            AccelRate=4.50,
            TorqueCurve=(Points={(
                (InVal=0,OutVal=3500),
                (InVal=2800,OutVal=3750),
                (InVal=3000,OutVal=6000),
                (InVal=3200,OutVal=0.0)
                )}),
            TurningThrottle=1.0
            )}
        GearArray(5)={(
            // Real world - [1.09] ~40.0 kph
            GearRatio=1.95,
            AccelRate=4.00,
            TorqueCurve=(Points={(
                (InVal=0,OutVal=4000),
                (InVal=2800,OutVal=4250),
                (InVal=3000,OutVal=6500),
                (InVal=3200,OutVal=0.0)
                )}),
            TurningThrottle=1.0
            )}
        // Transmission - Misc
        FirstForwardGear=2
    End Object
    Components.Remove(SimObject)
    SimObj=SimObjectHalfTrack
    Components.Add(SimObjectHalfTrack)

    // Begin Object class=SVehicleSimCar Name=SimObjectCar
    //     bClampedFrictionModel=True
    // End Object
    // Components.Remove(SimObject)
    // SimObj=SimObjectCar
    // Components.Add(SimObjectCar)

    DefaultPhysicalMaterial=PhysicalMaterial'VH_VN_US_UH1H.Phys.PhysMat_UH1H'
    DrivingPhysicalMaterial=PhysicalMaterial'VH_VN_US_UH1H.Phys.PhysMat_UH1H'
    TreadSpeedParameterName=Tank_Tread_Speed
    TrackSoundParamScale=0.000033
    TreadSpeedScale=2.5

    // // Muzzle Flashes
    // VehicleEffects(TankVFX_Firing1)=(EffectStartTag=UCHullMG,EffectTemplate=ParticleSystem'FX_MuzzleFlashes.Emitters.muzzleflash_3rdP',EffectSocket=MG_Barrel)
    // // Driving effects
    VehicleEffects(TankVFX_Exhaust)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,EffectTemplate=ParticleSystem'FX_VN_Helicopters.Emitter.FX_VN_EngineExhaust_Small',EffectSocket=Exhaust)
    VehicleEffects(TankVFX_TreadWing)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,bStayActive=true,EffectTemplate=ParticleSystem'FX_VEH_Tank_Three.FX_VEH_Tank_A_Wing_Dirt_T34',EffectSocket=attachments_body_ground)
    // // Damage
    // VehicleEffects(TankVFX_DmgSmoke)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'FX_Vehicles_Two.UniversalCarrier.FX_UnivCarrier_damaged_burning',EffectSocket=attachments_body)
    // VehicleEffects(TankVFX_DmgInterior)=(EffectStartTag=DamageInterior,EffectEndTag=NoInternalSmoke,bRestartRunning=false,bInteriorEffect=true,EffectTemplate=ParticleSystem'FX_VEH_Tank_Two.FX_VEH_Tank_Interior_Penetrate',EffectSocket=attachments_body)
    // Death
    VehicleEffects(TankVFX_DeathSmoke1)=(EffectStartTag=Destroyed,EffectEndTag=NoDeathSmoke,EffectTemplate=ParticleSystem'FX_VN_Helicopters.Emitter.FX_VN_HelicopterBurning',EffectSocket=FX_Fire)
    // VehicleEffects(TankVFX_DeathSmoke2)=(EffectStartTag=Destroyed,EffectEndTag=NoDeathSmoke,EffectTemplate=ParticleSystem'FX_VEH_Tank_Two.FX_VEH_Tank_A_SmallSmoke',EffectSocket=FX_Smoke_2)
    // VehicleEffects(TankVFX_DeathSmoke3)=(EffectStartTag=Destroyed,EffectEndTag=NoDeathSmoke,EffectTemplate=ParticleSystem'FX_VEH_Tank_Two.FX_VEH_Tank_A_SmallSmoke',EffectSocket=FX_Smoke_3)

    BigExplosionSocket=FX_Fire
    ExplosionTemplate=ParticleSystem'FX_VN_Helicopters.Emitter.FX_VN_HelicopterExplosion'

    ExplosionDamageType=class'RODmgType_VehicleExplosion'
    ExplosionDamage=100.0
    ExplosionRadius=300.0
    ExplosionMomentum=60000
    ExplosionInAirAngVel=1.5
    InnerExplosionShakeRadius=400.0
    OuterExplosionShakeRadius=1000.0
    ExplosionLightClass=class'ROGame.ROGrenadeExplosionLight'
    MaxExplosionLightDistance=4000.0
    TimeTilSecondaryVehicleExplosion=0//2.0f
    SecondaryExplosion=none//ParticleSystem'FX_VEH_Tank_Two.FX_VEH_Tank_C_Explosion_Ammo'
    bHasTurretExplosion=false

    EngineStartOffsetSecs=2.0
    EngineStopOffsetSecs=0.5

    CabinL_FXSocket=Sound_Cabin_L
    CabinR_FXSocket=Sound_Cabin_R
    Exhaust_FXSocket=Exhaust
    TreadL_FXSocket=Sound_Tread_L
    TreadR_FXSocket=Sound_Tread_R

    MaxSpeed=1365 // ~100 km/h // 723 = 53 km/h

    AirSpeed=2500
    GroundSpeed=1365

    bDestroyedTracksCauseTurn=false

    // TODO:
    RanOverDamageType=RODamageType_RunOver
    TransportType=ROTT_Halftrack
}
