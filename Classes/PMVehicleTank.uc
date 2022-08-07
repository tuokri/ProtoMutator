// TODO: Add custom SoundCue support.
// TODO: Add custom material support.
// ROVehicleTank with some useful code taken from ROVehicleHelicopter.
class PMVehicleTank extends ROVehicleTank;

// Procedural track animation.
// Bone information of the spline elements that the track mesh chain should move along.
// TODO: Use sockets?
struct TrackGuideBoneInfo
{
    var name BoneName;

    // True if this track bone moves in relation to the track parent.
    // E.g. track bones that move with the tank's suspension.
    var bool bStaticBone;

    // True if this bone's spline actor should calculate the spline
    // tangent dynamically. Otherwise use bone rotation and default
    // tangent length. Should be true for bones that are not manually
    // rotated to point at the next spline bone.
    var bool bCalculateTangent;

    StructDefaultProperties
    {
        bStaticBone=False
        bCalculateTangent=True
    }
};

// Class of the track spline actor to spawn.
var(TrackAnim) class<PMTrackSplineActor> TrackSplineActorClass;

// Display track spline debug information.
var(TrackAnim) bool bDebugTrackSpline;

// Left side track spline guide bone names.
var(TrackAnim) array<TrackGuideBoneInfo> TrackGuideBoneInfosLeft;
// Right side track spline guide bone names.
var(TrackAnim) array<TrackGuideBoneInfo> TrackGuideBoneInfosRight;

// Left side generated track spline actors.
var(TrackAnim) array<PMTrackSplineActor> TrackSplineActorsLeft;
// Right side generated track spline actors.
var(TrackAnim) array<PMTrackSplineActor> TrackSplineActorsRight;

// Skeletal mesh to use for individual track pieces.
var(TrackAnim) SkeletalMesh TrackPieceMesh;

var(TrackAnim) class<PMSplineMover> SplineTrackPieceClass;

// Names of left side track bones to spawn track pieces at.
var(TrackAnim) array<name> TrackPieceBoneNamesLeft;
// Names of right side track bones to spawn track pieces at.
var(TrackAnim) array<name> TrackPieceBoneNamesRight;

var(TrackAnim) array<PMSplineMover> TrackPieceSplineMoversLeft;
var(TrackAnim) array<PMSplineMover> TrackPieceSplineMoversRight;

// Width of an indiviual track piece. Used in dynamic track piece generation.
var(TrackAnim) int TrackPieceWidth;
// Offset (gap) between track pieces. Used in dynamic track piece generation.
var(TrackAnim) int TrackPieceOffset;

// // Name the of left side track master (parent) skeletal controller.
// var(TrackAnim) name TrackMasterSkelControlLeftName;
// // Name the of right side track master (parent) skeletal controller.
// var(TrackAnim) name TrackMasterSkelControlRightName;

// var SkelControlSingleBone TrackMasterSkelControlLeft;
// var SkelControlSingleBone TrackMasterSkelControlRight;

var SoundCue ExplosionSoundCustom;

var(Sounds) editconst const AudioComponent EngineSoundCustom;
var(Sounds) editconst const AudioComponent SquealSoundCustom;

// Engine start sounds.
var AudioComponent  EngineStartLeftSoundCustom;
var AudioComponent  EngineStartRightSoundCustom;
var AudioComponent  EngineStartExhaustSoundCustom;
var AudioComponent  EngineStopSoundCustom;

var SoundCue EngineIdleSoundCustom;
var SoundCue EngineIdleDamagedSoundCustom;
var SoundCue TrackTakeDamageSoundCustom;
var SoundCue TrackDamagedSoundCustom;
var SoundCue TrackDestroyedSoundCustom;

// Engine interior cabin sounds.
var AudioComponent EngineIntLeftSoundCustom;
var AudioComponent EngineIntRightSoundCustom;

// Tread sounds.
var AudioComponent  TrackLeftSoundCustom;
var AudioComponent  TrackRightSoundCustom;

// Tranmission sounds.
var AudioComponent  BrokenTransmissionSoundCustom;

// Brake sounds.
var AudioComponent  BrakeLeftSoundCustom;
var AudioComponent  BrakeRightSoundCustom;

// Gear shift sounds.
var SoundCue        ShiftUpSoundCustom;
var SoundCue        ShiftDownSoundCustom;
var SoundCue        ShiftLeverSoundCustom;

// Turret rotation components.
var AudioComponent  TurretTraverseSoundCustom;
var AudioComponent  TurretMotorTraverseSoundCustom;
var AudioComponent  TurretElevationSoundCustom;

/** AnimTree for characters riding in this vehicle. */
// TODO: useless variable as it doesn't differ from VehicleCrewProxy default AnimTree...
var Animtree PassengerAnimTree;

// NOTE: just a convenience enum to avoid magic values from legacy ROVehicle code.
// TODO: Might want to move this to some common file.
enum EDeadVehicleType
{
    EDVT_None,                              // 0
    EDVT_Explosion,                         // 1
    EDVT_AmmoExplosion,                     // 2
    EDVT_AmmoExplosionTurretBlowoff,        // 3
    EDVT_FireCrewEscape,                    // 4
    EDVT_FireCrewEscapeFailed,              // 5
};

// Combined ROVehicleTank and ROVehicleTreaded PostBeginPlay here to get rid of
// null component attachment warnings.
simulated function PostBeginPlay()
{
    local int i;
    local int NewSeatIndexHealths;
    local int LoopMax;

    Super(ROVehicle).PostBeginPlay();

    if (bDeleteMe)
    {
        return;
    }

    if (WorldInfo.NetMode != NM_DedicatedServer && Mesh != None)
    {
        // set up material instance (for overlay effects)
        LeftTreadMaterialInstance = Mesh.CreateAndSetMaterialInstanceConstant(1);
        RightTreadMaterialInstance = Mesh.CreateAndSetMaterialInstanceConstant(2);
    }

    // Attach sound cues
    if (WorldInfo.NetMode != NM_DedicatedServer)
    {
        Mesh.AttachComponentToSocket(EngineStartLeftSoundCustom, CabinL_FXSocket);
        Mesh.AttachComponentToSocket(EngineStartRightSoundCustom, CabinR_FXSocket);
        Mesh.AttachComponentToSocket(EngineStartExhaustSoundCustom, Exhaust_FXSocket);
        Mesh.AttachComponentToSocket(EngineStopSoundCustom, Exhaust_FXSocket);
        Mesh.AttachComponentToSocket(EngineIntLeftSoundCustom, CabinL_FXSocket);
        Mesh.AttachComponentToSocket(EngineIntRightSoundCustom, CabinR_FXSocket);
        Mesh.AttachComponentToSocket(EngineSoundCustom, Exhaust_FXSocket);
        Mesh.AttachComponentToSocket(TrackLeftSoundCustom, TreadL_FXSocket);
        Mesh.AttachComponentToSocket(TrackRightSoundCustom, TreadR_FXSocket);
        Mesh.AttachComponentToSocket(BrakeLeftSoundCustom, TreadL_FXSocket);
        Mesh.AttachComponentToSocket(BrakeRightSoundCustom, TreadR_FXSocket);
    }

    // Initialize vehicle hitzone healths
    for (i = 0; i < VehHitZones.length; i++)
    {
        VehHitZoneHealths[i] = 255;

        if( VehHitZones[i].VehicleHitZoneType == VHT_CrewHead || VehHitZones[i].VehicleHitZoneType == VHT_CrewBody )
        {
            CrewVehHitZoneIndexes[CrewVehHitZoneIndexes.Length] = i;
        }
    }

    // Initialize armor plate zone healths
    for (i = 0; i < MAX_ARMOR_PLATE_ZONES; i++)
    {
        ArmorPlateZoneHealthsCompressed[i] = 255;
    }

    // Cache seat indexes
    SeatIndexHullMG = GetHullMGSeatIndex();
    SeatIndexGunner = GetGunnerSeatIndex();

    if (Role == ROLE_Authority)
    {
        // GRIP BEGIN
        // Create the Tank AI. It will be initialized later, in DriverEnter.
        if( TankController == None )
        {
            TankController = Spawn(TankControllerClass, self, , Location, Rotation, , true);
        }
        // GRIP END

        if( SeatProxies.Length > 7 )
            LoopMax = 7;
        else
            LoopMax = SeatProxies.Length;

        // Initialize the replicated seat proxy health values.
        for ( i = 0; i < LoopMax; i++ )
        {
            NewSeatIndexHealths = (NewSeatIndexHealths - (NewSeatIndexHealths & (15 << (4 * i)))) | (int(SeatProxies[i].Health / 6.6666666) << (4 * i));
        }
        ReplicatedSeatProxyHealths = NewSeatIndexHealths;

        if( LoopMax < SeatProxies.Length )
        {
            LoopMax = SeatProxies.Length;
            NewSeatIndexHealths = 0;

            // Initialize the remaining replicated seat proxy health values.
            for ( i = 7; i < LoopMax; i++ )
            {
                NewSeatIndexHealths = (NewSeatIndexHealths - (NewSeatIndexHealths & (15 << (4 * (i - 7))))) | (int(SeatProxies[i].Health / 6.6666666) << (4 * (i - 7)));
            }
            ReplicatedSeatProxyHealths2 = NewSeatIndexHealths;
        }
    }

    SpawnExternallyVisibleSeatProxies();

    if (WorldInfo.NetMode != NM_DedicatedServer && Mesh != None)
    {
        InitTrackSplines();
        InitSplineTrackPieces();
    }
}

simulated event Tick(float DeltaTime)
{
    local int i;
    // local TrackGuideBoneInfo GuideInfo;

    super.Tick(DeltaTime);

    if ((WorldInfo.NetMode != NM_DedicatedServer) && (LastRenderTime > WorldInfo.TimeSeconds - 0.1))
    {
        for (i = 0; i < TrackSplineActorsLeft.Length; ++i)
        {
            // TODO: Update tangent for spline actors that move up/down with suspension?

            // GuideInfo = TrackGuideBoneInfosLeft[i];
            // TrackSpline.SetLocation(Mesh.GetBoneLocation(GuideInfo.BoneName);
            // TrackSpline.SetRotation(QuatToRotator(Mesh.GetBoneQuaternion(GuideInfo.BoneName));

            // TrackSplineActorsLeft[i].UpdateConnectedSplineComponents(True);
            TrackSplineActorsLeft[i].UpdateSplineComponents();
        }

        for (i = 0; i < TrackSplineActorsRight.Length; ++i)
        {
            TrackSplineActorsRight[i].UpdateSplineComponents();
        }

        // for (i = 0; i < TrackPieceSplineMoversLeft.Length; ++i)
        // {

        // }

        // for (i = 0; i < TrackPieceSplineMoversRight.Length; ++i)
        // {

        // }
    }
}

simulated function InitTrackSplines()
{
    local int i;
    local int j;
    local int k;
    local PMTrackSplineActor TrackSpline;
    local vector VecToNext;
    local vector BoneWorldLoc;
    // local vector BoneLocalLoc;
    local rotator BoneWorldRot;
    // local rotator BoneLocalRot;
    local TrackGuideBoneInfo GuideInfo;

    // if (TrackMasterSkelControlLeftName != '')
    // {
    //     TrackMasterSkelControlLeft = SkelControlSingleBone(Mesh.FindSkelControl(TrackMasterSkelControlLeftName));
    // }

    // if (TrackMasterSkelControlRightName != '')
    // {
    //     TrackMasterSkelControlRight = SkelControlSingleBone(Mesh.FindSkelControl(TrackMasterSkelControlRightName));
    // }

    for (i = 0; i < TrackGuideBoneInfosLeft.Length; ++i)
    {
        `pmlog("*** *** ***");
        `pmlog("  i = " $ i);
        GuideInfo = TrackGuideBoneInfosLeft[i];
        `pmlog("  BoneName  = " $ GuideInfo.BoneName);
        `pmlog("  BoneIndex = " $ Mesh.MatchRefBone(GuideInfo.BoneName));
        BoneWorldRot = QuatToRotator(Mesh.GetBoneQuaternion(GuideInfo.BoneName, 0));
        // BoneLocalRot = QuatToRotator(Mesh.GetBoneQuaternion(GuideInfo.BoneName, 1));
        BoneWorldLoc = Mesh.GetBoneLocation(GuideInfo.BoneName, 0);
        // BoneLocalLoc = Mesh.GetBoneLocation(GuideInfo.BoneName, 1);
        `pmlog("  BoneWorldRot = " $ BoneWorldRot);
        // `pmlog("  BoneLocalRot = " $ BoneLocalRot);
        `pmlog("  BoneWorldLoc = " $ BoneWorldLoc);
        // `pmlog("  BoneLocalLoc = " $ BoneLocalLoc);

        TrackSpline = Spawn(TrackSplineActorClass, self,, BoneWorldLoc, BoneWorldRot,, True);
        `pmlog("  spawned " $ TrackSpline);

        if (TrackSpline == None)
        {
            `pmlog("!!! ERROR !!! FAILED TO SPAWN " $ TrackSplineActorClass $ "(" $ i $ ")");
            continue;
        }

        TrackSpline.SetBase(None);
        TrackSpline.SetHardAttach(true);
        // TrackSpline.SetHardAttach(GuideInfo.bStaticBone);  // TODO: Should we use hard attach?
        TrackSpline.SetPhysics(PHYS_Interpolating);
        TrackSpline.SetCollision(False, False);
        TrackSpline.bCollideWorld = false;
        TrackSpline.SetLocation(BoneWorldLoc);
        // TODO: see if dynamic tangent calucation is better than manual bone rotation in all cases.
        //       If it is (it probaby is), we can just do it by default for all spline actors.
        // TrackSpline.SetRotation(BoneWorldRot);
        TrackSpline.SetRotation(rot(0, 0, 0));

        if (i > 0)
        {
            TrackSplineActorsLeft[i - 1].AddConnectionTo(TrackSpline);
        }

        TrackSplineActorsLeft.AddItem(TrackSpline);
    }

    // Connect last to first and complete the loop.
    TrackSplineActorsLeft[TrackSplineActorsLeft.Length - 1].AddConnectionTo(TrackSplineActorsLeft[0]);

    for(i = 0; i < TrackSplineActorsLeft.Length; ++i)
    {
        GuideInfo = TrackGuideBoneInfosLeft[i];

        // TODO: SetHidden doesn't work. Use "SHOW SPLINES" console command to see the spline.
        if (bDebugTrackSpline)
        {
            TrackSplineActorsLeft[i].SetHidden(False);
            for (j = 0; j < TrackSplineActorsLeft[i].Connections.Length; ++j)
            {
                TrackSplineActorsLeft[i].Connections[j].SplineComponent.SetHidden(False);
                TrackSplineActorsLeft[i].Connections[j].SplineComponent.SplineArrowSize = 5;
            }
        }

        if (GuideInfo.bCalculateTangent)
        {
            // Index of next spline.
            k = (i + 1) % TrackSplineActorsLeft.Length;

            VecToNext = TrackSplineActorsLeft[k].Location - TrackSplineActorsLeft[i].Location;

            // TODO: Just set the tangent X component. The rest should be handled when rotation is set??
            // TODO: experiment with different length multipliers.
            TrackSplineActorsLeft[i].SplineActorTangent.X = VSize(VecToNext) * 0.7;

            `pmlog("VSize(VecToNext)   = " $ VSize(VecToNext));
            `pmlog("VSize2D(VecToNext) = " $ VSize2D(VecToNext));

            TrackSplineActorsLeft[i].SetRotation(
                rotator(VecToNext /*<< QuatToRotator(Mesh.GetBoneQuaternion(GuideInfo.BoneName, 1))*/));
        }

        TrackSplineActorsLeft[i].SetBase(self,, Mesh, GuideInfo.BoneName);

        // TrackSplineActorsLeft[i].UpdateConnectedSplineComponents(True);
        TrackSplineActorsLeft[i].UpdateSplineComponents();

        `log("  [" $ i $ "].SplineActorTangent = " $ TrackSplineActorsLeft[i].SplineActorTangent);
    }

    // for (i = 0; i < TrackGuideBoneInfosRight.Length; ++i)
    // {

    // }

    `pmlog("--- --- ---");
}

simulated function InitSplineTrackPieces()
{
    local int i;
    local int NumPieces;
    local int TotalNumPieces;
    local float TotalSplineLength;
    local float SplineLength;
    local float Leftover;
    local PMSplineMover TrackPiece;
    local PMTrackSplineActor CurrentSpline;
    // local vector BoneWorldLoc;
    // local rotator BoneWorldRot;
    local vector SpawnLoc;
    local rotator SpawnRot;

    for (i = 0; i < TrackSplineActorsLeft.Length; ++i)
    {
        TotalSplineLength += TrackSplineActorsLeft[i].Connections[0].SplineComponent.GetSplineLength();
    }

    TotalNumPieces = TotalSplineLength / (TrackPieceWidth + TrackPieceOffset);
    Leftover = TotalSplineLength - (TotalNumPieces * TrackPieceWidth + TrackPieceOffset);

    `pmlog("TotalSplineLength  = " $ TotalSplineLength);
    `pmlog("TotalNumPieces     = " $ TotalNumPieces);
    `pmlog("Leftover           = " $ Leftover);
    Leftover /= TotalNumPieces;
    `pmlog("Leftover (final)   = " $ Leftover);

    for (i = 0; i < TrackSplineActorsLeft.Length; ++i)
    {
        `pmlog("*** *** ***");
        `pmlog(" Generating track pieces for TrackSplineActorsLeft[" $ i $ "]");

        CurrentSpline = TrackSplineActorsLeft[i];

        SplineLength = CurrentSpline.Connections[0].SplineComponent.GetSplineLength();

        `pmlog("  SplineLength = " $ SplineLength);

        NumPieces = SplineLength / (TrackPieceWidth + TrackPieceOffset);

        `pmlog("  NumPieces = " $ NumPieces);

        // BoneWorldRot = QuatToRotator(Mesh.GetBoneQuaternion(TrackPieceBoneNamesLeft[i]));
        // BoneWorldLoc = Mesh.GetBoneLocation(TrackPieceBoneNamesLeft[i]);

        // TrackPiece = Spawn(SplineTrackPieceClass, self,, BoneWorldLoc, BoneWorldRot,, True);
        TrackPiece = Spawn(SplineTrackPieceClass, self,, SpawnLoc, SpawnRot,, True);

        if (TrackPiece == None)
        {
            `pmlog("!!! ERROR !!! FAILED TO SPAWN " $ SplineTrackPieceClass $ " (" $ i $ ")");
            continue;
        }

        TrackPiece.TargetSpline = CurrentSpline;

        TrackPiece.SkeletalMeshComponent.SetSkeletalMesh(TrackPieceMesh);
        TrackPiece.SkeletalMeshComponent.SetShadowParent(Mesh);
        TrackPiece.SkeletalMeshComponent.SetLightingChannels(ExteriorLightingChannels);
        TrackPiece.SkeletalMeshComponent.SetLightEnvironment(LightEnvironment);

        TrackPiece.SetBase(None);
        TrackPiece.SetHardAttach(true);
        TrackPiece.SetPhysics(PHYS_Interpolating);
        TrackPiece.SetCollision(False, False);
        TrackPiece.bCollideWorld = false;
        TrackPiece.SetLocation(SpawnLoc);
        TrackPiece.SetRotation(SpawnRot);

        // TrackPiece.SetBase(self,, Mesh, TrackPieceBoneNamesLeft[i]);
        TrackPiece.SetBase(self);

        // TODO: dynamic mover generation:
        // Use track piece mesh width and generate X number of movers
        // on track spline with Y offset between pieces?

        // TrackPiece.CurrentSpline = None // get closest spline.
        // figure out distance on spline for mover spawn position
        // TrackPiece.SetLocation(); // get location along spline at distance
        // TrackPiece.SetRotation(); // set rotation to tangent along spline

        TrackPieceSplineMoversLeft.AddItem(TrackPiece);

        `pmlog("  TrackPieces[" $ i $ "].Location = " $ TrackPiece.Location);
        `pmlog("  TrackPieces[" $ i $ "].Rotation = " $ TrackPiece.Rotation);
        `pmlog("--- --- ---");
    }
}

simulated function AttachBrokenTransmissionSound()
{
    Mesh.AttachComponentToSocket(BrokenTransmissionSoundCustom, Exhaust_FXSocket);
}

// TODO: We'll want these in the future.
function SetPendingDestroyIfEmpty(float WaitToDestroyTime);
function DestroyIfEmpty();

// Get engine output level for SoundCue parameters.
// Adapted from ROVehicle native C++ version.
// TODO: when adding SoundCue back-port code here, check this again!
//       There are 2 versions of this in the native vehicle code.
simulated function float GetEngineOutput()
{
    // Scaled by gear change RPM.
    // 0.0 = 0 RPM.
    // 1.0 = ChangeUp RPM * 1.1.
    // Set max clamp to 1.5 because the engine can actually go above
    // ChangeUpPoint RPM in certain situations.
    return FClamp(
        ROVehicleSimTreaded(SimObj).EngineRPM / (ROVehicleSimTreaded(SimObj).ChangeUpPoint * 1.1f),
        0.0, 1.5);
}

// NOTE: From ROVehicleHelicopter.
simulated function SitDriver(ROPawn ROP, int SeatIndex)
{
    local ROPlayerController ROPC;

    `pmlog("ROP=" $ ROP $ " SeatIndex= " $ SeatIndex);

    // NOTE: Ignore ROVehicleTank::SitDriver.
    super(ROVehicleTreaded).SitDriver(ROP, SeatIndex);

    ROPC = ROPlayerController(FindVehicleLocalPlayerController(ROP, SeatIndex));

    if ((ROPC != none) && ((WorldInfo.NetMode == NM_Standalone) || IsLocalPlayerInThisVehicle()))
    {
        // Force the driver's view rotation to default to forward instead of some arbitrary angle
        ROPC.SetRotation(rot(0,0,0));
        // TODO: Added this because the above statement is not enough.
        //       But WHY is it not enough?
        ROPC.ClientSetRotation(rot(0,0,0));

        // Set Interior engine sounds. Exterior sounds are called by ROPawn.StopDriving
        // TODO: HELOSTUFF, CHECK THIS.
        // SetInteriorEngineSound(true);
    }

    if (ROP != none)
    {
        ROP.Mesh.SetAnimTreeTemplate(PassengerAnimTree);
        ROP.HideGear(true);
        if (ROP.CurrentWeaponAttachment != none)
        {
            ROP.PutAwayWeaponAttachment();
        }

        // Set the proxy health to be whatever our pawn had on entry
        if (Role == ROLE_Authority)
        {
            UpdateSeatProxyHealth(GetSeatProxyIndexForSeatIndex(SeatIndex), ROP.Health, false);
        }
    }

    if (WorldInfo.NetMode != NM_DedicatedServer)
    {
        // Display the vehicle interior if a local player is getting into it
        // Check for IsLocalPlayerInThisVehicle shouldn't normally be required, but it prevents a nasty bug when new players
        // connect and briefly think that they control every pawn, leading to invisible heads for all vehicle passengers - Ch!cken
        if (ROPC != None && LocalPlayer(ROPC.Player) != none && (WorldInfo.NetMode == NM_Standalone || IsLocalPlayerInThisVehicle()))
        {
            // If our local PlayerController is getting into this seat set up the
            // hands and head meshes so we see what we need to see (like our
            // third person hands, and don't see what we don't (like our own head)
            if (ROP != None)
            {
                if( ROP.ThirdPersonHeadphonesMeshComponent != none )
                {
                    ROP.ThirdPersonHeadphonesMeshComponent.SetOwnerNoSee(true);
                }

                if( ROP.ThirdPersonHeadgearMeshComponent != none )
                {
                    ROP.ThirdPersonHeadgearMeshComponent.SetHidden(true);
                }

                if( ROP.FaceItemMeshComponent != none )
                {
                    ROP.FaceItemMeshComponent.SetHidden(true);
                }

                if( ROP.FacialHairMeshComponent != none )
                {
                    ROP.FacialHairMeshComponent.SetHidden(true);
                }

                ROP.ThirdPersonHeadAndArmsMeshComponent.SetSkeletalMesh(ROP.ArmsOnlyMesh);
                ROP.ArmsMesh.SetHidden(true);
            }

            SpawnOrReplaceSeatProxyCustom(SeatIndex, ROP, true);

            // Since we are entering a tank we want to spawn all the proxies.
            SpawnSeatProxiesCustom(SeatIndex, ROP);
        }
        else if (ROAIController(ROP.Controller) != none && IsLocalPlayerInThisVehicle())
        {
            SpawnOrReplaceSeatProxyCustom(SeatIndex, ROP, true);
        }
        else
        {
            SpawnOrReplaceSeatProxyCustom(SeatIndex, ROP, false);
        }

        if ((ROPC != none && ROPC.IsLocalPlayerController() && ROPC.IsFirstPersonCamera()) || IsLocalPlayerInThisVehicle())
        {
            SetVehicleDepthToForeground();
        }
        else
        {
            SetVehicleDepthToWorld();
        }
    }

    if (ROP != none)
    {
       ROP.SetRelativeRotation(Seats[SeatIndex].SeatRotation);
       // IK update here to force client replication on vehicle entry, otherwise IK doesn't update until position change
       ROP.UpdateVehicleIK(self, SeatIndex, SeatPositionIndex(SeatIndex,, true));
    }
}

simulated function PlayerController FindVehicleLocalPlayerController(ROPawn ROP, int SeatIndex, optional out Pawn LocalPawn)
{
    local ROPlayerController ROPC;

    // Here we need to find the local PlayerController for either the SeatPawn
    // or the Pawn we're putting in the seat. Have to search a couple different
    // ways, since this code has to run on the server and the client, and the
    // Pawns get possessed in a different order on the client and the server.
    if ((Seats[SeatIndex].SeatPawn != none) && (Seats[SeatIndex].SeatPawn.Driver != none))
    {
        ROPC = ROPlayerController(Seats[SeatIndex].SeatPawn.Driver.Controller);
    }

    // Couldn't find the Controller for the driver, check the SeatPawn
    if ((ROPC == none) && (Seats[SeatIndex].SeatPawn != none))
    {
        ROPC = ROPlayerController(Seats[SeatIndex].SeatPawn.Controller);
    }

    // Look at the controller of the incoming pawn's DrivenVehicle,
    // and see if it matches the local PlayerController.
    if (ROPC == none)
    {
        if (ROP != None)
        {
            if ((ROP.DrivenVehicle.Controller != none) && (ROP.DrivenVehicle.Controller == GetALocalPlayerController()))
            {
                ROPC = ROPlayerController(ROP.DrivenVehicle.Controller);
            }
        }
    }

    // Another check, if we are looking for the controller for the vehicle itself
    // just check and see if the controller for the local PlayerController is set
    // to this vehicle.
    if ((ROPC == none) && (SeatIndex == 0))
    {
        if ((GetALocalPlayerController() != none) && (GetALocalPlayerController().Pawn == self))
        {
            ROPC = ROPlayerController(GetALocalPlayerController());
        }
    }

    // Final check, if we are looking for the controller for a particular seat
    // just check and see if the controller for the local PlayerController is set
    // to that seat's SeatPawn.
    if (ROPC == none)
    {
        LocalPawn = GetALocalPlayerController().Pawn;

        `pmlog("LocalPawn = " $ LocalPawn $ " GetALocalPlayerController() = " $ GetALocalPlayerController()
            $ " LocalPawn.Controller = " $ LocalPawn.Controller);

        if ((GetALocalPlayerController() != none) && (LocalPawn == Seats[SeatIndex].SeatPawn))
        {
            ROPC = ROPlayerController(GetALocalPlayerController());
        }
    }

    return ROPC;
}

// Just a wrapper to call our custom version.
// NOTE: SeatIndex here actually refers to SeatProxyIndex.
//       It is assumed they are both equal for every seat position.
//       This is not true for RO2 tank code so be careful when porting stuff.
simulated function SpawnOrReplaceSeatProxy(int SeatIndex, ROPawn ROP, optional bool bInternalVisibility)
{
    SpawnOrReplaceSeatProxyCustom(SeatIndex, ROP, bInternalVisibility, false, false, false);
}

// TODO: Try to simplify this logic.
// NOTE: From ROVehicleHelicopter with some heavy modifications.
// NOTE: Only use bForceSetVisible to make seat proxies for non-local pawns visible!
/**
 * Spawn or update a single proxy (or multiple, depending on the boolean flags)
 * for playing death animations on. Match the outfit to that of the Pawn in the same seat.
 *
 * @param SeatIndex                 The pawn's SeatIndex. NOTE: This is actually SeatProxyIndex.
 * @param ROP                       The pawn in this SeatIndex.
 * @param bInternalVisibility       Set visibility to interior for the seat proxy or proxies handled.
 * @param bForceCreateProxy         If set, always loop through all SeatProxies (unless overridden by bOnlySeatIndex).
 * @param bForceSetVisible          If set, force seat proxy visible in this SeatIndex.
 * @param bOnlySeatIndex            If set, only handle this seat index.
 */
simulated function SpawnOrReplaceSeatProxyCustom(
    int SeatIndex,
    ROPawn ROP,
    optional bool bInternalVisibility = false,
    optional bool bForceCreateProxy = false,
    optional bool bForceSetVisible = false,
    optional bool bOnlySeatIndex = false)
{
    local int i;
    local VehicleCrewProxy CurrentProxyActor;
    local ROMapInfo ROMI;
    local bool bSetMeshRequired;
    local bool bPlayerEnterableSeat;
    local bool bIsThisPawnsSeat;

    // Don't spawn the seat proxy actors on the dedicated server (at least for now).
    if (WorldInfo == none || WorldInfo.NetMode == NM_DedicatedServer)
    {
        return;
    }

    `pmlog("SeatIndex=" $ SeatIndex $ " ROP=" $ ROP $ " bInternalVisibility="
        $ bInternalVisibility $ " bForceCreateProxy=" $ bForceCreateProxy $ " bForceSetVisible="
        $ bForceSetVisible $ " bOnlySeatIndex=" $ bOnlySeatIndex);

    // `pmlog(GetScriptTrace());

    // Don't create proxy if vehicle is dead to prevent leave bodies in the air after round has finished.
    if (IsPendingKill() || bDeadVehicle)
    {
        return;
    }

    ROMI = ROMapInfo(WorldInfo.GetMapInfo());

    for (i = 0; i < SeatProxies.Length; i++)
    {
        bPlayerEnterableSeat = !Seats[SeatProxies[i].SeatIndex].bNonEnterable;
        bIsThisPawnsSeat = (SeatIndex == i);

        // bOnlySeatIndex is higher priority than other checks.
        if (bOnlySeatIndex && !bIsThisPawnsSeat)
        {
            continue;
        }

        // Only create a proxy for the seat the player has entered, or any seats where players can never enter.
        // OR if bForceCreateProxy is set.
        // OR if bForceSetVisible is set and it's this pawn's seat.
        if (bForceCreateProxy || (bIsThisPawnsSeat && (ROP != none)) || !bPlayerEnterableSeat || (bForceSetVisible && bIsThisPawnsSeat))
        {
            bSetMeshRequired = false;

            // Dismemberment causes serious problems in native code if we try to reuse the existing mesh, so destroy it and create a new one instead.
            if (SeatProxies[i].ProxyMeshActor != none && SeatProxies[i].ProxyMeshActor.bIsDismembered)
            {
                SeatProxies[i].ProxyMeshActor.Destroy();
                SeatProxies[i].ProxyMeshActor = none;
            }

            if (SeatProxies[i].ProxyMeshActor == none)
            {
                SeatProxies[i].ProxyMeshActor = Spawn(class'PMVehicleCrewProxy', self);
                SeatProxies[i].ProxyMeshActor.MyVehicle = self;
                SeatProxies[i].ProxyMeshActor.SeatProxyIndex = i;

                CurrentProxyActor = SeatProxies[i].ProxyMeshActor;

                SeatProxies[i].TunicMeshType.Characterization = class'ROPawn'.default.PlayerHIKCharacterization;

                CurrentProxyActor.Mesh.SetShadowParent(Mesh);
                CurrentProxyActor.SetLightingChannels(InteriorLightingChannels);
                CurrentProxyActor.SetLightEnvironment(InteriorLightEnvironment);

                CurrentProxyActor.SetCollision(false, false);
                CurrentProxyActor.bCollideWorld = false;
                CurrentProxyActor.SetBase(none);
                CurrentProxyActor.SetHardAttach(true);
                CurrentProxyActor.SetLocation(Location);
                CurrentProxyActor.SetPhysics(PHYS_None);
                CurrentProxyActor.SetBase(Self, , Mesh, Seats[SeatProxies[i].SeatIndex].SeatBone);

                CurrentProxyActor.SetRelativeLocation(vect(0,0,0));
                CurrentProxyActor.SetRelativeRotation(Seats[SeatProxies[i].SeatIndex].SeatRotation);

                bSetMeshRequired = true;
            }
            else
            {
                CurrentProxyActor = SeatProxies[i].ProxyMeshActor;
            }

            // TODO: this check is not needed.
            if (CurrentProxyActor != none)
            {
                CurrentProxyActor.bExposedToRain = (ROMI != none && ROMI.RainStrength != RAIN_None) && SeatProxies[i].bExposedToRain;
            }

            // Create the proxy mesh for player-enterable seat from the Pawn.
            // TODO: if we can move into loader position we may want to rethink this logic.
            if (bPlayerEnterableSeat && (ROP != None) && bIsThisPawnsSeat)
            {
                CurrentProxyActor.ReplaceProxyMeshWithPawn(ROP);
            }
            // Create it from the SeatProxy's mesh info (usually the default mesh).
            else if (bSetMeshRequired)
            {
                CurrentProxyActor.CreateProxyMesh(SeatProxies[i]);
            }

            // Override the animation set.
            if (SeatProxyAnimSet != None)
            {
                CurrentProxyActor.Mesh.AnimSets[0] = SeatProxyAnimSet;
            }

            if (bInternalVisibility)
            {
                SetSeatProxyVisibilityInteriorByIndex(i);
            }
            else
            {
                SetSeatProxyVisibilityExteriorByIndex(i);
            }

            // bForceSetVisible means we want to force visibility for *this pawn's* seat.
            if (bForceSetVisible && bIsThisPawnsSeat)
            {
                SetProxyMeshVisibility(true, CurrentProxyActor, i, true);
            }
            // Hide player-enterable seat proxies or when force-creating them. They will be unhidden when needed.
            // NOTE: Tank should always show all living non-local-player proxies.
            else if (bPlayerEnterableSeat || bForceCreateProxy)
            {
                SetProxyMeshVisibility(false, CurrentProxyActor, i, true);
            }
            // Non-enterable (loaders, etc.). Always visible.
            // TODO: If we should be able to enter loader's seat, we need to re-think this logic.
            else if (!bPlayerEnterableSeat)
            {
                SetProxyMeshVisibility(true, CurrentProxyActor, i, true);
            }
            // Fallback option is to hide. Probably shouldn't get there though.
            else
            {
                SetProxyMeshVisibility(false, CurrentProxyActor, i, true);
            }
        }
    }
}

// TODO: Should use this in every place that changes proxy actor visibility to update collision too.
//       We don't use crew collision for anything in tanks yet, but we might want to do that later on.
simulated function SetProxyMeshVisibility(bool bSetVisible, VehicleCrewProxy ProxyActor, int SeatProxyIndex,
    optional bool bEnableCrewCollision = True)
{
    `pmlog("bSetVisible=" $ bSetVisible $ " ProxyActor=" $ ProxyActor $ " SeatProxyIndex="
        $ SeatProxyIndex $ " bEnableCrewCollision=" $ bEnableCrewCollision);

    if (ProxyActor != None)
    {
        ProxyActor.HideMesh(!bSetVisible);
        ProxyActor.UpdateVehicleIK(self, SeatProxies[SeatProxyIndex].SeatIndex, SeatProxies[SeatProxyIndex].PositionIndex);
    }

    if ((SeatProxies[SeatProxyIndex].Health <= 0) && bEnableCrewCollision)
    {
        bEnableCrewCollision = False;
        `pmlog("overriding bEnableCrewCollision to False, since SeatProxy is dead!");
    }
    ChangeCrewCollision(bEnableCrewCollision, SeatProxies[SeatProxyIndex].SeatIndex);
}

// NOTE: Overridden to use SpawnOrReplaceSeatProxyCustom().
// TODO: Is this needed? Looks like we're doing all this twice now?
/**
 * Spawn the SeatProxy ProxyMeshActors on the client for SeatProxies you could
 * possibly see in third person.
 */
simulated function SpawnExternallyVisibleSeatProxies()
{
    local int i;
    local int j;
    local bool bCanBecomeVisible;

    `pmlog("spawning externally visible seat proxies...");

    // Don't spawn the seat proxy actors on the dedicated server (at least for now).
    if (WorldInfo.NetMode == NM_DedicatedServer)
    {
        return;
    }

    for (i = 0; i < SeatProxies.Length; i++)
    {
        bCanBecomeVisible = false;

        for (j = 0; j < Seats[SeatProxies[i].SeatIndex].SeatPositions.Length; j++)
        {
            if ((Seats[SeatProxies[i].SeatIndex].SeatPositions[j].SeatProxyIndex == i)
                && Seats[SeatProxies[i].SeatIndex].SeatPositions[j].bDriverVisible)
            {
                bCanBecomeVisible = true;
                break;
            }
        }

        `pmlog("SeatProxies[" $ i $ "]: bCanBecomeVisible=" $ bCanBecomeVisible);

        if ((SeatProxies[i].ProxyMeshActor == None) && bCanBecomeVisible)
        {
            SpawnOrReplaceSeatProxyCustom(
                i,                                    // SeatIndex
                None,                                 // ROP
                False,                                // bInternalVisibility
                True,                                 // bForceCreateProxy
                False,                                // bForceSetVisible
                True                                  // bOnlySeatIndex
            );
        }
    }
}

// NOTE: From ROVehicleHelicopter.
// TODO: check hide/unhide logic again. Differs from ROVehicle.
/**
 * Set the SeatProxies visibility to the foreground depth group
 *
 * @param   DriverIndex         - if set denotes the local player's SeatIndex
 */
simulated function SetSeatProxyVisibilityInterior(int DriverIndex =-1)
{
    local int i;

    `pmlog("DriverIndex=" $ DriverIndex);
    // `pmlog(GetScriptTrace());

    for (i = 0; i < SeatProxies.Length; i++)
    {
        `pmlog("Before logic : SeatProxies[" $ i $ "] HiddenGame=" $ SeatProxies[i].ProxyMeshActor.Mesh.HiddenGame,
            SeatProxies[i].ProxyMeshActor != None);

        if (SeatProxies[i].ProxyMeshActor != none)
        {
            SeatProxies[i].ProxyMeshActor.SetVisibilityToInterior();
            SeatProxies[i].ProxyMeshActor.SetLightingChannels(InteriorLightingChannels);
            SeatProxies[i].ProxyMeshActor.SetLightEnvironment(InteriorLightEnvironment);
        }

        // Hide seat proxy for the driver.
        if ((DriverIndex >= 0) && (GetSeatProxyForSeatIndex(DriverIndex) == SeatProxies[i]))
        {
            if (GetSeatProxyForSeatIndex(DriverIndex).ProxyMeshActor != none)
            {
                GetSeatProxyForSeatIndex(DriverIndex).ProxyMeshActor.HideMesh(true);
                `pmlog("    Hiding proxy for seat" @ SeatProxies[i].SeatIndex);
            }
        }
        // Hide local proxy seat (even if DriverIndex is unset).
        // TODO: this check doesn't work as expected!
        else if (IsLocalSeatProxy(i))
        {
            SeatProxies[i].ProxyMeshActor.HideMesh(true);
            `pmlog("    Hiding proxy for local seat" @ SeatProxies[i].SeatIndex);
        }
        else
        {
            /*
            // Unhide this mesh if no pawn is sitting here and the proxy is dead, or if it's a non-enterable seat.
            if (
                (((SeatProxies[i].Health <= 0) && (DriverIndex < 0)) || (GetDriverForSeatIndex(SeatProxies[i].SeatIndex) == none)
                ) || Seats[SeatProxies[i].SeatIndex].bNonEnterable)
            */
            // NOTE: Actually, since this is a tank, we want to show all non-local proxies.
            // if (True)
            // {
                // Unhide the mesh for the interior seat proxies.
                if (SeatProxies[i].ProxyMeshActor != none)
                {
                    SeatProxies[i].ProxyMeshActor.HideMesh(false);
                    // `pmlog("Unhiding proxy for seat" @ SeatProxies[i].SeatIndex @ "as health is" @ SeatProxies[i].Health);
                    `pmlog("    Unhiding proxy for seat" @ SeatProxies[i].SeatIndex);
                }
            // }
        }

        `pmlog("After logic  : SeatProxies[" $ i $ "] HiddenGame=" $ SeatProxies[i].ProxyMeshActor.Mesh.HiddenGame,
            SeatProxies[i].ProxyMeshActor != None);
    }
}

// NOTE: From ROVehicleHelicopter.
// TODO: check hide/unhide logic again. Differs from ROVehicle.
/**
 * Set the SeatProxies visibility to the world depth group if they can
 * become visible.
 *
 * @param   DriverIndex         - If set denotes the local player's SeatIndex
 */
simulated function SetSeatProxyVisibilityExterior(optional int DriverIndex =-1)
{
    local int i,j;
    local bool bCanBecomeVisible;

    `pmlog("DriverIndex=" $ DriverIndex);

    for (i = 0; i < SeatProxies.Length; i++)
    {
        `pmlog("Before logic : SeatProxies[" $ i $ "] HiddenGame=" $ SeatProxies[i].ProxyMeshActor.Mesh.HiddenGame,
            SeatProxies[i].ProxyMeshActor != None);

        bCanBecomeVisible = false;

        for (j = 0; j < Seats[SeatProxies[i].SeatIndex].SeatPositions.Length; j++)
        {
            if ((Seats[SeatProxies[i].SeatIndex].SeatPositions[j].SeatProxyIndex == i)
                && Seats[SeatProxies[i].SeatIndex].SeatPositions[j].bDriverVisible)
            {
                bCanBecomeVisible = true;
                break;
            }
        }

        if (SeatProxies[i].ProxyMeshActor != none)
        {
            SeatProxies[i].ProxyMeshActor.SetVisibilityToExterior();
            SeatProxies[i].ProxyMeshActor.SetLightingChannels(ExteriorLightingChannels);
            SeatProxies[i].ProxyMeshActor.SetLightEnvironment(LightEnvironment);

            // Don't display the proxy mesh for the driver.
            if ((DriverIndex >= 0) && (GetSeatProxyForSeatIndex(DriverIndex) == SeatProxies[i]))
            {
                GetSeatProxyForSeatIndex(DriverIndex).ProxyMeshActor.HideMesh(true);
                `pmlog("Hiding proxy for seat" @ SeatProxies[i].SeatIndex);
            }
            else if (IsLocalSeatProxy(i))
            {
                SeatProxies[i].ProxyMeshActor.HideMesh(true);
                `pmlog("Hiding proxy for local seat" @ SeatProxies[i].SeatIndex);
            }
            else
            {
                // Display meshes for third person proxies that could be seen.
                // Since this is a tank, we want to show all non-local proxies.
                if (bCanBecomeVisible
                    /*
                    && (
                        ((SeatProxies[i].Health <= 0) && (DriverIndex < 0))
                        || (GetDriverForSeatIndex(SeatProxies[i].SeatIndex) == none)
                        || Seats[SeatProxies[i].SeatIndex].bNonEnterable)
                    */
                    )
                {
                    // Unhide the mesh for the exterior seatproxies.
                    SeatProxies[i].ProxyMeshActor.HideMesh(false);
                    `pmlog("Unhiding proxy for seat" @ SeatProxies[i].SeatIndex);
                }
            }
        }

        `pmlog("After logic  : SeatProxies[" $ i $ "] HiddenGame=" $ SeatProxies[i].ProxyMeshActor.Mesh.HiddenGame,
            SeatProxies[i].ProxyMeshActor != None);
    }
}

// Non-looping version only for this SeatProxyIndex.
simulated function SetSeatProxyVisibilityInteriorByIndex(int SeatProxyIndex)
{
    if (SeatProxies[SeatProxyIndex].ProxyMeshActor != none)
    {
        SeatProxies[SeatProxyIndex].ProxyMeshActor.SetVisibilityToInterior();
        SeatProxies[SeatProxyIndex].ProxyMeshActor.SetLightingChannels(InteriorLightingChannels);
        SeatProxies[SeatProxyIndex].ProxyMeshActor.SetLightEnvironment(InteriorLightEnvironment);
    }
}

// Non-looping version only for this SeatProxyIndex.
simulated function SetSeatProxyVisibilityExteriorByIndex(int SeatProxyIndex)
{
    if (SeatProxies[SeatProxyIndex].ProxyMeshActor != none)
    {
        SeatProxies[SeatProxyIndex].ProxyMeshActor.SetVisibilityToExterior();
        SeatProxies[SeatProxyIndex].ProxyMeshActor.SetLightingChannels(ExteriorLightingChannels);
        SeatProxies[SeatProxyIndex].ProxyMeshActor.SetLightEnvironment(LightEnvironment);
    }
}

// NOTE: From ROVehicleHelicopter.
/**
 * Handle processing changes in the ReplicatedSeatProxyHealths. Currently
 * turns off the proxy mesh when they are out of health
 */
simulated function HandleSeatProxyHealthUpdated()
{
    local int i;
    local int ProxySeatIdx;
    local bool bRevivingProxy;
    local float NewReplicatedHealth;

    `pmlog("starting seat proxy health update");

    for (i = 0; i < SeatProxies.Length; i++)
    {
        `pmlog("Before logic : SeatProxies[" $ i $ "] Health=" $ SeatProxies[i].Health $ " HiddenGame=" $ SeatProxies[i].ProxyMeshActor.Mesh.HiddenGame,
            SeatProxies[i].ProxyMeshActor != None);

        // Health replicated to us (sent by the server).
        NewReplicatedHealth = GetSeatProxyHealth(i);
        bRevivingProxy = false;
        ProxySeatIdx = SeatProxies[i].SeatIndex;

        `pmlog("  SeatProxies[" $ i $ "] NewReplicatedHealth=" $ NewReplicatedHealth);

        // This proxy's health current doesn't match the new replicated health.
        if (SeatProxies[i].Health != NewReplicatedHealth)
        {

            // Proxy was dead and we got a replicated health update that revives it.
            if ((SeatProxies[i].Health <= 0) && (NewReplicatedHealth > 0))
            {
                bRevivingProxy = true;

                /* NOTE: HELOSTUFF.
                // TODO: for tanks, do we need to do other shit here? Probably not...
                if( i == 0 && bBackSeatDriving )
                    StopCopilotFlyingPosition();
                */
            }

            `pmlog("  SeatProxies[" $ i $ "] bRevivingProxy=" $ bRevivingProxy);

            // Update local proxy health to health received in the replicated variable.
            SeatProxies[i].Health = NewReplicatedHealth;

            if (SeatProxies[i].ProxyMeshActor != none)
            {
                // Bring the proxy "back to life".
                if (bRevivingProxy)
                {
                    SeatProxies[i].ProxyMeshActor.ClearBloodOverlay();

                    // Replace it entirely to get rid of gore.
                    SpawnOrReplaceSeatProxyCustom(
                        ProxySeatIdx,
                        ROPawn(Seats[ProxySeatIdx].StoragePawn),
                        IsLocalPlayerInThisVehicle(),
                        false,      // bForceCreateProxy
                        false,      // bForceSetVisible
                        false       // bOnlySeatIndex
                    );

                    if (Seats[ProxySeatIdx].SeatPositions[SeatProxies[i].PositionIndex].bDriverVisible)
                    {
                        Seats[ProxySeatIdx].PositionBlend.HandleAnimPlay(Seats[ProxySeatIdx].SeatPositions[SeatPositionIndex(ProxySeatIdx,,true)].PositionIdleAnim, true);

                        // NOTE: Tank should always show all non-local-player proxies.
                        // if (Seats[ProxySeatIdx].bNonEnterable)
                        if (IsLocalSeatProxy(i))
                        {
                            SeatProxies[i].ProxyMeshActor.HideMesh(true);
                            `pmlog("hiding local seat proxy at SeatProxies[" $ i $ "]");
                        }
                        else
                        {
                            SeatProxies[i].ProxyMeshActor.HideMesh(false);
                            `pmlog("unhiding non-local seat proxy at SeatProxies[" $ i $ "]");
                        }

                        ChangeCrewCollision(true, ProxySeatIdx);
                    }
                }
                // If the seat proxy is dead, unhide it.
                else if (SeatProxies[i].Health <= 0)
                {
                    // Driver proxy died.
                    if (ProxySeatIdx == 0)
                    {
                        // Set the current move order.
                        CurrentMoveOrder.Forward = 0;
                        CurrentMoveOrder.Strafe = 0;
                        CurrentMoveOrder.Up = 0;
                    }

                    // Play animation instead of hide in ROAnimNodeBlendDriverDeath.
                    if (Seats[ProxySeatIdx].SeatPositions[SeatProxies[i].PositionIndex].bDriverVisible)
                    {
                        //Seats[ProxySeatIdx].PositionBlend.HandleAnimPlay(Seats[ProxySeatIdx].SeatPositions[Seats[ProxySeatIdx].InitialPositionIndex].PositionIdleAnim, true);

                        SeatProxies[i].ProxyMeshActor.HideMesh(false);
                        `pmlog("unhiding dead seat proxy at SeatProxies[" $ i $ "]");

                        // if (Seats[ProxySeatIdx].bNonEnterable)
                        // {
                            ChangeCrewCollision(false, ProxySeatIdx);
                        // }
                    }
                }
            }
        }
        /*
        else
        {
            // Current health matches replicated health, not update needed.
        }
        */

        `pmlog("After logic  : SeatProxies[" $ i $ "] Health=" $ SeatProxies[i].Health $ " HiddenGame=" $ SeatProxies[i].ProxyMeshActor.Mesh.HiddenGame,
            SeatProxies[i].ProxyMeshActor != None);
    }
}

// NOTE: From ROVehicleHelicopter.
simulated function DetachDriver(Pawn P)
{
    local ROPawn ROP;

    ROP = ROPawn(P);

    // Unhide the relevant bits and give us a regular player anim again
    if (ROP != None)
    {
        ROP.Mesh.SetAnimTreeTemplate(ROP.Mesh.default.AnimTreeTemplate);
        ROSkeletalMeshComponent(ROP.Mesh).AnimSets[0]=ROSkeletalMeshComponent(ROP.Mesh).default.AnimSets[0];

        ROP.ThirdPersonHeadAndArmsMeshComponent.SetSkeletalMesh(ROP.HeadAndArmsMesh);
        ROP.ThirdPersonHeadgearMeshComponent.SetHidden(false);
        ROP.FaceItemMeshComponent.SetHidden(false);
        ROP.FacialHairMeshComponent.SetHidden(false);
        ROP.HideGear(false);
    }

    Super.DetachDriver(P);
}

// TODO: refactor this to make the logic easier to read.
// NOTE: Combined from ROVehicleHelicopter and ROVehicleTank.
/**
 * Handle transitions between seats in the vehicle which need to be animated or
 * swap meshes. Here we handle the specific per vehicle implementation of the
 * visible animated transitions between seats or the mesh swapped proxy mesh
 * instant transitions. For animated transitions that involve the turret area,
 * it performs the first half of the transition, moving them to a position
 * under the turret area. These transitions must be split into two parts,
 * since the turret can rotate, we move the players to a position under the
 * turret that will always be in the same place no matter which direction the
 * turret is rotated. Then the second half of the transition starts from this
 * position.
 *
 * @param   DriverPawn        The pawn driver that is transitioning seats
 * @param   NewSeatIndex      The SeatIndex the pawn is moving to
 * @param   OldSeatIndex      The SeatIndex the pawn is moving from
 * @param   bInstantTransition    True if this is an instant transition not an animated transition
 * Network: Called on network clients when the ROPawn Driver's VehicleSeatTransition
 * is changed. HandleSeatTransition is called directly on the server and in standalone
 */
simulated function HandleSeatTransition(ROPawn DriverPawn, int NewSeatIndex, int OldSeatIndex, bool bInstantTransition)
{
    `pmlog("DriverPawn=" $ DriverPawn $ " NewSeatIndex=" $ NewSeatIndex $ " OldSeatIndex="
        $ OldSeatIndex $ " bInstantTransition=" $ bInstantTransition);

    if (bInstantTransition && (GetSeatProxyForSeatIndex(NewSeatIndex).Health <= 0))
    {
        `pmlog("!!!!!!!!!!!!!!!!!!!!! WARNING: INSTANT TRANSITION TO DEAD PROXY, HOW DID WE GET HERE?");
        `pmlog(GetScriptTrace());
    }

    LogSeatProxyStates(self $ "_" $ GetFuncName() $ "(): before");

    // Ignore ROVehicleTank::UpdateSeatProxyHealth
    super(ROVehicleTreaded).HandleSeatTransition(DriverPawn, NewSeatIndex, OldSeatIndex, bInstantTransition);

    // Non-animated transition.
    if (bInstantTransition)
    {
        // Copied from ROVehicle.HandleSeatTransition, adds new positions for transports.
        // We don't actually use this functionality on transports currently, but it's left to handle potential mod vehicles
        if( Role == ROLE_Authority )
        {
            if( OldSeatIndex == 4 )
            {
                SetTimer(1.0, false, 'HandlePostInstantSeatTransFour');
            }
            else if( OldSeatIndex == 5 )
            {
                SetTimer(1.0, false, 'HandlePostInstantSeatTransFive');
            }
            else if( OldSeatIndex == 6 )
            {
                SetTimer(1.0, false, 'HandlePostInstantSeatTransSix');
            }
            else if( OldSeatIndex == 7 )
            {
                SetTimer(1.0, false, 'HandlePostInstantSeatTransSeven');
            }
            else if( OldSeatIndex == 8 )
            {
                SetTimer(1.0, false, 'HandlePostInstantSeatTransEight');
            }
            else if( OldSeatIndex == 9 )
            {
                SetTimer(1.0, false, 'HandlePostInstantSeatTransNine');
            }
        }

        // Set new seat proxy from the moving pawn.
        // TODO: should we call this here or later in this branch??
        SpawnOrReplaceSeatProxyCustom(
            NewSeatIndex,                                  // SeatIndex
            DriverPawn,                                    // ROP
            IsLocalPlayerInThisVehicle(),                  // bInternalVisibility
            False,                                         // bForceCreateProxy
            False,                                         // bForceSetVisible
            True                                           // bOnlySeatIndex
        );

        // Set old seat proxy from the StoragePawn (or default mesh if StoragePawn is null).
        // Set bForceCreateProxy to make sure we do it even if StoragePawn is null.
        SpawnOrReplaceSeatProxyCustom(
            OldSeatIndex,                                   // SeatIndex
            ROPawn(Seats[OldSeatIndex].StoragePawn),        // ROP
            IsLocalPlayerInThisVehicle(),                   // bInternalVisibility
            True,                                           // bForceCreateProxy
            False,                                          // bForceSetVisible
            True                                            // bOnlySeatIndex
        );

        // Turn off or on the OLD proxy mesh depending upon the health of the Proxy.
        // TODO: why is ROVehicleTank checking for NetMode here but not for the other hide/unhide calls?
        //       Is this SP only logic on purpose?
        if ((WorldInfo.NetMode != NM_DedicatedServer) && (GetSeatProxyForSeatIndex(OldSeatIndex).ProxyMeshActor != none))
        {
            `pmlog("Enter (WorldInfo.NetMode != NM_DedicatedServer) branch, NetMode=" $ WorldInfo.NetMode);

            // OLD proxy alive.
            if (GetSeatProxyForSeatIndex(OldSeatIndex).Health > 0)
            {
                // Old proxy has bDriverVisible and local player in the vic.
                if (Seats[OldSeatIndex].SeatPositions[GetSeatProxyForSeatIndex(OldSeatIndex).PositionIndex].bDriverVisible || IsLocalPlayerInThisVehicle())
                {
                    GetSeatProxyForSeatIndex(OldSeatIndex).ProxyMeshActor.HideMesh(false);
                    `pmlog("SeatProxies[" $ OldSeatIndex $ "] Setting HiddenGame to false because proxy is alive, HiddenGame = "
                        $ GetSeatProxyForSeatIndex(OldSeatIndex).ProxyMeshActor.Mesh.HiddenGame);

                    // Update and re-activate IK for the OLD Proxy Mesh...
                    GetSeatProxyForSeatIndex(OldSeatIndex).ProxyMeshActor.UpdateVehicleIK(self, OldSeatIndex, SeatPositionIndex(OldSeatIndex,,true));
                }
            }
            // OLD proxy is dead and this is an instant transition.
            else
            {
                // Seat no longer enterable -> show proxy even if it's dead.
                if (Seats[OldSeatIndex].bNonEnterable)
                {
                    GetSeatProxyForSeatIndex(OldSeatIndex).ProxyMeshActor.HideMesh(false);
                    `pmlog("SeatProxies[" $ OldSeatIndex $ "] Setting HiddenGame to false because proxy is non-enterable, HiddenGame = "
                        $ SeatProxies[OldSeatIndex].ProxyMeshActor.Mesh.HiddenGame);
                }
                // We transitioned instantly out of a dead seat. How did this happen? Should probably leave old proxy visible?
                else
                {
                    GetSeatProxyForSeatIndex(OldSeatIndex).ProxyMeshActor.HideMesh(true);
                    `pmlog("SeatProxies[" $ OldSeatIndex $ "] Setting HiddenGame to true because proxy's Health is 0, HiddenGame = "
                        $ SeatProxies[OldSeatIndex].ProxyMeshActor.Mesh.HiddenGame);
                }
            }
        }

        // TODO: This is already called in SpawnOrReplaceSeatProxyCustom() for bInstantTransition...
        // Update the driver IK.
        // if (DriverPawn != none)
        // {
        //     DriverPawn.UpdateVehicleIK(self, NewSeatIndex, SeatPositionIndex(NewSeatIndex,,true));
        // }
    }

    // NOTE: Combined From ROVehicleTank and ROVehicleHelicopter.
    // Health follows the player moving if they animated transition out of a seat.
    if (Role == ROLE_Authority)
    {
        // Instant transition -> health follows the player.
        if (bInstantTransition)
        {
            UpdateSeatProxyHealth(GetSeatProxyIndexForSeatIndex(NewSeatIndex), GetSeatProxyForSeatIndex(OldSeatIndex).Health, true);
            `pmlog("Old Seat Health = " $ GetSeatProxyForSeatIndex(OldSeatIndex).Health);
            `pmlog("New Seat Health = " $ GetSeatProxyForSeatIndex(NewSeatIndex).Health);
        }
        // Animated transition, old proxy is dead -> seat health to 0 (?).
        else
        {
            UpdateSeatProxyHealth(GetSeatProxyIndexForSeatIndex(NewSeatIndex), GetSeatProxyForSeatIndex(OldSeatIndex).Health, true);
            UpdateSeatProxyHealth(GetSeatProxyIndexForSeatIndex(OldSeatIndex), 0, true);
            `pmlog("Old Seat Health = " $ GetSeatProxyForSeatIndex(OldSeatIndex).Health);
            `pmlog("New Seat Health = " $ GetSeatProxyForSeatIndex(NewSeatIndex).Health);
        }
    }

    // NOTE: Combined From ROVehicleTank and ROVehicleHelicopter.
    if (GetSeatProxyForSeatIndex(OldSeatIndex).ProxyMeshActor != none)
    {
        // Animated transition -> hide old seat proxy. NOTE: we're only doing animated transitions
        // if the target seat is empty/dead and we are moving out of our position to replace that new seat...
        if (!bInstantTransition)
        {
            GetSeatProxyForSeatIndex(OldSeatIndex).ProxyMeshActor.HideMesh(true);
            `pmlog("SeatProxies[" $ OldSeatIndex $ "] Setting HiddenGame to true because transition was animated, HiddenGame = "
                    $ SeatProxies[OldSeatIndex].ProxyMeshActor.Mesh.HiddenGame);
        }
        // Instant transition -> check health and enterability.
        // NOTE: This should be covered already in the first if(bInstantTransition) branch for SP... Or is it?
        else
        {
            // Old seat is non-enterable -> always show proxy (ignore health).
            // TODO: is this even possible for tanks? Seats' bNonEnterable values shouldn't change for tanks...
            //       This branch would happen if we move out of loader's position (which we shouldn't be able
            //       to enter anyway, in the first place).
            if (Seats[OldSeatIndex].bNonEnterable)
            {
                GetSeatProxyForSeatIndex(OldSeatIndex).ProxyMeshActor.HideMesh(false);
                `pmlog("SeatProxies[" $ OldSeatIndex $ "] Setting HiddenGame to false because proxy is non-enterable, HiddenGame = "
                    $ SeatProxies[OldSeatIndex].ProxyMeshActor.Mesh.HiddenGame);
            }
            // TODO: Need to think about this. If we move out of a dead position, the OLD proxy should be hidden,
            //       since the only way we got there was if the proxy was dead before we move into the position,
            //       so we should leave it in dead state after we move away.
            //       If the OLD proxy is alive, that means we are doing instant transitions and it should be left visible.
            // Conclusion: lots of convoluted logic (and unnecessary) checks in this function for scenarios that shouldn't happen anyway...
            else
            {
                // Old seat proxy is alive -> show proxy.
                if (GetSeatProxyForSeatIndex(OldSeatIndex).Health > 0)
                {
                    GetSeatProxyForSeatIndex(OldSeatIndex).ProxyMeshActor.HideMesh(false);
                    `pmlog("SeatProxies[" $ OldSeatIndex $ "] Setting HiddenGame to false because proxy alive, HiddenGame = "
                        $ SeatProxies[OldSeatIndex].ProxyMeshActor.Mesh.HiddenGame);
                }
                // Old seat proxy is dead -> hide it. How did we move out of a dead proxy instantly?
                else
                {
                    GetSeatProxyForSeatIndex(OldSeatIndex).ProxyMeshActor.HideMesh(true);
                    `pmlog("SeatProxies[" $ OldSeatIndex $ "] Setting HiddenGame to true because proxy is dead, HiddenGame = "
                        $ SeatProxies[OldSeatIndex].ProxyMeshActor.Mesh.HiddenGame);
                }
            }
        }
    }

    // NOTE: for animated transitions, SpawnOrReplaceSeatProxyCustom is called in FinishTransition,
    //       which is triggered by a timer, individually in each vehicle's subclass code.

    LogSeatProxyStates(self $ "_" $ GetFuncName() $ "(): after");
}

/**
 * Handle SeatProxy transitions between seats in the vehicle which need to be
 * animated or swap meshes. When called on the server the subclasses handle
 * replicating the information so the animations happen on the client
 * Since the transitions are very vehicle specific, all of the actual animations,
 * etc must be implemented in subclasses
 * @param   NewSeatIndex          The SeatIndex the proxy is moving to
 * @param   OldSeatIndex          The SeatIndex the proxy is moving from
 * Network: Called on network clients when the ProxyTransition variables
 * implemented in subclass are changed. HandleProxySeatTransition is called
 * directly on the server and in standalone
 */
// TODO: this is only used in tank replication code. How does this differ from HandleSeatTransition?
simulated function HandleProxySeatTransition(int NewSeatIndex, int OldSeatIndex)
{
    `pmlog("NewSeatIndex=" $ NewSeatIndex $ " OldSeatIndex=" $ OldSeatIndex);
    super.HandleProxySeatTransition(NewSeatIndex, OldSeatIndex);
}

/**
 * Use on the server to update the health of a SeatProxy. This function will
 * set the health of the SeatProxy, and call the function to replicate the
 * health to the client.
 * @param   SeatProxyIndex        The seat proxy you want to update the health for
 * @param   NewHealth             The value to set the SeatProxy Health to
 */
function UpdateSeatProxyHealth(int SeatProxyIndex, int NewHealth, optional bool bIsTransition)
{
    // Ignore ROVehicleTank::UpdateSeatProxyHealth because it has leftover code from RO2.
    super(ROVehicleTreaded).UpdateSeatProxyHealth(SeatProxyIndex, NewHealth, bIsTransition);
}

simulated function bool CanEnterVehicle(Pawn P)
{
    return !bDeadVehicle && super.CanEnterVehicle(P);
}

// TODO: this doesn't do anything in ROVehicleTank, it only changes
// collision for helicopter and transport crew members. We can probably ignore this
// for tanks since they don't use CrewHitZoneStart/CrewHitZoneEnd optimization
// like open top vehicles (transports/helicopters) AND tank crews aren't supposed to
// take explosion radius damage anyway.
// TODO: need to revisit this if we want open top tanks and/or for the crew members
// to take explosion radius damage for any other reason (driving with open hatch,
// passengers sitting on top of the vehicle, etc.).
simulated function ChangeCrewCollision(bool bEnable, int SeatIndex)
{
    // local int i;

    // // Hide or unhide our driver collision cylinders.
    // for (i = CrewHitZoneStart; i <= CrewHitZoneEnd; i++)
    // {
    //     if (VehHitZones[i].CrewSeatIndex == SeatIndex)
    //     {
    //         if (bEnable)
    //         {
    //             Mesh.UnhideBoneByName(VehHitZones[i].CrewBoneName);
    //         }
    //         else
    //         {
    //             Mesh.HideBoneByName(VehHitZones[i].CrewBoneName, PBO_Disable);
    //         }
    //     }
    // }
}

// Fired by a timer in each vehicle subclass code.
// NOTE: Added SpawnOrReplaceSeatProxyCustom.
simulated function FinishTransition(int SeatTransitionedTo)
{
    local ROPlayerController ROPC;
    local ROPawn P;

    `pmlog("SeatTransitionedTo=" $ SeatTransitionedTo);

    // Find the local PlayerController for this transition.
    ROPC = ROPlayerController(Seats[SeatTransitionedTo].SeatPawn.Controller);

    if (ROPC != None && LocalPlayer(ROPC.Player) != none)
    {
        // Set the FOV to the initial FOV for this position when the transition is complete.
        ROPC.HandleTransitionFOV(Seats[SeatTransitionedTo].SeatPositions[Seats[SeatTransitionedTo].InitialPositionIndex].ViewFOV, 0.0);
    }

    P = ROPawn(Seats[SeatTransitionedTo].StoragePawn);
    if (P != None)
    {
        // To set correct customization etc. for the new seat.
        SpawnOrReplaceSeatProxyCustom(
            SeatTransitionedTo,                  // SeatIndex
            P,                                   // ROP
            IsLocalPlayerInThisVehicle(),        // bInternalVisibility
            False,                               // bForceCreateProxy
            False,                               // bForceSetVisible
            True                                 // bOnlySeatIndex
        );
    }
    else
    {
        // If this happens, should we run some default error handling version of SpawnOrReplaceSeatProxyCustom()?
        // Did the player get kicked/disconnected before the transition ended? Did they exit the vehicle
        // somehow during the transition?
        // Or is StoragePawn set after FinishTransition??
        `pmlog("!!! ERROR !!! SeatTransitionedTo=" $ SeatTransitionedTo $ " Pawn is NULL!");
    }

    Seats[SeatTransitionedTo].bTransitioningToSeat = false;
    Seats[SeatTransitionedTo].SeatTransitionBoneName = '';
    Seats[SeatTransitionedTo].TransitionPawn = none;
    Seats[SeatTransitionedTo].TransitionProxy = none;
}

// NOTE: Added ReviveProxies() call similarly to ROVehicleHelicopter.
/**
 * Repair all of the damaged armor and internal hit zones in the vehicle
 *
 * @return  returns true if any repairs were done
 */
function bool FullyRepairVehicle()
{
    local bool bDidSomeRepairs;

    bDidSomeRepairs = super.FullyRepairVehicle();
    ReviveProxies();
    return bDidSomeRepairs;
}

// NOTE: From ROVehicleHelicopter.
/**
 * Bring dead seat proxies back to life
 * @return true if any proxies were brought back to life
 */
simulated function bool ReviveProxies()
{
    local int i;
    local int ProxySeatIdx;
    local bool bDidRevive;

    for (i = 0; i < SeatProxies.Length; i++)
    {
        if ((SeatProxies[i].Health < 100) && !SeatbDriving(SeatProxies[i].SeatIndex,,true))
        {
            ProxySeatIdx = SeatProxies[i].SeatIndex;

            UpdateSeatProxyHealth(i, 100);

            if (Seats[ProxySeatIdx].bNonEnterable)
            {
                ChangeCrewCollision(true, ProxySeatIdx);
            }

            SpawnOrReplaceSeatProxyCustom(
                ProxySeatIdx,                                   // SeatIndex
                ROPawn(Seats[ProxySeatIdx].StoragePawn),        // ROP
                IsLocalPlayerInThisVehicle(),                   // bInternalVisibility
                False,                                          // bForceCreateProxy
                False,                                          // bForceSetVisible
                True                                            // bOnlySeatIndex
            );

            bDidRevive = true;
        }
    }

    // NOTE: HELOSTUFF.
    // If the copilot is currently active in a proxy copilot type aircraft, reset the enterable seats
    /*
    if( bCopilotCanFly && default.Seats[SeatIndexCopilot].bNonEnterable && !Seats[SeatIndexCopilot].bNonEnterable )
    {
        if( Role == ROLE_Authority )
        {
            SetCopilotEnterable(false);
        }
        SetTimer(0.25, false, 'DelayedMoveCopilotToPilot');
    }

    CritComponentDestroyer = none;
    */

    return bDidRevive;
}

// NOTE: From ROVehicleHelicopter.
/**
 * This function is called when the driver's status has changed.
 */
simulated function DrivingStatusChanged()
{
    //local ROPlayerController ROPC;

    // NOTE: Ignore ROVehicleTank::DrivingStatusChanged.
    super(ROVehicleTreaded).DrivingStatusChanged();

    /*ROPC = ROPlayerController(Driver.Controller);

    // Couldn't find the Controller for the driver, check the Vehicle
    if( ROPC == none )
    {
        ROPC = ROPlayerController(Controller);
    }
    */
    // Update the driver's hit detection.
    ChangeCrewCollision(bDriving, 0);
}

/**
 * Spawn all seat proxies and set non-local-player proxies visible.
 *
 * @param SeatIndex indicates the local player's seat index.
 * @param ROP       the local player's pawn.
 */
simulated function SpawnSeatProxiesCustom(int SeatIndex, optional ROPawn ROP = None)
{
    local int i;
    local ROPawn LocalPawn;

    if (WorldInfo.NetMode == NM_DedicatedServer)
    {
        return;
    }

    `pmlog("SeatIndex=" $ SeatIndex);

    for (i = 0; i < Seats.Length; ++i)
    {
        if (i == SeatIndex)
        {
            if (ROP == None)
            {
                LocalPawn = ROPawn(Seats[i].StoragePawn);
            }
            else
            {
                LocalPawn = ROP;
            }

            // This is the seat for *this local player*:
            // Internally visible, non-force-create, non-force-set-visible.
            SpawnOrReplaceSeatProxyCustom(
                i,                                    // SeatIndex
                LocalPawn,                            // ROP
                IsLocalPlayerInThisVehicle(),         // bInternalVisibility
                False,                                // bForceCreateProxy
                False,                                // bForceSetVisible
                True                                  // bOnlySeatIndex
            );

            // Just to be safe, do this here. Should not be needed though...
            // TODO: Check if we need this call and remove if we don't!
            SetProxyMeshVisibility(false, GetSeatProxyForSeatIndex(SeatIndex).ProxyMeshActor, i, true);
        }
        else
        {
            // Seats for other, non-local players (or empty seats). Force set visible.
            // If StoragePawn exists, it will be used for the proxy mesh.
            SpawnOrReplaceSeatProxyCustom(
                i,                                    // SeatIndex
                ROPawn(Seats[i].StoragePawn),         // ROP
                IsLocalPlayerInThisVehicle(),         // bInternalVisibility
                True,                                 // bForceCreateProxy
                True,                                 // bForceSetVisible
                True                                  // bOnlySeatIndex
            );
        }
    }
}

// NOTE: Don't call this manually. Use SpawnOrReplaceSeatProxyCustom() or SpawnSeatProxies() instead.
simulated function SpawnSeatProxies()
{
    `pmlog("*** *** WARNING *** *** old function SpawnSeatProxies() called! Script trace:\n"
        $ GetScriptTrace() $ "\n\n*** *** WARNING *** ***");
    GetALocalPlayerController().ClientMessage("WARNING: SpawnSeatProxies() called, check the log!");
}

/**
 * Call this function to blow up the vehicle.
 */
// TODO: Add handling for new death types.
// TODO: Delayed death system for playing crew escape animations.
simulated function BlowupVehicle()
{
    local int i;

    VehicleEvent('EngineStop');

    // Must destroy these BEFORE GoToState('DyingVehicle').
    // Otherwise we might swap to the destroyed mesh before
    // destroying these, which can break their transform and
    // cause log spam -Austin.
    for (i = 0; i < EntryPoints.length; i++)
    {
        if (EntryPoints[i].EntryActor != none)
        {
            EntryPoints[i].EntryActor.SetBase(none);
            EntryPoints[i].EntryActor.Destroy();
            EntryPoints[i].EntryActor = none;
        }
    }

    if (WorldInfo.NetMode != NM_Client)
    {
        if (bHitAmmo)
        {
            // 50% chance of blowing the Turret off if you hit the ammo.
            if (Rand(2) == 1)
            {
                DeadVehicleType = EDVT_AmmoExplosionTurretBlowoff;
            }
            else
            {
                DeadVehicleType = EDVT_AmmoExplosion;
            }
        }
        else
        {
            DeadVehicleType = EDVT_Explosion;
        }
    }

    bCanBeBaseForPawns = false;
    GotoState('DyingVehicle');
    AddVelocity(TearOffMomentum, TakeHitLocation, HitDamageType);
    bDeadVehicle = true;
    bStayUpright = false;

    if (StayUprightConstraintInstance != None)
    {
        StayUprightConstraintInstance.TermConstraint();
    }
}

/** Turn the vehicle interior visibility on or off. */
simulated function SetInteriorVisibility(bool bVisible)
{
    local bool bHide;
    local int i, j, TextureBias;

    `pmlog("bVisible = " $ bVisible);

    // `pmlog(GetScriptTrace());

    bHide = !bVisible;
    TextureBias = bVisible ? -2 : 0;

    // Change the component visibility only if it changed.
    if (bInteriorVisible != bVisible)
    {
        for (i = 0; i < MeshAttachments.length; i++)
        {
            if(MeshAttachments[i].Component == none)
            {
                continue;
            }

            MeshAttachments[i].Component.SetHidden(bHide);

            // Set negative texture lod bias to tank interior
            for (j = 0; j < MeshAttachments[i].Component.GetNumElements(); j++)
            {
                if (MeshAttachments[i].Component.GetMaterial(j) != none)
                {
                    MeshAttachments[i].Component.GetMaterial(j).ApplyLodBias(TextureBias);
                }
            }
        }

        // Update the state of the interior visibility flag.
        bInteriorVisible = bVisible;
    }

    if (Mesh != None)
    {
        for (i = 0; i < Mesh.GetNumElements(); i++)
        {
            if (Mesh.GetMaterial(i) != None)
            {
                Mesh.GetMaterial(i).ApplyLodBias(TextureBias);
            }
        }
    }

    for (i = 0; i < Seats.Length; i++)
    {
        ForceOverlayTextureMipsToBeResident(i, bVisible);
    }
}

// Return true if local player is in this seat.
// TODO: might not work as expected. Need to investigate.
simulated function bool IsLocalSeat(int SeatIndex)
{
    local Pawn out_LocalPawn;
    local ROPawn StoragePawn;
    local Vehicle SeatPawn;
    local ROPlayerController ROPC;

    // `pmlog("### ### LOCAL SEAT LOGIC DEBUG CHECKS BEGIN ### ###");
    `pmlog("SeatIndex         = " $ SeatIndex);

    StoragePawn = ROPawn(Seats[SeatIndex].StoragePawn);
    SeatPawn = Seats[SeatIndex].SeatPawn;

    // `pmlog("StoragePawn       = " $ StoragePawn);
    // `pmlog("SeatPawn          = " $ SeatPawn);

    // Can't have local player in this seat if there is no storage pawn or seat pawn.
    if ((StoragePawn == None) && (SeatPawn == None))
    {
        return false;
    }

    // TODO: can we just return true if ROPC is not None? Are all the below checks really necessary?
    ROPC = ROPlayerController(FindVehicleLocalPlayerController(StoragePawn, SeatIndex, out_LocalPawn));

    // `pmlog("ROPC              = " $ ROPC);
    // `pmlog("out_LocalPawn     = " $ out_LocalPawn);
    // `pmlog("ROPawn(ROPC.Pawn) = " $ ROPawn(ROPC.Pawn));
    // if (StoragePawn != None)
    // {
    //     `pmlog("StoragePawn.Ctrl. = " $ ROPlayerController(StoragePawn.Controller));
    // }
    // if (SeatPawn != None)
    // {
    //     `pmlog("SeatPawn.Ctrl.    = " $ ROPlayerController(SeatPawn.Controller));
    // }

    // `pmlog("### ### LOCAL SEAT LOGIC DEBUG CHECKS END ### ###");

    // Didn't find player controller -> can't have local player in this seat.
    if (ROPC == None)
    {
        return false;
    }
    if (StoragePawn == ROPawn(out_LocalPawn))
    {
        return true;
    }
    // Vehicle driver (owner) is local player.
    if (StoragePawn == ROPawn(ROPC.Pawn))
    {
        return true;
    }
    if (StoragePawn != None)
    {
        // Local PlayerController is the StoragePawn's controller.
        if (ROPC == ROPlayerController(StoragePawn.Controller))
        {
            return true;
        }
    }
    if (SeatPawn != None)
    {
        // Local PlayerController is the SeatPawn's controller.
        if (ROPC == ROPlayerController(SeatPawn.Controller))
        {
            return true;
        }
    }

    return false;
}

// Return true if local player is in this seat proxy.
simulated function bool IsLocalSeatProxy(int SeatProxyIndex)
{
    return IsLocalSeat(SeatProxies[SeatProxyIndex].SeatIndex);
}

// NOTE: Moved here from ROVehicle to do some additional checks.
simulated function SetVehicleDepthToForeground()
{
    local int i;
    local ROPawn ROP;

    `pmlog("setting vehicle depth to foreground");

    Mesh.ForcedLodModel = 1;
    Mesh.CastShadow = false;

    // Set interior lighting channels.
    Mesh.SetLightingChannels(InteriorLightingChannels);
    // Switch to the interior LE when inside the vehicle.
    Mesh.SetLightEnvironment(InteriorLightEnvironment);

    // Remove the min LOD restriction so that the interior of the vehicle can be displayed.
    Mesh.MinLodModel = 0;

    // Set the tank and drivers to the foreground if you are viewing from inside it.
    Mesh.SetDepthPriorityGroup(SDPG_Foreground);

    for (i = 0; i < Seats.length; i++)
    {
        if (Seats[i].bNonEnterable)
        {
            continue;
        }

        ROP = GetDriverForSeatIndex(i);

        // TODO: Does this also make the driver see his own first person mesh?
        //       Probably not, but this logic is a bit suspicious in any case. Need to
        //       think about it more later.
        if (ROP != none && ROP.Mesh != none)
        {
            ROP.Mesh.SetDepthPriorityGroup(SDPG_Foreground);
            ROP.ThirdPersonHeadAndArmsMeshComponent.SetDepthPriorityGroup(SDPG_Foreground);
            ROP.ThirdPersonHeadgearMeshComponent.SetDepthPriorityGroup(SDPG_Foreground);

            if( ROP.ThirdPersonHeadphonesMeshComponent != none )
            {
                ROP.ThirdPersonHeadphonesMeshComponent.SetDepthPriorityGroup(SDPG_Foreground);
            }
            if( ROP.ClothComponent != none )
            {
                ROP.ClothComponent.SetDepthPriorityGroup(SDPG_Foreground);
            }
            if( ROP.FaceItemMeshComponent != none )
            {
                ROP.FaceItemMeshComponent.SetDepthPriorityGroup(SDPG_Foreground);
            }
            if( ROP.FacialHairMeshComponent != none )
            {
                ROP.FacialHairMeshComponent.SetDepthPriorityGroup(SDPG_Foreground);
            }

            ROP.SetLightingChannels(InteriorLightingChannels);
            ROP.SetLightEnvironment(InteriorLightEnvironment);
        }
    }

    SetSeatProxyVisibilityInterior();

    SetInteriorVisibility(true);
}

// -------------------- DEBUG HELPERS --------------------
`ifdef(DEBUG_BUILD)

simulated function BlowupVehicleForcedTurretBlowOff()
{
    local int i;

    VehicleEvent('EngineStop');

    for (i = 0; i < EntryPoints.length; i++)
    {
        if (EntryPoints[i].EntryActor != none)
        {
            EntryPoints[i].EntryActor.SetBase(none);
            EntryPoints[i].EntryActor.Destroy();
            EntryPoints[i].EntryActor = none;
        }
    }

    if (WorldInfo.NetMode != NM_Client)
    {
        DeadVehicleType = EDVT_AmmoExplosionTurretBlowoff;
    }

    bCanBeBaseForPawns = false;
    GotoState('DyingVehicle');
    AddVelocity(TearOffMomentum, TakeHitLocation, HitDamageType);
    bDeadVehicle = true;
    bStayUpright = false;

    if (StayUprightConstraintInstance != None)
    {
        StayUprightConstraintInstance.TermConstraint();
    }
}

simulated function LogSeatProxyStates(coerce string Msg = "")
{
    local int i;
    local string HiddenStatusStr;
    local SeatProxy SP;
    local VehicleSeat VS;
    local ROSkeletalMeshComponent SM;
    local Pawn StoragePawn;
    local Controller StoragePawnController;
    local Controller SeatPawnController;
    local Pawn SeatPawn;

    `pmlog(Msg $ ": SeatProxies:");
    `log("**** **** **** **** **** ****");
    for (i = 0; i < SeatProxies.Length; ++i)
    {
        SP = SeatProxies[i];

        if (SP.ProxyMeshActor != None)
        {
            SM = SP.ProxyMeshActor.Mesh;
        }

        if (SM != None)
        {
            HiddenStatusStr = string(SM.HiddenGame);
        }
        else
        {
            HiddenStatusStr = "(mesh==null)";
        }

        `log("  SeatProxies[" $ i $ "]: Health=" $ SP.Health $ " SeatIndex=" $ SP.SeatIndex
            $ " PositionIndex=" $ SP.PositionIndex $ " HiddenGame=" $ HiddenStatusStr
            $ " ProxyMeshActor=" $ SP.ProxyMeshActor);
    }
    `log("**** **** **** **** **** ****");

    `pmlog(Msg $ ": Seats:");
    `log("**** **** **** **** **** ****");
    for (i = 0; i < Seats.Length; ++i)
    {
        VS = Seats[i];
        StoragePawn = VS.StoragePawn;
        if (StoragePawn != None)
        {
            StoragePawnController = StoragePawn.Controller;
        }
        if (VS.SeatPawn != None)
        {
            SeatPawn = VS.SeatPawn;
            SeatPawnController = SeatPawn.Controller;
        }

        `log("  Seats[" $ i $ "]: StoragePawn=" $ StoragePawn $ " bNonEnterable=" $ VS.bNonEnterable
            $ " StoragePawnController=" $ StoragePawnController
            $ " SeatPawn(Weapon)=" $ SeatPawn $ " SeatPawnController=" $ SeatPawnController);
    }
    `log("**** **** **** **** **** ****");
}

simulated function DebugKillDriver(int DriverToKill)
{
    local ROPawn ROP;

    ROP = ROPawn(Seats[DriverToKill].SeatPawn.Driver);

    if (ROP != none)
    {
        ROP.TakeDamage(150, none, vect(0, 0, 0), vect(0, 0, 0), class'DamageType');
    }
}

simulated function DebugKillProxy(int ProxyToKill)
{
    if(Role < ROLE_Authority)
    {
        DebugServerKillProxy(ProxyToKill);
    }
    else
    {
        UpdateSeatProxyHealth(ProxyToKill, 0);
    }
}

reliable server function DebugServerKillProxy(int ProxyToKill)
{
    UpdateSeatProxyHealth(ProxyToKill, 0);
}

simulated function DebugRefreshProxies()
{
    local int i;

    for (i = 0; i < SeatProxies.Length; i++)
    {
        UpdateSeatProxyHealth(i, 100);
    }
}

simulated function DebugReviveProxies()
{
    ReviveProxies();
}

simulated function DebugDestroyProxies()
{
    local int i;

    for (i = 0; i < SeatProxies.Length; i++)
    {
        SeatProxies[i].ProxyMeshActor.SetBase(none);
        SeatProxies[i].ProxyMeshActor.Destroy();
        SeatProxies[i].ProxyMeshActor = none;
        `pmlog("SeatProxies[" $ i $ "].ProxyMeshActor = " $ SeatProxies[i].ProxyMeshActor);
    }
}

simulated function DebugDamageProxy(int ProxyIndex, int DamageAmount)
{
    DamageSeatProxy(ProxyIndex, DamageAmount, GetALocalPlayerController(),
        vect(0,0,0), vect(0,0,0), class'RODamageType_CannonShell_AP');
}

`endif // DEBUG_BUILD

DefaultProperties
{
    // This is the same in VehicleCrewProxy, not sure why it's even needed.
    PassengerAnimTree=AnimTree'CHR_Playeranimtree_Master.CHR_Tanker_animtree'

    // For debugging.
    bInfantryCanUse=True

    WeaponPawnClass=class'PMWeaponPawn'

    TrackSplineActorClass=class'PMTrackSplineActor'
    SplineTrackPieceClass=class'PMSplineMover'

    TrackPieceWidth = 4
    TrackPieceOffset = 2

    bDebugTrackSpline=True

    // TrackMasterSkelControlLeftName=Track_Master_Left
    // TrackMasterSkelControlRightName=Track_Master_Right
}
