class PMVehicle_PanzerIVG_Content extends PMVehicle_PanzerIVG
    placeable;

DefaultProperties
{
    // ------------------------------- Mesh --------------------------------------------------------------

    Begin Object Name=ROSVehicleMesh
        SkeletalMesh=SkeletalMesh'PM_VH_Panzer_IVG.Mesh.Ger_PZIV_Rig_Master'
        AnimTreeTemplate=AnimTree'PM_VH_Panzer_IVG.Anim.AT_VH_PanzerIVG_New'
        PhysicsAsset=PhysicsAsset'PM_VH_Panzer_IVG.Phys.Ger_PZIV_Rig_new_Physics'
        AnimSets.Add(AnimSet'PM_VH_Panzer_IVG.Anim.PZIV_anim_Master')
        AnimSets.Add(AnimSet'PM_VH_Panzer_IVG.Anim.PZIV_Destroyed_anim_Master')
    End Object

    // -------------------------------- Sounds -----------------------------------------------------------

    // TODO: NO AUDIO FOR PROTOTYPE TANK
    // Engine start sounds
    Begin Object Class=AudioComponent Name=StartEngineLSound
        // SoundCue=SoundCue'AUD_Vehicle_Tank_PanzerIV.Movement.Panzer_Movement_Engine_Start_Cabin_L_Cue'
    End Object
    EngineStartLeftSoundCustom=StartEngineLSound

    Begin Object Class=AudioComponent Name=StartEngineRSound
        // SoundCue=SoundCue'AUD_Vehicle_Tank_PanzerIV.Movement.Panzer_Movement_Engine_Start_Cabin_R_Cue'
    End Object
    EngineStartRightSoundCustom=StartEngineRSound

    Begin Object Class=AudioComponent Name=StartEngineExhaustSound
        // SoundCue=SoundCue'AUD_Vehicle_Tank_PanzerIV.Movement.Panzer_Movement_Engine_Start_Exhaust_Cue'
    End Object
    EngineStartExhaustSoundCustom=StartEngineExhaustSound

    // Engine idle sounds
    Begin Object Class=AudioComponent Name=IdleEngineLeftSound
        // SoundCue=SoundCue'AUD_Vehicle_Tank_PanzerIV.Movement.Panzer_Movement_Engine_Run_Cabin_L_Cue'
        bShouldRemainActiveIfDropped=TRUE
    End Object
    EngineIntLeftSoundCustom=IdleEngineLeftSound

    Begin Object Class=AudioComponent Name=IdleEngineRighSound
        // SoundCue=SoundCue'AUD_Vehicle_Tank_PanzerIV.Movement.Panzer_Movement_Engine_Run_Cabin_R_Cue'
        bShouldRemainActiveIfDropped=TRUE
    End Object
    EngineIntRightSoundCustom=IdleEngineRighSound

    Begin Object Class=AudioComponent Name=IdleEngineExhaustSound
        // SoundCue=SoundCue'AUD_Vehicle_Tank_PanzerIV.Movement.Panzer_Movement_Engine_Run_Exhaust_Cue'
        bShouldRemainActiveIfDropped=TRUE
    End Object
    EngineSoundCustom=IdleEngineExhaustSound

    Begin Object Class=AudioComponent Name=StopEngineSound
        // TODO: stopsound SoundCue=SoundCue'AUD_Vehicle_Tank_PanzerIV.Movement.Panzer_Movement_Engine_Run_Exhaust_Cue'
    End Object
    EngineStopSoundCustom=StopEngineSound

    // Track sounds
    Begin Object Class=AudioComponent Name=TrackLSound
        // SoundCue=SoundCue'AUD_Vehicle_Tank_PanzerIV.Movement.Panzer_Movement_Treads_L_Cue'
    End Object
    TrackLeftSoundCustom=TrackLSound

    Begin Object Class=AudioComponent Name=TrackRSound
        // SoundCue=SoundCue'AUD_Vehicle_Tank_PanzerIV.Movement.Panzer_Movement_Treads_R_Cue'
    End Object
    TrackRightSoundCustom=TrackRSound

    // Brake sounds
    Begin Object Class=AudioComponent Name=BrakeLeftSnd
        // SoundCue=SoundCue'AUD_Vehicle_Tank_PanzerIV.Movement.Panzer_Movement_Treads_Brake_Cue'
    End Object
    BrakeLeftSoundCustom=BrakeLeftSnd

    Begin Object Class=AudioComponent Name=BrakeRightSnd
        // SoundCue=SoundCue'AUD_Vehicle_Tank_PanzerIV.Movement.Panzer_Movement_Treads_Brake_Cue'
    End Object
    BrakeRightSoundCustom=BrakeRightSnd

    /*
    // Damage sounds
    EngineIdleDamagedSoundCustom=SoundCue'AUD_Vehicle_Tank_PanzerIV.Movement.Panzer_Movement_Engine_Broken_Cue'
    TrackTakeDamageSoundCustom=SoundCue'AUD_Vehicle_Tank_PanzerIV.Movement.Panzer_Movement_Treads_Brake_Cue'
    TrackDamagedSoundCustom=SoundCue'AUD_Vehicle_Tank_PanzerIV.Movement.Panzer_Movement_Treads_Broken_Cue'
    TrackDestroyedSoundCustom=SoundCue'AUD_Vehicle_Tank_PanzerIV.Movement.Panzer_Movement_Treads_Skid_Cue'
    */

    // Destroyed tranmission
    Begin Object Class=AudioComponent Name=BrokenTransmissionSnd
        // SoundCue=SoundCue'AUD_Vehicle_Tank_PanzerIV.Movement.Panzer_Movement_Transmission_Broken_Cue'
        bStopWhenOwnerDestroyed=TRUE
    End Object
    BrokenTransmissionSoundCustom=BrokenTransmissionSnd

    /*
    // Gear shift sounds
    ShiftUpSoundCustom=SoundCue'AUD_Vehicle_Tank_PanzerIV.Movement.Panzer_Movement_Engine_Exhaust_ShiftUp_Cue'
    ShiftDownSoundCustom=SoundCue'AUD_Vehicle_Tank_PanzerIV.Movement.Panzer_Movement_Engine_Exhaust_ShiftDown_Cue'
    ShiftLeverSoundCustom=SoundCue'AUD_Vehicle_Tank_PanzerIV.Foley.Panzer_Lever_GearShift_Cue'
    */

    // Turret sounds
    Begin Object Class=AudioComponent Name=TurretTraverseComponent
        // SoundCue=SoundCue'AUD_Vehicle_Tank_PanzerIV.Turret.Turret_Traverse_Manual_Cue'
    End Object
    TurretTraverseSoundCustom=TurretTraverseComponent
    Components.Add(TurretTraverseComponent);

    Begin Object Class=AudioComponent Name=TurretMotorTraverseComponent
        // SoundCue=SoundCue'AUD_Vehicle_Tank_PanzerIV.Turret.Turret_Traverse_Electric_Cue'
    End Object
    TurretMotorTraverseSoundCustom=TurretMotorTraverseComponent
    Components.Add(TurretMotorTraverseComponent);

    Begin Object Class=AudioComponent Name=TurretElevationComponent
        // SoundCue=SoundCue'AUD_Vehicle_Tank_PanzerIV.Turret.Turret_Elevate_Cue'
    End Object
    TurretElevationSoundCustom=TurretElevationComponent
    Components.Add(TurretElevationComponent);

    Begin Object Class=AudioComponent name=HullMGSoundComponent
        bShouldRemainActiveIfDropped=true
        bStopWhenOwnerDestroyed=true
        // SoundCue=SoundCue'AUD_Vehicle_Tank_PanzerIV.Weapon.MG_MG34_Fire_Loop_M_Cue'
    End Object
    HullMGAmbient=HullMGSoundComponent
    Components.Add(HullMGSoundComponent)

    Begin Object Class=AudioComponent name=CoaxMGSoundComponent
        bShouldRemainActiveIfDropped=true
        bStopWhenOwnerDestroyed=true
        // SoundCue=SoundCue'AUD_Vehicle_Tank_PanzerIV.Weapon.MG_MG34_Fire_Loop_M_Cue'
    End Object
    CoaxMGAmbient=CoaxMGSoundComponent
    Components.Add(CoaxMGSoundComponent)

    /*
    ExplosionSoundCustom=SoundCue'AUD_EXP_Tanks.A_CUE_Tank_Explode'

    HullMGStopSoundCustom=SoundCue'AUD_Vehicle_Tank_PanzerIV.Weapon.MG_MG34_Fire_LoopEnd_M_Cue'
    CoaxMGStopSoundCustom=SoundCue'AUD_Vehicle_Tank_PanzerIV.Weapon.MG_MG34_Fire_LoopEnd_M_Cue'
    */

    // -------------------------------- Dead -----------------------------------------------------------

    DestroyedSkeletalMesh=SkeletalMesh'PM_VH_Panzer_IVG.Mesh.Ger_PZIV_Destroyed_Master'
    DestroyedSkeletalMeshWithoutTurret=SkeletalMesh'PM_VH_Panzer_IVG.Mesh.Ger_PZIV_Body_Destroyed_Master'
    DestroyedPhysicsAsset=PhysicsAsset'PM_VH_Panzer_IVG.Phys.Ger_PZIV_Destroyed_Physics'
    DestroyedMaterial=MaterialInstanceConstant'PM_VH_Panzer_IVG.Materials.VH_Ger_Panzer_IVG_Destroyed_Mic'
    DestroyedFXMaterial=Material'PM_M_Vehicles.M_Common_Vehicles.Tank_Fireplanes'
    DestroyedTurretClass=class'PMVehicleDeathTurret_PanzerIVG'

    // HUD.
    HUDBodyTexture=Texture2D'PM_UI_Textures.HUD.Vehicles.ui_hud_tank_pz4_body'
    HUDTurretTexture=Texture2D'PM_UI_Textures.HUD.Vehicles.ui_hud_tank_pz4_turret'
    DriverOverlayTexture=Texture2D'PM_UI_Textures.VehicleOptics.ui_hud_vehicle_optics_PZIV_driver'
    HUDMainCannonTexture=Texture2D'PM_UI_Textures.HUD.Vehicles.ui_hud_tank_GunPZ'
    HUDGearBoxTexture=Texture2D'PM_UI_Textures.HUD.Vehicles.ui_hud_tank_transmition_PZ'
    HUDFrontArmorTexture=Texture2D'PM_UI_Textures.HUD.Vehicles.ui_tank_hud_PZ4armor_front'
    HUDBackArmorTexture=Texture2D'PM_UI_Textures.HUD.Vehicles.ui_tank_hud_PZ4armor_back'
    HUDLeftArmorTexture=Texture2D'PM_UI_Textures.HUD.Vehicles.ui_tank_hud_PZ4armor_left'
    HUDRightArmorTexture=Texture2D'PM_UI_Textures.HUD.Vehicles.ui_tank_hud_PZ4armor_right'
    HUDTurretFrontArmorTexture=Texture2D'PM_UI_Textures.HUD.Vehicles.ui_tank_hud_PZ4armor_turretfront'
    HUDTurretBackArmorTexture=Texture2D'PM_UI_Textures.HUD.Vehicles.ui_tank_hud_PZ4armor_turretback'
    HUDTurretLeftArmorTexture=Texture2D'PM_UI_Textures.HUD.Vehicles.ui_tank_hud_PZ4armor_turretleft'
    HUDTurretRightArmorTexture=Texture2D'PM_UI_Textures.HUD.Vehicles.ui_tank_hud_PZ4armor_turretright'

    RoleSelectionImage=Texture2D'PM_UI_Textures.RoleSelection.Textures.ger_tank_pzIVg'

    // TODO: add crew mesh/gear/headgear stuff etc.

    // NOTE: IMPORTANT!
    // MAKE SURE ALL SEAT PROXY INDICES ARE EQUAL TO THEIR SEAT INCIDES!
    // THIS IS DUE TO THE CHANGES I'VE MADE IN SEAT PROXY ACTOR HANDLING!
    // VANILLA TANK CODE DOESN'T HAVE THIS EXPECTATION!

    // Driver.
    SeatProxies(`SI_PZ_IVG_DRIVER)={(
        TunicMeshType=SkeletalMesh'CHR_VN_US_Army.Mesh.US_Tunic_Long_Mesh',
        HeadGearMeshType=None,
        HeadAndArmsMeshType=SkeletalMesh'CHR_VN_US_Heads.Mesh.US_Head1_Mesh',
        HeadphonesMeshType=none,
        HeadAndArmsMICTemplate=MaterialInstanceConstant'CHR_VN_US_Heads.Materials.M_US_Head_01_Long_INST',
        BodyMICTemplate=MaterialInstanceConstant'CHR_VN_US_Army.Materials.M_US_Tunic_Long_INST',
        SeatIndex=`SI_PZ_IVG_DRIVER,
        PositionIndex=1)}

    // Commander.
    SeatProxies(`SI_PZ_IVG_COMMDR)={(
        TunicMeshType=SkeletalMesh'CHR_VN_US_Army.Mesh.US_Tunic_Long_Mesh',
        HeadGearMeshType=None,
        HeadAndArmsMeshType=SkeletalMesh'CHR_VN_US_Heads.Mesh.US_Head1_Mesh',
        HeadphonesMeshType=none,
        HeadAndArmsMICTemplate=MaterialInstanceConstant'CHR_VN_US_Heads.Materials.M_US_Head_01_Long_INST',
        BodyMICTemplate=MaterialInstanceConstant'CHR_VN_US_Army.Materials.M_US_Tunic_Long_INST',
        SeatIndex=`SI_PZ_IVG_COMMDR,
        PositionIndex=1)}

    // Gunner.
    SeatProxies(`SI_PZ_IVG_GUNNER)={(
        TunicMeshType=SkeletalMesh'CHR_VN_US_Army.Mesh.US_Tunic_Long_Mesh',
        HeadGearMeshType=None,
        HeadAndArmsMeshType=SkeletalMesh'CHR_VN_US_Heads.Mesh.US_Head1_Mesh',
        HeadphonesMeshType=none,
        HeadAndArmsMICTemplate=MaterialInstanceConstant'CHR_VN_US_Heads.Materials.M_US_Head_01_Long_INST',
        BodyMICTemplate=MaterialInstanceConstant'CHR_VN_US_Army.Materials.M_US_Tunic_Long_INST',
        SeatIndex=`SI_PZ_IVG_GUNNER,
        PositionIndex=0)}

    // Hull MG.
    SeatProxies(`SI_PZ_IVG_HULLMG)={(
        TunicMeshType=SkeletalMesh'CHR_VN_US_Army.Mesh.US_Tunic_Long_Mesh',
        HeadGearMeshType=None,
        HeadAndArmsMeshType=SkeletalMesh'CHR_VN_US_Heads.Mesh.US_Head1_Mesh',
        HeadphonesMeshType=none,
        HeadAndArmsMICTemplate=MaterialInstanceConstant'CHR_VN_US_Heads.Materials.M_US_Head_01_Long_INST',
        BodyMICTemplate=MaterialInstanceConstant'CHR_VN_US_Army.Materials.M_US_Tunic_Long_INST',
        SeatIndex=`SI_PZ_IVG_HULLMG,
        PositionIndex=2)}

    // Loader.
    SeatProxies(`SI_PZ_IVG_LOADER)={(
        TunicMeshType=SkeletalMesh'CHR_VN_US_Army.Mesh.US_Tunic_Long_Mesh',
        HeadGearMeshType=None,
        HeadAndArmsMeshType=SkeletalMesh'CHR_VN_US_Heads.Mesh.US_Head1_Mesh',
        HeadphonesMeshType=none,
        HeadAndArmsMICTemplate=MaterialInstanceConstant'CHR_VN_US_Heads.Materials.M_US_Head_01_Long_INST',
        BodyMICTemplate=MaterialInstanceConstant'CHR_VN_US_Army.Materials.M_US_Tunic_Long_INST',
        SeatIndex=`SI_PZ_IVG_LOADER,
        PositionIndex=0)}

    // Seat proxy animations.
    SeatProxyAnimSet=AnimSet'CHR_Playeranim_Master.Anim.CHR_Panzer4G_Anim_Master'

    //----------------------------------------------------------------
    //                 Tank Attachments
    //
    // Exterior attachments use the exterior light environment,
    // accept light from the dominant directional light only and
    // cast shadows
    //
    // Interior attachments use the interior light environment,
    // accept light from both the dominant directional light and
    // the vehicle interior lights. They do not usually cast shadows.
    // Exceptions are attachments which share a part of the mesh with
    // the exterior.
    //----------------------------------------------------------------

    // NOTE: setting the static mesh materials here because I can't
    // be arsed to re-import every mesh to be able to apply the materials
    // to them in the editor. (Setting them in the editor doesn't persist
    // for static meshes in cooked packages).

    // -------------- Exterior attachments ------------------//

    Begin Object class=StaticMeshComponent name=ExtBodyAttachment0
        StaticMesh=StaticMesh'PM_VH_Panzer_IVG_Interior.Mesh.VH_SM_PzIVG_Ext_Body'
        Materials(0)=MaterialInstanceConstant'PM_VH_Panzer_IVG.Materials.VH_Ger_Panzer_IVG_Mic'
        // Materials(1)=TODO TREAD L
        // Materials(2)=TODO TREAD R
        LightingChannels=(Dynamic=TRUE,Unnamed_1=FALSE,bInitialized=TRUE)
        LightEnvironment=MyLightEnvironment
        CastShadow=true
        DepthPriorityGroup=SDPG_Foreground
        HiddenGame=true
        CollideActors=false
        BlockActors=false
        BlockZeroExtent=false
        BlockNonZeroExtent=false
    End Object

    Begin Object class=StaticMeshComponent name=ExtBodyAttachment1
        StaticMesh=StaticMesh'PM_VH_Panzer_IVG_Interior.Mesh.VH_SM_PzIVG_Ext_Turret'
        Materials(0)=MaterialInstanceConstant'PM_VH_Panzer_IVG.Materials.VH_Ger_Panzer_IVG_Mic'
        LightingChannels=(Dynamic=TRUE,Unnamed_1=FALSE,bInitialized=TRUE)
        LightEnvironment=MyLightEnvironment
        CastShadow=true
        DepthPriorityGroup=SDPG_Foreground
        HiddenGame=true
        CollideActors=false
        BlockActors=false
        BlockZeroExtent=false
        BlockNonZeroExtent=false
    End Object

    Begin Object class=StaticMeshComponent name=ExtBodyAttachment2
        StaticMesh=StaticMesh'PM_VH_Panzer_IVG_Interior.Mesh.VH_SM_PzIVG_Ext_GunBase'
        Materials(0)=MaterialInstanceConstant'PM_VH_Panzer_IVG.Materials.VH_Ger_Panzer_IVG_Mic'
        LightingChannels=(Dynamic=TRUE,Unnamed_1=FALSE,bInitialized=TRUE)
        LightEnvironment=MyLightEnvironment
        CastShadow=true
        DepthPriorityGroup=SDPG_Foreground
        HiddenGame=true
        CollideActors=false
        BlockActors=false
        BlockZeroExtent=false
        BlockNonZeroExtent=false
    End Object

    Begin Object class=StaticMeshComponent name=ExtBodyAttachment3
        StaticMesh=StaticMesh'PM_VH_Panzer_IVG_Interior.Mesh.VH_SM_PzIVG_Ext_Barrel'
        Materials(0)=MaterialInstanceConstant'PM_VH_Panzer_IVG.Materials.VH_Ger_Panzer_IVG_Mic'
        LightingChannels=(Dynamic=TRUE,Unnamed_1=FALSE,bInitialized=TRUE)
        LightEnvironment=MyLightEnvironment
        CastShadow=true
        DepthPriorityGroup=SDPG_Foreground
        HiddenGame=true
        CollideActors=false
        BlockActors=false
        BlockZeroExtent=false
        BlockNonZeroExtent=false
    End Object

    Begin Object class=StaticMeshComponent name=ExtBodyAttachment4
        StaticMesh=StaticMesh'PM_VH_Panzer_IVG_Interior.Mesh.VH_SM_PzIVG_Ext_MG'
        Materials(0)=MaterialInstanceConstant'PM_VH_Panzer_IVG.Materials.VH_Ger_Panzer_IVG_Mic'
        LightingChannels=(Dynamic=TRUE,Unnamed_1=FALSE,bInitialized=TRUE)
        LightEnvironment=MyLightEnvironment
        CastShadow=true
        DepthPriorityGroup=SDPG_Foreground
        HiddenGame=true
        CollideActors=false
        BlockActors=false
        BlockZeroExtent=false
        BlockNonZeroExtent=false
    End Object

    // -------------- Interior attachments ------------------//

    Begin Object class=StaticMeshComponent name=IntBodyAttachment0
        StaticMesh=StaticMesh'PM_VH_Panzer_IVG_Interior.Mesh.VH_SM_PzIVG_Int_Body'
        Materials(0)=MaterialInstanceConstant'PM_VH_Panzer_IVG_Interior.Materials.VH_Ger_Panzer_IVG_Int_Tile_Mic'
        Materials(1)=MaterialInstanceConstant'PM_VH_Panzer_IVG_Interior.Materials.VH_Ger_Panzer_IVG_Int_Driver_Mic'
        Materials(2)=MaterialInstanceConstant'PM_VH_Panzer_IVG_Interior.Materials.VH_Ger_Panzer_IVG_Int_Cuppola_Mic'
        LightingChannels=(Dynamic=FALSE,Unnamed_1=TRUE,bInitialized=TRUE)
        LightEnvironment=MyInteriorLightEnvironment
        CastShadow=false
        DepthPriorityGroup=SDPG_Foreground
        HiddenGame=true
        CollideActors=false
        BlockActors=false
        BlockZeroExtent=false
        BlockNonZeroExtent=false
    End Object

    Begin Object class=StaticMeshComponent name=IntBodyAttachment6
        StaticMesh=StaticMesh'PM_VH_Panzer_IVG_Interior.Mesh.VH_SM_PzIVG_Int_Main_Ammo'
        Materials(0)=MaterialInstanceConstant'PM_VH_Panzer_IVG_Interior.Materials.VH_Ger_Panzer_IVG_Int_Tile_Mic'
        Materials(1)=MaterialInstanceConstant'PM_VH_Panzer_IVG_Interior.Materials.VH_Ger_Panzer_IVG_Int_Cuppola_Mic'
        LightingChannels=(Dynamic=TRUE,Unnamed_1=TRUE,bInitialized=TRUE)
        LightEnvironment=MyInteriorLightEnvironment
        CastShadow=false
        DepthPriorityGroup=SDPG_Foreground
        HiddenGame=true
        CollideActors=false
        BlockActors=false
        BlockZeroExtent=false
        BlockNonZeroExtent=false
    End Object

    Begin Object class=StaticMeshComponent name=IntBodyAttachment8
        StaticMesh=StaticMesh'PM_VH_Panzer_IVG_Interior.Mesh.VH_SM_PzIVG_Hull_Side_1'
        Materials(0)=MaterialInstanceConstant'PM_VH_Panzer_IVG_Interior.Materials.VH_Ger_Panzer_IVG_Int_Turret_Mic'
        Materials(1)=MaterialInstanceConstant'PM_VH_Panzer_IVG_Interior.Materials.VH_Ger_Panzer_IVG_Int_Tile_Mic'
        Materials(2)=MaterialInstanceConstant'PM_VH_Panzer_IVG_Interior.Materials.VH_Ger_Panzer_IVG_Int_Driver_Mic'
        Materials(3)=Material'VH_VN_US_UH1H.Materials.M_WindowGlass_MASTER'
        LightingChannels=(Dynamic=TRUE,Unnamed_1=TRUE,bInitialized=TRUE)
        LightEnvironment=MyInteriorLightEnvironment
        CastShadow=false
        DepthPriorityGroup=SDPG_Foreground
        HiddenGame=true
        CollideActors=false
        BlockActors=false
        BlockZeroExtent=false
        BlockNonZeroExtent=false
    End Object

    Begin Object class=StaticMeshComponent name=IntBodyAttachment10
        StaticMesh=StaticMesh'PM_VH_Panzer_IVG_Interior.Mesh.VH_SM_PzIVG_Driver_Side_1'
        Materials(0)=MaterialInstanceConstant'PM_VH_Panzer_IVG_Interior.Materials.VH_Ger_Panzer_IVG_Int_Turret_Mic'
        Materials(1)=MaterialInstanceConstant'PM_VH_Panzer_IVG_Interior.Materials.VH_Ger_Panzer_IVG_Int_Tile_Mic'
        Materials(2)=MaterialInstanceConstant'PM_VH_Panzer_IVG_Interior.Materials.VH_Ger_Panzer_IVG_Int_Driver_Mic'
        Materials(3)=Material'VH_VN_US_UH1H.Materials.M_WindowGlass_MASTER'
        LightingChannels=(Dynamic=TRUE,Unnamed_1=TRUE,bInitialized=TRUE)
        LightEnvironment=MyInteriorLightEnvironment
        CastShadow=false
        DepthPriorityGroup=SDPG_Foreground
        HiddenGame=true
        CollideActors=false
        BlockActors=false
        BlockZeroExtent=false
        BlockNonZeroExtent=false
    End Object

    Begin Object class=StaticMeshComponent name=IntBodyAttachment13
        StaticMesh=StaticMesh'PM_VH_Panzer_IVG_Interior.Mesh.VH_SM_PzIVG_Int_HullMG'
        Materials(0)=MaterialInstanceConstant'PM_VH_Panzer_IVG_Interior.Materials.VH_Ger_Panzer_IVG_Int_Turret_Mic'
        Materials(1)=MaterialInstanceConstant'PM_VH_Panzer_IVG_Interior.Materials.VH_Ger_Panzer_IVG_Int_Tile_Mic'
        Materials(2)=MaterialInstanceConstant'PM_VH_Panzer_IVG_Interior.Materials.VH_Ger_Panzer_IVG_Int_Driver_Mic'
        // Materials(3)=TODO MG34 MIC
        Materials(4)=MaterialInstanceConstant'WP_VN_USA_M14.Materials.US_XM21_LenseMat'
        LightingChannels=(Dynamic=TRUE,Unnamed_1=TRUE,bInitialized=TRUE)
        LightEnvironment=MyInteriorLightEnvironment
        CastShadow=false
        DepthPriorityGroup=SDPG_Foreground
        HiddenGame=true
        CollideActors=false
        BlockActors=false
        BlockZeroExtent=false
        BlockNonZeroExtent=false
    End Object

    Begin Object class=StaticMeshComponent name=TurretAttachment0
        StaticMesh=StaticMesh'PM_VH_Panzer_IVG_Interior.Mesh.VH_SM_PzIVG_Int_Turret'
        Materials(0)=MaterialInstanceConstant'PM_VH_Panzer_IVG_Interior.Materials.VH_Ger_Panzer_IVG_Int_Turret_Mic'
        Materials(1)=MaterialInstanceConstant'PM_VH_Panzer_IVG_Interior.Materials.VH_Ger_Panzer_IVG_Int_Tile_Mic'
        LightingChannels=(Dynamic=FALSE,Unnamed_1=TRUE,bInitialized=TRUE)
        LightEnvironment=MyInteriorLightEnvironment
        CastShadow=false
        DepthPriorityGroup=SDPG_Foreground
        HiddenGame=true
        CollideActors=false
        BlockActors=false
        BlockZeroExtent=false
        BlockNonZeroExtent=false
    End Object

    Begin Object class=StaticMeshComponent name=TurretAttachment1
        StaticMesh=StaticMesh'PM_VH_Panzer_IVG_Interior.Mesh.VH_SM_PzIVG_Int_GunBase'
        Materials(0)=MaterialInstanceConstant'PM_VH_Panzer_IVG_Interior.Materials.VH_Ger_Panzer_IVG_Int_Turret_Mic'
        Materials(1)=MaterialInstanceConstant'PM_VH_Panzer_IVG_Interior.Materials.VH_Ger_Panzer_IVG_Int_Tile_Mic'
        // Materials(3)=TODO MG34 MIC
        LightingChannels=(Dynamic=TRUE,Unnamed_1=TRUE,bInitialized=TRUE)
        LightEnvironment=MyInteriorLightEnvironment
        CastShadow=false
        DepthPriorityGroup=SDPG_Foreground
        HiddenGame=true
        CollideActors=false
        BlockActors=false
        BlockZeroExtent=false
        BlockNonZeroExtent=false
    End Object

    Begin Object class=StaticMeshComponent name=TurretAttachment2
        StaticMesh=StaticMesh'PM_VH_Panzer_IVG_Interior.Mesh.VH_SM_PzIVG_Int_Coppola'
        Materials(0)=MaterialInstanceConstant'PM_VH_Panzer_IVG.Materials.VH_Ger_Panzer_IVG_Mic'
        Materials(1)=MaterialInstanceConstant'PM_VH_Panzer_IVG_Interior.Materials.VH_Ger_Panzer_IVG_Int_Tile_Mic'
        Materials(2)=MaterialInstanceConstant'PM_VH_Panzer_IVG_Interior.Materials.VH_Ger_Panzer_IVG_Int_Cuppola_Mic'
        Materials(3)=Material'VH_VN_US_UH1H.Materials.M_WindowGlass_MASTER'
        LightingChannels=(Dynamic=TRUE,Unnamed_1=TRUE,bInitialized=TRUE)
        LightEnvironment=MyInteriorLightEnvironment
        CastShadow=true
        DepthPriorityGroup=SDPG_Foreground
        HiddenGame=true
        CollideActors=false
        BlockActors=false
        BlockZeroExtent=false
        BlockNonZeroExtent=false
    End Object

    Begin Object class=StaticMeshComponent name=TurretAttachment5
        StaticMesh=StaticMesh'PM_VH_Panzer_IVG_Interior.Mesh.VH_SM_PzIVG_Int_Turret_Details_1'
        Materials(0)=MaterialInstanceConstant'PM_VH_Panzer_IVG_Interior.Materials.VH_Ger_Panzer_IVG_Int_Turret_Mic'
        Materials(1)=MaterialInstanceConstant'PM_VH_Panzer_IVG_Interior.Materials.VH_Ger_Panzer_IVG_Int_Tile_Mic'
        Materials(2)=Material'VH_VN_US_UH1H.Materials.M_WindowGlass_MASTER'
        Materials(3)=MaterialInstanceConstant'WP_VN_USA_M14.Materials.US_XM21_LenseMat'
        LightingChannels=(Dynamic=TRUE,Unnamed_1=TRUE,bInitialized=TRUE)
        LightEnvironment=MyInteriorLightEnvironment
        CastShadow=false
        DepthPriorityGroup=SDPG_Foreground
        HiddenGame=true
        CollideActors=false
        BlockActors=false
        BlockZeroExtent=false
        BlockNonZeroExtent=false
    End Object

    Begin Object class=StaticMeshComponent name=TurretAttachment7
        StaticMesh=StaticMesh'PM_VH_Panzer_IVG_Interior.Mesh.VH_SM_PzIVG_Int_Turret_Basket'
        Materials(0)=MaterialInstanceConstant'PM_VH_Panzer_IVG_Interior.Materials.VH_Ger_Panzer_IVG_Int_Turret_Mic'
        Materials(1)=MaterialInstanceConstant'PM_VH_Panzer_IVG_Interior.Materials.VH_Ger_Panzer_IVG_Int_Tile_Mic'
        Materials(2)=MaterialInstanceConstant'PM_VH_Panzer_IVG_Interior.Materials.VH_Ger_Panzer_IVG_Int_Cuppola_Mic'
        LightingChannels=(Dynamic=TRUE,Unnamed_1=TRUE,bInitialized=TRUE)
        LightEnvironment=MyInteriorLightEnvironment
        CastShadow=false
        DepthPriorityGroup=SDPG_Foreground
        HiddenGame=true
        CollideActors=false
        BlockActors=false
        BlockZeroExtent=false
        BlockNonZeroExtent=false
    End Object

    MeshAttachments(0)={(AttachmentName=ExtBodyComponent,Component=ExtBodyAttachment0,bAttachToSocket=true,AttachmentTargetName=attachments_body)}
    MeshAttachments(1)={(AttachmentName=ExtTurretComponent,Component=ExtBodyAttachment1,bAttachToSocket=true,AttachmentTargetName=attachments_turret)}
    MeshAttachments(2)={(AttachmentName=ExtGunBaseComponent,Component=ExtBodyAttachment2,bAttachToSocket=true,AttachmentTargetName=attachments_gun)}
    MeshAttachments(3)={(AttachmentName=ExtBarrelComponent,Component=ExtBodyAttachment3,bAttachToSocket=true,AttachmentTargetName=attachments_turretBarrel)}
    MeshAttachments(4)={(AttachmentName=ExtMGComponent,Component=ExtBodyAttachment4,bAttachToSocket=true,AttachmentTargetName=attachments_MGPitch)}
    MeshAttachments(5)={(AttachmentName=IntBodyComponent,Component=IntBodyAttachment0,bAttachToSocket=true,AttachmentTargetName=attachments_body)}
    MeshAttachments(6)={(AttachmentName=IntMainAmmoComponent,Component=IntBodyAttachment6,bAttachToSocket=true,AttachmentTargetName=attachments_body)}
    MeshAttachments(7)={(AttachmentName=IntHullSide1Component,Component=IntBodyAttachment8,bAttachToSocket=true,AttachmentTargetName=attachments_body)}
    MeshAttachments(8)={(AttachmentName=IntDriverSide1Component,Component=IntBodyAttachment10,bAttachToSocket=true,AttachmentTargetName=attachments_body)}
    MeshAttachments(9)={(AttachmentName=IntHullMGComponent,Component=IntBodyAttachment13,bAttachToSocket=false,AttachmentTargetName=Hull_MG_interior)}
    MeshAttachments(10)={(AttachmentName=TurretComponent,Component=TurretAttachment0,bAttachToSocket=true,AttachmentTargetName=attachments_turret)}
    MeshAttachments(11)={(AttachmentName=TurretGunGaseComponent,Component=TurretAttachment1,bAttachToSocket=true,AttachmentTargetName=attachments_gun)}
    MeshAttachments(12)={(AttachmentName=TurretCuppolaComponent,Component=TurretAttachment2,bAttachToSocket=true,AttachmentTargetName=attachments_turret)}
    MeshAttachments(13)={(AttachmentName=TurretDetails1Component,Component=TurretAttachment5,bAttachToSocket=true,AttachmentTargetName=attachments_turret)}
    MeshAttachments(14)={(AttachmentName=TurretBasketComponent,Component=TurretAttachment7,bAttachToSocket=true,AttachmentTargetName=attachments_turret)}
}
