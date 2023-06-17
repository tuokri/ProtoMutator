class PMSouthPawn extends PMPawn;

simulated event byte ScriptGetTeamNum()
{
    return `ALLIES_TEAM_INDEX;
}

DefaultProperties
{
    // Meshes
    TunicMesh=SkeletalMesh'CHR_VN_US_Army.Mesh.US_Tunic_Long_Mesh'
    HeadAndArmsMesh=SkeletalMesh'CHR_VN_US_Heads.Mesh.US_Head1_Mesh'
    FieldgearMesh=SkeletalMesh'CHR_VN_US_Army.GearMesh.US_Gear_Long_Rifleman'
    // Single-variant mesh
    PawnMesh_SV=SkeletalMesh'CHR_VN_US_Army.Mesh_Low.US_Tunic_Low_Mesh'
    // First person arms mesh
    ArmsOnlyMeshFP=SkeletalMesh'CHR_VN_1stP_Hands_Master.Mesh.VN_1stP_US_Long_Mesh'
    HeadgearMesh=SkeletalMesh'CHR_VN_US_Headgear.Mesh.US_headgear_var1'

    // Third person sockets
    HeadgearAttachSocket=helmet

    // MIC(s)
    BodyMICTemplate=MaterialInstanceConstant'CHR_VN_US_Army.Materials.M_US_Tunic_Long_INST'
    HeadAndArmsMICTemplate=MaterialInstanceConstant'CHR_VN_US_Heads.Materials.M_US_Head_01_Long_INST'
    HeadgearMICTemplate=MaterialInstanceConstant'CHR_VN_US_Headgear.Materials.M_US_Headgear_INST'

    // Southern forces specific animset
    Begin Object Name=ROPawnSkeletalMeshComponent
        AnimSets(0)=AnimSet'CHR_Playeranim_Master.Anim.CHR_Stand_anim'
        AnimSets(1)=AnimSet'CHR_Playeranim_Master.Anim.CHR_ChestCover_anim'
        AnimSets(2)=AnimSet'CHR_Playeranim_Master.Anim.CHR_WaistCover_anim'
        AnimSets(3)=AnimSet'CHR_Playeranim_Master.Anim.CHR_StandCover_anim'
        AnimSets(4)=AnimSet'CHR_Playeranim_Master.Anim.CHR_Crouch_anim'
        AnimSets(5)=AnimSet'CHR_Playeranim_Master.Anim.CHR_Prone_anim'
        AnimSets(6)=AnimSet'CHR_Playeranim_Master.Anim.CHR_Hand_Poses_Master'
        AnimSets(7)=AnimSet'CHR_Playeranim_Master.Anim.CHR_Death_anim'
        AnimSets(8)=AnimSet'CHR_Playeranim_Master.Anim.CHR_Tripod_anim'
        AnimSets(9)=AnimSet'CHR_Playeranim_Master.Anim.Special_Actions'
        AnimSets(10)=AnimSet'CHR_Playeranim_Master.Anim.CHR_Melee'
        AnimSets(11)=AnimSet'CHR_Playeranim_Master.Anim.CHR_Russian_Unique'
        AnimSets(12)=None	// Reserved for weapon specific animations
        AnimSets(13)=AnimSet'CHR_VN_Playeranim_Master.Anim.CHR_VN_Tripod_anim'
        AnimSets(14)=AnimSet'CHR_VN_Playeranim_Master.Anim.CHR_VN_Stand_anim'
        AnimSets(15)=AnimSet'CHR_VN_Playeranim_Master.Anim.CHR_VN_ChestCover_anim'
        AnimSets(16)=AnimSet'CHR_VN_Playeranim_Master.Anim.CHR_VN_WaistCover_anim'
        AnimSets(17)=AnimSet'CHR_VN_Playeranim_Master.Anim.CHR_VN_StandCover_anim'
        AnimSets(18)=AnimSet'CHR_VN_Playeranim_Master.Anim.CHR_VN_Crouch_anim'
        AnimSets(19)=AnimSet'CHR_VN_Playeranim_Master.Anim.CHR_VN_Prone_anim'
        AnimSets(20)=AnimSet'CHR_VN_Playeranim_Master.Anim.CHR_VN_Hand_Poses_Master'
        AnimSets(21)=AnimSet'CHR_VN_Playeranim_Master.Anim.VN_Special_Actions' // Package containing vine ladder anims.
    End Object

    // Gore
    Gore_LeftHand=(GibClass=class'ROGameContent.ROGib_HumanArm_Gore_BareArm')
    Gore_RightHand=(GibClass=class'ROGameContent.ROGib_HumanArm_Gore_BareArm')
    Gore_LeftLeg=(GibClass=class'ROGameContent.ROGib_HumanLeg_Gore_BareLeg')
    Gore_RightLeg=(GibClass=class'ROGameContent.ROGib_HumanLeg_Gore_BareLeg')

    bSingleHandedSprinting=false

    FootstepSounds.Add((MaterialType=EMT_Default,Sound=AkEvent'WW_FOL_US.Play_FS_US_Jog_Dirt')()
    FootstepSounds.Add((MaterialType=EMT_Rock,Sound=AkEvent'WW_FOL_US.Play_FS_US_Jog_Gravel'))
    FootstepSounds.Add((MaterialType=EMT_Dirt,Sound=AkEvent'WW_FOL_US.Play_FS_US_Jog_Dirt'))
    FootstepSounds.Add((MaterialType=EMT_Metal,Sound=AkEvent'WW_FOL_US.Play_FS_US_Jog_Metal'))
    FootstepSounds.Add((MaterialType=EMT_Wood,Sound=AkEvent'WW_FOL_US.Play_FS_US_Jog_Wood'))
    FootstepSounds.Add((MaterialType=EMT_Asphalt,Sound=AkEvent'WW_FOL_US.Play_FS_US_Jog_Rock'))
    FootstepSounds.Add((MaterialType=EMT_RedBrick,Sound=AkEvent'WW_FOL_US.Play_FS_US_Jog_Rock'))
    FootstepSounds.Add((MaterialType=EMT_WhiteBrick,Sound=AkEvent'WW_FOL_US.Play_FS_US_Jog_Rock'))
    FootstepSounds.Add((MaterialType=EMT_Plant,Sound=AkEvent'WW_FOL_US.Play_FS_US_Jog_Grass'))
    FootstepSounds.Add((MaterialType=EMT_HollowMetal,Sound=AkEvent'WW_FOL_US.Play_FS_US_Jog_Metal'))
    FootstepSounds.Add((MaterialType=EMT_HollowWood,Sound=AkEvent'WW_FOL_US.Play_FS_US_Jog_Wood'))
    FootstepSounds.Add((MaterialType=EMT_Mud,Sound=AkEvent'WW_FOL_US.Play_FS_US_Jog_Mud'))
    FootstepSounds.Add((MaterialType=EMT_Dirt,Sound=AkEvent'WW_FOL_US.Play_FS_US_Jog_Dirt'))
    FootstepSounds.Add((MaterialType=EMT_Water,Sound=AkEvent'WW_FOL_US.Play_FS_US_Jog_Water'))
    FootstepSounds.Add((MaterialType=EMT_ShallowWater,Sound=AkEvent'WW_FOL_US.Play_FS_US_Jog_Mud'))
    FootstepSounds.Add((MaterialType=EMT_Gravel,Sound=AkEvent'WW_FOL_US.Play_FS_US_Jog_Gravel'))
    FootstepSounds.Add((MaterialType=EMT_Plaster,Sound=AkEvent'WW_FOL_US.Play_FS_US_Jog_Rock'))
    FootstepSounds.Add((MaterialType=EMT_Concrete,Sound=AkEvent'WW_FOL_US.Play_FS_US_Jog_Rock'))
    FootstepSounds.Add((MaterialType=EMT_Poop,Sound=AkEvent'WW_FOL_US.Play_FS_US_Jog_Mud'))
    FootstepSounds.Add((MaterialType=EMT_Plastic,Sound=AkEvent'WW_FOL_US.Play_FS_US_Jog_Rock'))
    FootstepSounds.Add((MaterialType=EMT_Clay,Sound=AkEvent'WW_FOL_US.Play_FS_US_Jog_Dirt'))

    CrawlFootStepSounds.Add((MaterialType=EMT_Default,Sound=AkEvent'WW_FOL_US.Play_FS_US_Crawl_Dirt'))
    CrawlFootStepSounds.Add((MaterialType=EMT_Rock,Sound=AkEvent'WW_FOL_US.Play_FS_US_Crawl_Gravel'))
    CrawlFootStepSounds.Add((MaterialType=EMT_Dirt,Sound=AkEvent'WW_FOL_US.Play_FS_US_Crawl_Dirt'))
    CrawlFootStepSounds.Add((MaterialType=EMT_Metal,Sound=AkEvent'WW_FOL_US.Play_FS_US_Crawl_Metal'))
    CrawlFootStepSounds.Add((MaterialType=EMT_Wood,Sound=AkEvent'WW_FOL_US.Play_FS_US_Crawl_Wood'))
    CrawlFootStepSounds.Add((MaterialType=EMT_Asphalt,Sound=AkEvent'WW_FOL_US.Play_FS_US_Crawl_Rock'))
    CrawlFootStepSounds.Add((MaterialType=EMT_RedBrick,Sound=AkEvent'WW_FOL_US.Play_FS_US_Crawl_Rock'))
    CrawlFootStepSounds.Add((MaterialType=EMT_WhiteBrick,Sound=AkEvent'WW_FOL_US.Play_FS_US_Crawl_Rock'))
    CrawlFootStepSounds.Add((MaterialType=EMT_Plant,Sound=AkEvent'WW_FOL_US.Play_FS_US_Crawl_Grass'))
    CrawlFootStepSounds.Add((MaterialType=EMT_HollowMetal,Sound=AkEvent'WW_FOL_US.Play_FS_US_Crawl_Metal'))
    CrawlFootStepSounds.Add((MaterialType=EMT_HollowWood,Sound=AkEvent'WW_FOL_US.Play_FS_US_Crawl_Wood'))
    CrawlFootStepSounds.Add((MaterialType=EMT_Mud,Sound=AkEvent'WW_FOL_US.Play_FS_US_Crawl_Mud'))
    CrawlFootStepSounds.Add((MaterialType=EMT_Dirt,Sound=AkEvent'WW_FOL_US.Play_FS_US_Crawl_Dirt'))
    CrawlFootStepSounds.Add((MaterialType=EMT_Water,Sound=AkEvent'WW_FOL_US.Play_FS_US_Crawl_Water'))
    CrawlFootStepSounds.Add((MaterialType=EMT_ShallowWater,Sound=AkEvent'WW_FOL_US.Play_FS_US_Crawl_Water'))
    CrawlFootStepSounds.Add((MaterialType=EMT_Gravel,Sound=AkEvent'WW_FOL_US.Play_FS_US_Crawl_Gravel'))
    CrawlFootStepSounds.Add((MaterialType=EMT_Plaster,Sound=AkEvent'WW_FOL_US.Play_FS_US_Crawl_Rock'))
    CrawlFootStepSounds.Add((MaterialType=EMT_Concrete,Sound=AkEvent'WW_FOL_US.Play_FS_US_Crawl_Rock'))
    CrawlFootStepSounds.Add((MaterialType=EMT_Poop,Sound=AkEvent'WW_FOL_US.Play_FS_US_Crawl_Mud'))
    CrawlFootStepSounds.Add((MaterialType=EMT_Plastic,Sound=AkEvent'WW_FOL_US.Play_FS_US_Crawl_Rock'))
    CrawlFootStepSounds.Add((MaterialType=EMT_Clay,Sound=AkEvent'WW_FOL_US.Play_FS_US_Crawl_Dirt'))

    SprintFootStepSounds.Add((MaterialType=EMT_Default,Sound=AkEvent'WW_FOL_US.Play_FS_US_Sprint_Dirt'))
    SprintFootStepSounds.Add((MaterialType=EMT_Rock,Sound=AkEvent'WW_FOL_US.Play_FS_US_Sprint_Gravel'))
    SprintFootStepSounds.Add((MaterialType=EMT_Dirt,Sound=AkEvent'WW_FOL_US.Play_FS_US_Sprint_Dirt'))
    SprintFootStepSounds.Add((MaterialType=EMT_Metal,Sound=AkEvent'WW_FOL_US.Play_FS_US_Sprint_Metal'))
    SprintFootStepSounds.Add((MaterialType=EMT_Wood,Sound=AkEvent'WW_FOL_US.Play_FS_US_Sprint_Wood'))
    SprintFootStepSounds.Add((MaterialType=EMT_Asphalt,Sound=AkEvent'WW_FOL_US.Play_FS_US_Sprint_Rock'))
    SprintFootStepSounds.Add((MaterialType=EMT_RedBrick,Sound=AkEvent'WW_FOL_US.Play_FS_US_Sprint_Rock'))
    SprintFootStepSounds.Add((MaterialType=EMT_WhiteBrick,Sound=AkEvent'WW_FOL_US.Play_FS_US_Sprint_Rock'))
    SprintFootStepSounds.Add((MaterialType=EMT_Plant,Sound=AkEvent'WW_FOL_US.Play_FS_US_Sprint_Grass'))
    SprintFootStepSounds.Add((MaterialType=EMT_HollowMetal,Sound=AkEvent'WW_FOL_US.Play_FS_US_Sprint_Metal'))
    SprintFootStepSounds.Add((MaterialType=EMT_HollowWood,Sound=AkEvent'WW_FOL_US.Play_FS_US_Sprint_Wood'))
    SprintFootStepSounds.Add((MaterialType=EMT_Mud,Sound=AkEvent'WW_FOL_US.Play_FS_US_Sprint_Mud'))
    SprintFootStepSounds.Add((MaterialType=EMT_Dirt,Sound=AkEvent'WW_FOL_US.Play_FS_US_Sprint_Dirt'))
    SprintFootStepSounds.Add((MaterialType=EMT_Water,Sound=AkEvent'WW_FOL_US.Play_FS_US_Sprint_Water'))
    SprintFootStepSounds.Add((MaterialType=EMT_ShallowWater,Sound=AkEvent'WW_FOL_US.Play_FS_US_Sprint_Mud'))
    SprintFootStepSounds.Add((MaterialType=EMT_Gravel,Sound=AkEvent'WW_FOL_US.Play_FS_US_Sprint_Gravel'))
    SprintFootStepSounds.Add((MaterialType=EMT_Plaster,Sound=AkEvent'WW_FOL_US.Play_FS_US_Sprint_Rock'))
    SprintFootStepSounds.Add((MaterialType=EMT_Concrete,Sound=AkEvent'WW_FOL_US.Play_FS_US_Sprint_Rock'))
    SprintFootStepSounds.Add((MaterialType=EMT_Poop,Sound=AkEvent'WW_FOL_US.Play_FS_US_Sprint_Mud'))
    SprintFootStepSounds.Add((MaterialType=EMT_Plastic,Sound=AkEvent'WW_FOL_US.Play_FS_US_Sprint_Rock'))
    SprintFootStepSounds.Add((MaterialType=EMT_Clay,Sound=AkEvent'WW_FOL_US.Play_FS_US_Sprint_Dirt'))

    WalkFootStepSounds.Add((MaterialType=EMT_Default,Sound=AkEvent'WW_FOL_US.Play_FS_US_Walk_Dirt'))
    WalkFootStepSounds.Add((MaterialType=EMT_Rock,Sound=AkEvent'WW_FOL_US.Play_FS_US_Walk_Gravel'))
    WalkFootStepSounds.Add((MaterialType=EMT_Dirt,Sound=AkEvent'WW_FOL_US.Play_FS_US_Walk_Dirt'))
    WalkFootStepSounds.Add((MaterialType=EMT_Metal,Sound=AkEvent'WW_FOL_US.Play_FS_US_Walk_Metal'))
    WalkFootStepSounds.Add((MaterialType=EMT_Wood,Sound=AkEvent'WW_FOL_US.Play_FS_US_Walk_Wood'))
    WalkFootStepSounds.Add((MaterialType=EMT_Asphalt,Sound=AkEvent'WW_FOL_US.Play_FS_US_Walk_Rock'))
    WalkFootStepSounds.Add((MaterialType=EMT_RedBrick,Sound=AkEvent'WW_FOL_US.Play_FS_US_Walk_Rock'))
    WalkFootStepSounds.Add((MaterialType=EMT_WhiteBrick,Sound=AkEvent'WW_FOL_US.Play_FS_US_Walk_Rock'))
    WalkFootStepSounds.Add((MaterialType=EMT_Plant,Sound=AkEvent'WW_FOL_US.Play_FS_US_Walk_Grass'))
    WalkFootStepSounds.Add((MaterialType=EMT_HollowMetal,Sound=AkEvent'WW_FOL_US.Play_FS_US_Walk_Metal'))
    WalkFootStepSounds.Add((MaterialType=EMT_HollowWood,Sound=AkEvent'WW_FOL_US.Play_FS_US_Walk_Wood'))
    WalkFootStepSounds.Add((MaterialType=EMT_Mud,Sound=AkEvent'WW_FOL_US.Play_FS_US_Walk_Mud'))
    WalkFootStepSounds.Add((MaterialType=EMT_Dirt,Sound=AkEvent'WW_FOL_US.Play_FS_US_Walk_Dirt'))
    WalkFootStepSounds.Add((MaterialType=EMT_Water,Sound=AkEvent'WW_FOL_US.Play_FS_US_Walk_Water'))
    WalkFootStepSounds.Add((MaterialType=EMT_ShallowWater,Sound=AkEvent'WW_FOL_US.Play_FS_US_Walk_Mud'))
    WalkFootStepSounds.Add((MaterialType=EMT_Gravel,Sound=AkEvent'WW_FOL_US.Play_FS_US_Walk_Gravel'))
    WalkFootStepSounds.Add((MaterialType=EMT_Plaster,Sound=AkEvent'WW_FOL_US.Play_FS_US_Walk_Rock'))
    WalkFootStepSounds.Add((MaterialType=EMT_Concrete,Sound=AkEvent'WW_FOL_US.Play_FS_US_Walk_Rock'))
    WalkFootStepSounds.Add((MaterialType=EMT_Poop,Sound=AkEvent'WW_FOL_US.Play_FS_US_Walk_Mud'))
    WalkFootStepSounds.Add((MaterialType=EMT_Plastic,Sound=AkEvent'WW_FOL_US.Play_FS_US_Walk_Rock'))
    WalkFootStepSounds.Add((MaterialType=EMT_Clay,Sound=AkEvent'WW_FOL_US.Play_FS_US_Walk_Dirt'))

    CrouchFootStepSounds.Add((MaterialType=EMT_Default,Sound=AkEvent'WW_FOL_US.Play_FS_US_Crouch_Dirt'))
    CrouchFootStepSounds.Add((MaterialType=EMT_Rock,Sound=AkEvent'WW_FOL_US.Play_FS_US_Crouch_Gravel'))
    CrouchFootStepSounds.Add((MaterialType=EMT_Dirt,Sound=AkEvent'WW_FOL_US.Play_FS_US_Crouch_Dirt'))
    CrouchFootStepSounds.Add((MaterialType=EMT_Metal,Sound=AkEvent'WW_FOL_US.Play_FS_US_Crouch_Metal'))
    CrouchFootStepSounds.Add((MaterialType=EMT_Wood,Sound=AkEvent'WW_FOL_US.Play_FS_US_Crouch_Wood'))
    CrouchFootStepSounds.Add((MaterialType=EMT_Asphalt,Sound=AkEvent'WW_FOL_US.Play_FS_US_Crouch_Rock'))
    CrouchFootStepSounds.Add((MaterialType=EMT_RedBrick,Sound=AkEvent'WW_FOL_US.Play_FS_US_Crouch_Rock'))
    CrouchFootStepSounds.Add((MaterialType=EMT_WhiteBrick,Sound=AkEvent'WW_FOL_US.Play_FS_US_Crouch_Rock'))
    CrouchFootStepSounds.Add((MaterialType=EMT_Plant,Sound=AkEvent'WW_FOL_US.Play_FS_US_Crouch_Grass'))
    CrouchFootStepSounds.Add((MaterialType=EMT_HollowMetal,Sound=AkEvent'WW_FOL_US.Play_FS_US_Crouch_Metal'))
    CrouchFootStepSounds.Add((MaterialType=EMT_HollowWood,Sound=AkEvent'WW_FOL_US.Play_FS_US_Crouch_Wood'))
    CrouchFootStepSounds.Add((MaterialType=EMT_Mud,Sound=AkEvent'WW_FOL_US.Play_FS_US_Crouch_Mud'))
    CrouchFootStepSounds.Add((MaterialType=EMT_Dirt,Sound=AkEvent'WW_FOL_US.Play_FS_US_Crouch_Dirt'))
    CrouchFootStepSounds.Add((MaterialType=EMT_Water,Sound=AkEvent'WW_FOL_US.Play_FS_US_Walk_Water'))
    CrouchFootStepSounds.Add((MaterialType=EMT_ShallowWater,Sound=AkEvent'WW_FOL_US.Play_FS_US_Crouch_Mud'))
    CrouchFootStepSounds.Add((MaterialType=EMT_Gravel,Sound=AkEvent'WW_FOL_US.Play_FS_US_Crouch_Gravel'))
    CrouchFootStepSounds.Add((MaterialType=EMT_Plaster,Sound=AkEvent'WW_FOL_US.Play_FS_US_Crouch_Rock'))
    CrouchFootStepSounds.Add((MaterialType=EMT_Concrete,Sound=AkEvent'WW_FOL_US.Play_FS_US_Crouch_Rock'))
    CrouchFootStepSounds.Add((MaterialType=EMT_Poop,Sound=AkEvent'WW_FOL_US.Play_FS_US_Crouch_Mud'))
    CrouchFootStepSounds.Add((MaterialType=EMT_Plastic,Sound=AkEvent'WW_FOL_US.Play_FS_US_Crouch_Rock'))
    CrouchFootStepSounds.Add((MaterialType=EMT_Clay,Sound=AkEvent'WW_FOL_US.Play_FS_US_Crouch_Dirt'))

    CrouchWalkFootStepSounds.Add((MaterialType=EMT_Default,Sound=AkEvent'WW_FOL_US.Play_FS_US_Crouch_Dirt'))
    CrouchWalkFootStepSounds.Add((MaterialType=EMT_Rock,Sound=AkEvent'WW_FOL_US.Play_FS_US_Crouch_Gravel'))
    CrouchWalkFootStepSounds.Add((MaterialType=EMT_Dirt,Sound=AkEvent'WW_FOL_US.Play_FS_US_Crouch_Dirt'))
    CrouchWalkFootStepSounds.Add((MaterialType=EMT_Metal,Sound=AkEvent'WW_FOL_US.Play_FS_US_Crouch_Metal'))
    CrouchWalkFootStepSounds.Add((MaterialType=EMT_Wood,Sound=AkEvent'WW_FOL_US.Play_FS_US_Crouch_Wood'))
    CrouchWalkFootStepSounds.Add((MaterialType=EMT_Asphalt,Sound=AkEvent'WW_FOL_US.Play_FS_US_Crouch_Rock'))
    CrouchWalkFootStepSounds.Add((MaterialType=EMT_RedBrick,Sound=AkEvent'WW_FOL_US.Play_FS_US_Crouch_Rock'))
    CrouchWalkFootStepSounds.Add((MaterialType=EMT_WhiteBrick,Sound=AkEvent'WW_FOL_US.Play_FS_US_Crouch_Rock'))
    CrouchWalkFootStepSounds.Add((MaterialType=EMT_Plant,Sound=AkEvent'WW_FOL_US.Play_FS_US_Crouch_Grass'))
    CrouchWalkFootStepSounds.Add((MaterialType=EMT_HollowMetal,Sound=AkEvent'WW_FOL_US.Play_FS_US_Crouch_Metal'))
    CrouchWalkFootStepSounds.Add((MaterialType=EMT_HollowWood,Sound=AkEvent'WW_FOL_US.Play_FS_US_Crouch_Wood'))
    CrouchWalkFootStepSounds.Add((MaterialType=EMT_Mud,Sound=AkEvent'WW_FOL_US.Play_FS_US_Crouch_Mud'))
    CrouchWalkFootStepSounds.Add((MaterialType=EMT_Dirt,Sound=AkEvent'WW_FOL_US.Play_FS_US_Crouch_Dirt'))
    CrouchWalkFootStepSounds.Add((MaterialType=EMT_Water,Sound=AkEvent'WW_FOL_US.Play_FS_US_Walk_Water'))
    CrouchWalkFootStepSounds.Add((MaterialType=EMT_ShallowWater,Sound=AkEvent'WW_FOL_US.Play_FS_US_Crouch_Mud'))
    CrouchWalkFootStepSounds.Add((MaterialType=EMT_Gravel,Sound=AkEvent'WW_FOL_US.Play_FS_US_Crouch_Gravel'))
    CrouchWalkFootStepSounds.Add((MaterialType=EMT_Plaster,Sound=AkEvent'WW_FOL_US.Play_FS_US_Crouch_Rock'))
    CrouchWalkFootStepSounds.Add((MaterialType=EMT_Concrete,Sound=AkEvent'WW_FOL_US.Play_FS_US_Crouch_Rock'))
    CrouchWalkFootStepSounds.Add((MaterialType=EMT_Poop,Sound=AkEvent'WW_FOL_US.Play_FS_US_Crouch_Mud'))
    CrouchWalkFootStepSounds.Add((MaterialType=EMT_Plastic,Sound=AkEvent'WW_FOL_US.Play_FS_US_Crouch_Rock'))
    CrouchWalkFootStepSounds.Add((MaterialType=EMT_Clay,Sound=AkEvent'WW_FOL_US.Play_FS_US_Crouch_Dirt'))
}
