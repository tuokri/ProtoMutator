class PMVehicle_Renault4CV_2 extends PMVehicleWheeled
    abstract;

DefaultProperties
{
    bInfantryCanUse=True
    bOpenVehicle=True
    bTeamLocked=False

    COMOffset=(x=20.0,y=0.0,z=-50.0)
    InertiaTensorMultiplier=(x=5.0,y=2.0,z=2.0)
    ExitRadius=180
    ExitOffset=(X=-150,Y=0,Z=0)

    Begin Object Name=CollisionCylinder
        CollisionHeight=0.0
        CollisionRadius=260.0
        Translation=(X=0.0,Y=0.0,Z=0.0)
    End Object
    CylinderComponent=CollisionCylinder

    bDontUseCollCylinderForRelevancyCheck=true
    RelevancyHeight=70.0
    RelevancyRadius=175.0

    CrewAnimSet=AnimSet'VH_VN_ARVN_M113_APC.Anim.CHR_M113_Anim_Master'

    Begin Object class=PointLightComponent name=InteriorLight_0
		Radius=100.0
		LightColor=(R=255,G=170,B=130)
		UseDirectLightMap=FALSE
		Brightness=1.0
		LightingChannels=(Unnamed_1=TRUE,BSP=FALSE,Static=FALSE,Dynamic=FALSE,CompositeDynamic=FALSE)
	End Object

	Begin Object class=PointLightComponent name=InteriorLight_1
		Radius=100.0
		LightColor=(R=255,G=170,B=130)
		UseDirectLightMap=FALSE
		Brightness=1.0
		LightingChannels=(Unnamed_1=TRUE,BSP=FALSE,Static=FALSE,Dynamic=FALSE,CompositeDynamic=FALSE)
	End Object

    VehicleLights(0)={(AttachmentName=InteriorLightComponent0,Component=InteriorLight_0,bAttachToSocket=true,AttachmentTargetName=interior_light_0)}
	VehicleLights(1)={(AttachmentName=InteriorLightComponent1,Component=InteriorLight_1,bAttachToSocket=true,AttachmentTargetName=interior_light_1)}

    Seats.Empty

    Seats(0)={(
        bNonEnterable=false,
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
            // 0
            (
                bDriverVisible=true,
                bAllowFocus=true,
                PositionCameraTag=None,
                ViewFOV=70.0,
                PositionUpAnim=none,
                PositionDownAnim=none,
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
                            EffectorRotationTargetName=IK_GearShifter,
                        ),
                        // (
                        //     Action=DAct_SteerSwap_RHOn,
                        //     IKEnabled=true,
                        //     EffectorLocationTargetName=IK_RightSteer_Swap,
                        //     EffectorRotationTargetName=IK_RightSteer_Swap,
                        // ),
                    )
                ),
                LeftFootIKInfo=
                (
                    IKEnabled=true,
                    DefaultEffectorLocationTargetName=IK_Driver_LeftFoot,
                    DefaultEffectorRotationTargetName=IK_Driver_LeftFoot,
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
                RightFootIKInfo=
                (
                    IKEnabled=true,
                    DefaultEffectorLocationTargetName=IK_AcceleratorPedal,
                    DefaultEffectorRotationTargetName=IK_AcceleratorPedal
                ),
                HipsIKInfo=
                (
                    PinEnabled=true,
                    DefaultEffectorLocationTargetName=DriverAttach,
                    DefaultEffectorRotationTargetName=DriverAttach,
                ),
                PositionFlinchAnims=(Driver_idle),
                PositionDeathAnims=(Driver_Death),
                LookAtInfo=
                (
                    LookAtEnabled=true,
                    DefaultLookAtTargetName=LookAt_Driver,
                    HeadInfluence=1.0,
                    BodyInfluence=1.0
                )
            ),
            // 1 is just a copy of 0. Has to be here since native has hard-coded position index 1.
            // TODO: test if removing this causes issues.
            (
                bDriverVisible=true,
                bAllowFocus=true,
                PositionCameraTag=None,
                ViewFOV=70.0,
                PositionUpAnim=none,
                PositionDownAnim=none,
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
                            EffectorRotationTargetName=IK_GearShifter,
                        ),
                        // (
                        //     Action=DAct_SteerSwap_RHOn,
                        //     IKEnabled=true,
                        //     EffectorLocationTargetName=IK_RightSteer_Swap,
                        //     EffectorRotationTargetName=IK_RightSteer_Swap,
                        // ),
                    )
                ),
                LeftFootIKInfo=
                (
                    IKEnabled=true,
                    DefaultEffectorLocationTargetName=IK_Driver_LeftFoot,
                    DefaultEffectorRotationTargetName=IK_Driver_LeftFoot,
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
                RightFootIKInfo=
                (
                    IKEnabled=true,
                    DefaultEffectorLocationTargetName=IK_AcceleratorPedal,
                    DefaultEffectorRotationTargetName=IK_AcceleratorPedal
                ),
                HipsIKInfo=
                (
                    PinEnabled=true,
                    DefaultEffectorLocationTargetName=DriverAttach,
                    DefaultEffectorRotationTargetName=DriverAttach,
                ),
                PositionFlinchAnims=(Driver_idle),
                PositionDeathAnims=(Driver_Death),
                LookAtInfo=
                (
                    LookAtEnabled=true,
                    DefaultLookAtTargetName=LookAt_Driver,
                    HeadInfluence=1.0,
                    BodyInfluence=1.0
                )
            ),
        )
    )}

    Seats(1)={(
        bNonEnterable=true, // TODO: non-enterable for testing!
        CameraTag=none,
        bSeatVisible=true,
        CameraOffset=-420,
        DriverDamageMult=1.0,
        SeatAnimBlendName=Pass1PositionNode,
        SeatBone=PassengerAttach_FrontRight,
        InitialPositionIndex=0,
        SeatRotation=(Pitch=0,Yaw=0,Roll=0),
        SeatOffset=(X=0,Y=0,Z=0),
        TurretVarPrefix="PassengerOne",
        SeatPositions=
        (
            // 0
            (
                SeatProxyIndex=1,
                bDriverVisible=true,
                bAllowFocus=true,
                PositionCameraTag=None,
                bIsExterior=true,
                ViewFOV=0.0,
                PositionIdleAnim=Pass04_Idle,
                DriverIdleAnim=Pass04_Idle,
                AlternateIdleAnim=Pass04_Idle,
                PositionFlinchAnims=(Pass04_Idle),
                PositionDeathAnims=(Pass04_Death),
                HipsIKInfo=
                (
                    PinEnabled=true,
                    DefaultEffectorLocationTargetName=PassengerAttach_FrontRight,
                    DefaultEffectorRotationTargetName=PassengerAttach_FrontRight,
                ),
                LeftFootIKInfo=
                (
                    IKEnabled=true,
                    DefaultEffectorLocationTargetName=IK_Passenger_Front_LeftFoot,
                    DefaultEffectorRotationTargetName=IK_Passenger_Front_LeftFoot
                ),
                RightFootIKInfo=
                (
                    IKEnabled=true,
                    DefaultEffectorLocationTargetName=IK_Passenger_Front_RightFoot,
                    DefaultEffectorRotationTargetName=IK_Passenger_Front_RightFoot
                ),
                LookAtInfo=
                (
                    LookAtEnabled=true,
                    DefaultLookAtTargetName=LookAt_Passenger_FrontRight,
                    HeadInfluence=1.0,
                    BodyInfluence=1.0
                ),
                LeftHandIKInfo=
                (
                    IKEnabled=false,
                    DefaultEffectorLocationTargetName=PointAt_Passenger_FrontRight,
                    DefaultEffectorRotationTargetName=PointAt_Passenger_FrontRight
                ),
            )
        )
    )}

    Seats(2)={(
        bNonEnterable=true, // TODO: non-enterable for testing!
        CameraTag=none,
        bSeatVisible=true,
        CameraOffset=-420,
        DriverDamageMult=1.0,
        SeatAnimBlendName=Pass2PositionNode,
        SeatBone=PassengerAttach_RearRight,
        InitialPositionIndex=0,
        SeatRotation=(Pitch=0,Yaw=0,Roll=0),
        SeatOffset=(X=0,Y=0,Z=0),
        TurretVarPrefix="PassengerTwo",
        SeatPositions=
        (
            // 0
            (
                SeatProxyIndex=2,
                bDriverVisible=true,
                bAllowFocus=true,
                PositionCameraTag=None,
                bIsExterior=true,
                ViewFOV=0.0,
                PositionIdleAnim=Pass04_Idle,
                DriverIdleAnim=Pass04_Idle,
                AlternateIdleAnim=Pass04_Idle,
                PositionFlinchAnims=(Pass04_Idle),
                PositionDeathAnims=(Pass04_Death),
                HipsIKInfo=
                (
                    PinEnabled=true,
                    DefaultEffectorLocationTargetName=PassengerAttach_RearRight,
                    DefaultEffectorRotationTargetName=PassengerAttach_RearRight,
                ),
                LookAtInfo=
                (
                    LookAtEnabled=true,
                    DefaultLookAtTargetName=LookAt_Passenger_RearRight,
                    HeadInfluence=1.0,
                    BodyInfluence=1.0
                ),
                LeftHandIKInfo=
                (
                    IKEnabled=false,
                    DefaultEffectorLocationTargetName=PointAt_Passenger_RearRight,
                    DefaultEffectorRotationTargetName=PointAt_Passenger_RearRight
                ),
                LeftFootIKInfo=
                (
                    IKEnabled=true,
                    DefaultEffectorLocationTargetName=IK_Passenger_RearRight_LeftFoot,
                    DefaultEffectorRotationTargetName=IK_Passenger_RearRight_LeftFoot,
                ),
                RightFootIKInfo=
                (
                    IKEnabled=true,
                    DefaultEffectorLocationTargetName=IK_Passenger_RearRight_RightFoot,
                    DefaultEffectorRotationTargetName=IK_Passenger_RearRight_RightFoot,
                ),
            )
        )
    )}

    Seats(3)={(
        bNonEnterable=false,
        CameraTag=none,
        bSeatVisible=true,
        CameraOffset=-420,
        DriverDamageMult=1.0,
        SeatAnimBlendName=Pass3PositionNode, // TODO: check that nodes are correct!
        SeatBone=PassengerAttach_RearLeft,
        InitialPositionIndex=0,
        SeatRotation=(Pitch=0,Yaw=0,Roll=0),
        SeatOffset=(X=0,Y=0,Z=0),
        TurretVarPrefix="PassengerThree",
        SeatPositions=
        (
            // 0
            (
                SeatProxyIndex=3,
                bDriverVisible=true,
                bAllowFocus=true,
                PositionCameraTag=None,
                bIsExterior=true,
                ViewFOV=0.0,
                PositionIdleAnim=Pass04_Idle,
                DriverIdleAnim=Pass04_Idle,
                AlternateIdleAnim=Pass04_Idle,
                PositionFlinchAnims=(Pass04_Idle),
                PositionDeathAnims=(Pass04_Death),
                HipsIKInfo=
                (
                    PinEnabled=true,
                    DefaultEffectorLocationTargetName=PassengerAttach_RearLeft,
                    DefaultEffectorRotationTargetName=PassengerAttach_RearLeft,
                ),
                LookAtInfo=
                (
                    LookAtEnabled=true,
                    DefaultLookAtTargetName=LookAt_Passenger_RearLeft,
                    HeadInfluence=1.0,
                    BodyInfluence=1.0
                ),
                LeftHandIKInfo=
                (
                    IKEnabled=true,
                    DefaultEffectorLocationTargetName=PointAt_Passenger_RearLeft,
                    DefaultEffectorRotationTargetName=PointAt_Passenger_RearLeft
                ),
                LeftFootIKInfo=
                (
                    IKEnabled=true,
                    DefaultEffectorLocationTargetName=IK_Passenger_RearLeft_LeftFoot,
                    DefaultEffectorRotationTargetName=IK_Passenger_RearLeft_LeftFoot,
                ),
                RightFootIKInfo=
                (
                    IKEnabled=true,
                    DefaultEffectorLocationTargetName=IK_Passenger_RearLeft_RightFoot,
                    DefaultEffectorRotationTargetName=IK_Passenger_RearLeft_RightFoot,
                ),
            )
        )
    )}

    Begin Object Name=RRWheel
        BoneName="R_Wheel_Rear"
        BoneOffset=(X=0.0,Y=0,Z=0.0)//(X=0.0,Y=20.0,Z=0.0)
        WheelRadius=17
        LongSlipFactor=2.0
        LatSlipFactor=1.5
        HandbrakeLongSlipFactor=0.2
        HandbrakeLatSlipFactor=0.1
        ParkedSlipFactor=2.0
        SkelControlName="R_Wheel_Rear"
        bPoweredWheel=true
        SuspensionTravel=4.8
    End Object

    Begin Object Name=LRWheel
        BoneName="L_Wheel_Rear"
        BoneOffset=(X=0.0,Y=0,Z=0.0)//(X=0.0,Y=-20.0,Z=0.0)
        WheelRadius=17
        LongSlipFactor=2.0
        LatSlipFactor=1.5
        HandbrakeLongSlipFactor=0.2
        HandbrakeLatSlipFactor=0.1
        ParkedSlipFactor=2.0
        SkelControlName="L_Wheel_Rear"
        bPoweredWheel=true
        SuspensionTravel=4.8
    End Object

    Begin Object Name=RFWheel
        BoneName="R_Wheel_Front"
        BoneOffset=(X=0.0,Y=0,Z=0.0)//(X=0.0,Y=20.0,Z=0.0)
        WheelRadius=17
        SteerFactor=1.0
        LongSlipFactor=2.0
        LatSlipFactor=1.5
        HandbrakeLongSlipFactor=2.0
        HandbrakeLatSlipFactor=1.5
        ParkedSlipFactor=2.0
        SkelControlName="R_Wheel_Front"
        bPoweredWheel=true
        SuspensionTravel=4.0
    End Object

    Begin Object Name=LFWheel
        BoneName="L_Wheel_Front"
        BoneOffset=(X=0.0,Y=0,Z=0.0)//(X=0.0,Y=-20.0,Z=0.0)
        SteerFactor=1.0
        WheelRadius=17
        LongSlipFactor=2.0
        LatSlipFactor=1.5
        HandbrakeLongSlipFactor=2.0
        HandbrakeLatSlipFactor=1.5
        ParkedSlipFactor=2.0
        SkelControlName="L_Wheel_Front"
        bPoweredWheel=true
        SuspensionTravel=4.0
    End Object

    Begin Object Name=SimObject
        bClampedFrictionModel=True
        bAutoHandbrake=True

        SpeedBasedTurnDamping=5

        HardTurnMotorTorque=1.0

        AirControlTurnTorque=0.0//0.2
        InAirUprightTorqueFactor=0.0//-1.0
        InAirUprightMaxTorque=0.0//5.0

        MaxBrakeTorque=7.0
        EngineBrakeFactor=0.001000

        StopThreshold=75

        ChassisTorqueScale=150.0

        WheelSuspensionBias=0.1
        WheelSuspensionDamping=40
        WheelSuspensionStiffness=2300

        MaxSteerAngleCurve={(
            Points=
            (
                (InVal=0,OutVal=35),
                (InVal=600.0,OutVal=20.0),
                (InVal=1100.0,OutVal=10.0),
                (InVal=1300.0,OutVal=7.5),
                (InVal=1600.0,OutVal=1.0)
            )
        )}
        SteerSpeed=35

        LSDFactor=0.0

        TorqueVSpeedCurve={(
            Points=
            (
                (InVal=-600.0,OutVal=0.0),
                (InVal=-300.0,OutVal=5.0),
                (InVal=0.0,OutVal=20.0),
                (InVal=950.0,OutVal=5.0),
                (InVal=1050.0,OutVal=0.5),
                (InVal=1150.0,OutVal=0.0)
            )
        )}

        EngineRPMCurve={(
            Points=
            (
                (InVal=-500.0,OutVal=2500.0),
                (InVal=0.0,OutVal=500.0),
                (InVal=549.0,OutVal=3500.0),
                (InVal=550.0,OutVal=1000.0),
                (InVal=849.0,OutVal=4500.0),
                (InVal=850.0,OutVal=1500.0),
                (InVal=1100.0,OutVal=5000.0)
            )
        )}

        ThrottleSpeed=0.4

        // Longitudinal tire model based on 10% slip ratio peak
        WheelLongExtremumSlip=0.1
        WheelLongExtremumValue=1.0
        WheelLongAsymptoteSlip=2.0
        WheelLongAsymptoteValue=0.6

        // Lateral tire model based on slip angle (radians)
        WheelLatExtremumSlip=0.35     // 20 degrees
        WheelLatExtremumValue=0.9
        WheelLatAsymptoteSlip=1.4     // 80 degrees
        WheelLatAsymptoteValue=0.9
    End Object

    // SteeringWheelSkelControlName=SteeringWheel

    SeatTextureOffsets(0)=(PositionOffSet=(X=-5,Y=+10,Z=0),bTurretPosition=0)
	SeatTextureOffsets(1)=(PositionOffSet=(X=+5,Y=+10,Z=0),bTurretPosition=0)
	SeatTextureOffsets(2)=(PositionOffSet=(X=+5,Y=-10,Z=0),bTurretPosition=0)
	SeatTextureOffsets(3)=(PositionOffSet=(X=-5,Y=-10,Z=0),bTurretPosition=0)

    DefaultPhysicalMaterial=PhysicalMaterial'VH_VN_US_UH1H.Phys.PhysMat_UH1H'
    DrivingPhysicalMaterial=PhysicalMaterial'VH_VN_US_UH1H.Phys.PhysMat_UH1H'

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

    // MaxSpeed=1365 // ~100 km/h // 723 = 53 km/h
    MaxSpeed=3000

    AirSpeed=2500
    GroundSpeed=1365 // ~100 km/h.

    // TODO:
    RanOverDamageType=RODamageType_RunOver
}
