class PMVehicle_Renault4CV_Content extends PMVehicle_Renault4CV
    placeable;

DefaultProperties
{
	Begin Object Name=ROSVehicleMesh
		SkeletalMesh=SkeletalMesh'RM_VH_Renault4CV.Mesh.SK_Renault4CV'
		LightingChannels=(Dynamic=TRUE,Unnamed_1=TRUE,bInitialized=TRUE)
		AnimTreeTemplate=AnimTree'RM_VH_Renault4CV.Anim.AT_Renault4CV'
		PhysicsAsset=PhysicsAsset'RM_VH_Renault4CV.Phys.PHYS_Renault4CV'
		// AnimSets.Add(AnimSet'WF_Vehicles_Jeep50Cal.Anims.Jeep_Anims_Master')
	End Object

	// HUD
	HUDBodyTexture=None
	HUDTurretTexture=None
	DriverOverlayTexture=None

	HUDMainCannonTexture=None
	HUDGearBoxTexture=None
	HUDFrontArmorTexture=None
	HUDBackArmorTexture=None
	HUDLeftArmorTexture=None
	HUDRightArmorTexture=None

	RoleSelectionImage=None

    SeatProxyAnimSet=AnimSet'VH_VN_ARVN_M113_APC.Anim.CHR_M113_Anim_Master'

    SeatProxies.Empty

    SeatProxies(0)={(
		TunicMeshType=SkeletalMesh'CHR_VN_US_Army.Mesh.US_Tunic_Pilot_Mesh',
		HeadGearMeshType=SkeletalMesh'CHR_VN_US_Headgear.PilotMesh.US_Headgear_Pilot_Base_Up',
		HeadAndArmsMeshType=SkeletalMesh'CHR_VN_US_Heads.Mesh.US_Head2_Mesh',
		HeadphonesMeshType=none,
		HeadAndArmsMICTemplate=MaterialInstanceConstant'CHR_VN_US_Heads.Materials.M_US_Head_02_Pilot_INST',
		BodyMICTemplate=MaterialInstanceConstant'CHR_VN_US_Army.Materials.M_US_Tunic_Pilot_A_INST',
		HeadgearSocket=helmet,
		SeatIndex=0,
		PositionIndex=0,
		bExposedToRain=true)}
}
