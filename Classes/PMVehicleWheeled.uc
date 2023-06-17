class PMVehicleWheeled extends ROVehicleWheeled
    abstract;

// TODO: LookAt controlled by a socket attached to a bone.
// The bone's location is controlled by player camera direction.

// TODO: braking right foot IK.

// TODO: this doesn't work as expected.
enum DriverAction_Custom
{
    DAct_Default_DUMMY,
    DAct_ShiftGears_DUMMY,
    DAct_ReloadCoaxMG_DUMMY,
    DAct_CannonReload_LH1_DUMMY,
    DAct_CannonReload_LH2_DUMMY,
    DAct_CannonReload_LH3_DUMMY,
    DAct_CannonReload_LHOff_DUMMY,
    DAct_CannonReload_RH1_DUMMY,
    DAct_CannonReload_RH2_DUMMY,
    DAct_CannonReload_RHOff_DUMMY,

    DAct_SteerSwap_RHOn,
    DAct_SteerSwap_RHOff, // TODO: is this needed?
};

const DAct_SteerSwap_RHOn = 3; // DAct_CannonReload_LH1

var(Seats) class<VehicleCrewProxy> VehicleCrewProxyClass;

var(Animation) AnimTree PassengerAnimTree;

var(Animation) float DebugPointAtDistance;

// TODO: PUT THIS IN VEHICLECREWPROXY?
// Name of the controller in PassengerAnimTree.
// var(Animation) name LeftHandPalmTwistSkelControlName;
// // Controllers indexed by SeatProxyIndex.
// var(Animation) array<SkelControl_TwistBone> LeftHandPalmTwistSkelControls;

// var(Animation) hand pose controls?

// TODO: Extra AnimSet for non-driver passengers?
// var(Animation) AnimSet PassengerAnimSet;

var() float EngineRPM;

// replication
// {
// 	if( bNetDirty )
// 		VehHitZoneHealths, VehHitZoneHealthsChanged, StartResupplyTime, HittingCanopyVolumeStatus, CurrentRPM, DesiredRPM, bInSpawnProtection;

// 	if( bNetDirty && Role == ROLE_Authority )
// 		HelicopterArrayIndex, bIncomingMissile, bAutoHover, bCopilotActive, bEngineOn,
// 		bUseAdvancedFlightModel, MouseTurnMode, bBrokeLeftSkid, bBrokeRightSkid, bCanopyShattered;

// 	if( Role == ROLE_Authority && bNetDirty && !IsSeatControllerReplicationViewer(0) )
// 		KeyForward, KeyStrafe, KeyTurn, KeyUp, MouseTurn, MouseLookUp;

// 	if ( Role == ROLE_Authority && bNetDirty && bNetOwner )
// 		VolumeHeloTrainingRespawnTime;
// }

var(Animation) name SteeringWheelBoneName;
var(Animation) name SteeringWheelSkelControlName;
var(Animation) SkelControlHandlebars SteeringWheelSkelControl;
// TODO: In degrees for now, use unreal rots later.
var(Animation) float SteeringRightSwapAngleOn;
var(Animation) float SteeringRightSwapAngleOff;

var(Animation) name SteeringWheelRotScaleSkelControlName;
var(Animation) SkelControlSingleBone SteeringWheelRotScaleSkelControl;
// Scales steering wheel rotation to achieve more realistic steering.
var(Animation) float SteeringWheelRotScale;

// Indexed by seat index.
var(Animation) array<name> LookAtTargetSkelControlNames;
// Indexed by seat index.
var(Animation) array<SkelControlSingleBone> LookAtTargetSkelControls;

// Indexed by seat index.
var(Animation) array<name> PointAtTargetSkelControlNames;
// Indexed by seat index.
var(Animation) array<SkelControlSingleBone> PointAtTargetSkelControls;
// Indexed by seat index.
var(Animation) array<name> PointAtRootBoneNames;

var(Animation) name BrakePedalSkelControlName;
var(Animation) PMSkelControlBrakePedal BrakePedalSkelControl;

// TODO: why are LookAt and PointAt controls tied to the car? Does this make any sense?

// TODO: We'll want these in the future.
function SetPendingDestroyIfEmpty(float WaitToDestroyTime);
function DestroyIfEmpty();
function SelfDestructTankIfEmpty();

simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
    local int Idx;

    super.PostInitAnimTree(SkelComp);

    if (SkelComp == Mesh)
    {
        if (SteeringWheelSkelControlName != '')
        {
            SteeringWheelSkelControl = SkelControlHandlebars(
                Mesh.FindSkelControl(SteeringWheelSkelControlName));

            if (SteeringWheelSkelControl != None)
            {
                SteeringWheelSkelControl.SetSkelControlActive(True);
            }
        }

        if (BrakePedalSkelControlName != '')
        {
            BrakePedalSkelControl = PMSkelControlBrakePedal(
                Mesh.FindSkelControl(BrakePedalSkelControlName));

            if (BrakePedalSkelControl != None)
            {
                BrakePedalSkelControl.SetSkelControlActive(True);
                BrakePedalSkelControl.OwnerVehicle = self;
            }
        }

        for (Idx = 0; Idx < Wheels.Length; ++Idx)
        {
            Wheels[Idx].WheelControl.SetSkelControlActive(True);
        }

        for (Idx = 0; Idx < Seats.Length; ++Idx)
        {
            // TODO: is it necessary to load these dynamically?
            // TODO: Custom LookAtInfo only supported for SeatPosition=0 for now.
            LookAtTargetSkelControlNames[Idx] = Seats[Idx].SeatPositions[0].LookAtInfo.DefaultLookAtTargetName;
            LookAtTargetSkelControls[Idx] = SkelControlSingleBone(
                Mesh.FindSkelControl(LookAtTargetSkelControlNames[Idx]));

            PointAtTargetSkelControls[Idx] = SkelControlSingleBone(
                Mesh.FindSkelControl(PointAtTargetSkelControlNames[Idx]));
        }
    }
}

simulated event Tick(float DeltaTime)
{
    // local float Speed;
    local int SeatIdx;
    local vector V;
    local vector PointAtLoc;
    local rotator PointAtRot;
    local rotator R;
    local name LookAtControlName;
    local name PointAtControlName;
    local Controller C;
    local int NumControllers;
    local bool bSeatHasHuman;
    local vector CamToPointAtRoot;

    super.Tick(DeltaTime);

    // TODO: Use squared for performance?
    // TODO: is this only needed on client? Keep it for both now.
    // TODO: use ForwardVel here?
    // Speed = VSize(Velocity);

    EngineRPM = EvalInterpCurveFloat(ROVehicleSimCar(SimObj).EngineRPMCurve, ForwardVel);

    // TODO: use GetMappedRangeValue or curve?
    // TODO: hard-coded for now. Make a better system. Another curve needed?
    // TODO: cache StopThreshold as an instance variable?
    if (Abs(ForwardVel) <= SVehicleSimCar(SimObj).StopThreshold)
    {
        // TODO: If if throttle != 0, just keep previous gear?
        if (Throttle ~= 0.0)
        {
            OutputGear = 1; // Neutral.
        }
        else if (Throttle > 0 && ForwardVel > 0)
        {
            OutputGear = 2;
        }
        else if (Throttle < 0 && ForwardVel < 0)
        {
            OutputGear = 0;
        }
    }
    else if (ForwardVel < 0)
    {
        OutputGear = 0;
    }
    else if (ForwardVel >= 0 && ForwardVel <= 549)
    {
        OutputGear = 2;
    }
    else if (ForwardVel > 549 && ForwardVel <= 849)
    {
        OutputGear = 3;
    }
    else if (ForwardVel > 849 /*&& ForwardVel <= 1100*/)
    {
        OutputGear = 4;
    }
    else
    {
        `pmlog("unable to determine OutputGear from ForwardVel: " $ ForwardVel);
    }

    // aladenberger 9/28/2010 - Delay gear shift for animation to play
    if (ShiftTimeRemaining > 0.f)
    {
        ShiftTimeRemaining -= DeltaTime;
        if (ShiftTimeRemaining <= 0.f)
        {
            // shift finished
            DelayedOutputGear = TargetOutputGear;
            if (DelayedOutputGear != OutputGear)
            {
                // shift again without letting clutch up
                TargetOutputGear = OutputGear;
                ShiftTimeRemaining = GearShiftTime;
                // begin client-side effects
                PlayGearShift(true);
            }
            else
            {
                HandleDriverIKAction(DAct_Default);
            }
        }
    }
    else if (DelayedOutputGear != OutputGear)
    {
        // begin normal shift
        TargetOutputGear = OutputGear;
        ShiftTimeRemaining = ClutchInTime + GearShiftTime;
        // begin client-side effects
        PlayGearShift(false);
    }

    // Client side effects follow.
    if (WorldInfo.NetMode == NM_DedicatedServer)
    {
        return;
    }

    // if ()

    // LookAtInfo
    // TODO: do this with a timer instead?
    // TODO: don't loop seats. Instead cache skel control and seat index pairs to update.
    if (Seats[0].SeatPawn != None)
    {
        if (Seats[0].SeatPawn.Controller != None)
        {
            Seats[0].SeatPawn.Controller.GetPlayerViewPoint(V, R);
        }
    }

    // Debug: if no player in vehicle -> look at closest player.
    NumControllers = NumPassengers();
    if (NumControllers == 0)
    {
        GetALocalPlayerController().GetPlayerViewPoint(V, R);
    }
    else
    {
        // Debug: no driver -> look at some human passenger.
        if (!bDriving)
        {
            GetALocalPlayerController().GetPlayerViewPoint(V, R);
        }
    }

    for (SeatIdx = 0; SeatIdx < Seats.Length; ++SeatIdx)
    {
        bSeatHasHuman = False;
        if (Seats[SeatIdx].SeatPawn != None)
        {
            if (Seats[SeatIdx].SeatPawn.Controller != None)
            {
                Seats[SeatIdx].SeatPawn.Controller.GetPlayerViewPoint(V, R);
                bSeatHasHuman = True;
            }
        }

        // TODO: should handle PointAt and LookAt in Proxy/Pawn tick.

        // TODO: world camera to vehicle local vector.
        // VehicleLocalV = V << Rotation;
        // PointAtLoc = PointAtRoot + Normal(VehicleLocalV) * Clamp(PointAtDistance); ???

        // LookAtControlName = Seats[SeatIdx].SeatPositions[SeatPositionIndex(SeatIdx,,true)].LookAtInfo.DefaultLookAtTargetName;
        LookAtControlName = LookAtTargetSkelControlNames[SeatIdx];
        // PointAtControlName = Seats[SeatIdx].SeatPositions[SeatPositionIndex(SeatIdx,,true)].LeftHandIKInfo.DefaultEffectorLocationTargetName;
        PointAtControlName = PointAtTargetSkelControlNames[SeatIdx];

        // Camera has world loc (LookAtLoc) and rot.
        // We want to turn this into PointAtLoc and PointAtRot, limited by
        // PointAtRoot and some distance not yet decided (DebugPointAtDistance)?

        // if (bSeatHasHuman)
        // {
        //     `pmlog("******************************************************");
        //     // TODO: cache this vector offset.
        //     CamToPointAtRoot = Mesh.GetBoneLocation(PointAtRootBoneNames[SeatIdx]) - V;
        //     `pmlog("CamToPointAtRoot        :" @ CamToPointAtRoot);
        // }

        if (NumControllers == 0)
        {
            // V.Z += class'ROPawn'.default.EyeHeight;
        }
        else
        {
            V = V + (Normal(vector(R)) * 5000);
        }

        // if (bSeatHasHuman)
        // {
        //     `pmlog("R                   :" @ R);
        //     `pmlog("RootBone rot (world):" @ QuatToRotator(Mesh.GetBoneQuaternion(PointAtRootBoneNames[SeatIdx], 0)));
        //     `pmlog("RootBone rot (local):" @ QuatToRotator(Mesh.GetBoneQuaternion(PointAtRootBoneNames[SeatIdx], 1)));

        //     // World location based on camera.
        //     PointAtLoc = V;
        //     `pmlog("PointAtLoc (world)  :" @ PointAtLoc);
        //     // Local location based on root bone.
        //     PointAtLoc = V << QuatToRotator(Mesh.GetBoneQuaternion(PointAtRootBoneNames[SeatIdx]));
        //     `pmlog("PointAtLoc (local?) :" @ PointAtLoc);
        //     PointAtLoc = V << R;
        //     `pmlog("PointAtLoc (local?) :" @ PointAtLoc);

        //     PointAtLoc = V - Mesh.GetBoneLocation(PointAtRootBoneNames[SeatIdx]);
        //     `pmlog("PointAtLoc (world?) :" @ PointAtLoc);



        //     PointAtLoc += CamToPointAtRoot; // Move by camera offset.
        //     `pmlog("PointAtLoc (offset) :" @ PointAtLoc);
        //     DrawDebugSphere(PointAtLoc, 4, 4, 0, SeatIdx * 25, SeatIdx * 25);
        //     PointAtLoc = ClampLength(PointAtLoc, DebugPointAtDistance);
        //     `pmlog("PointAtLoc (clamp)  :" @ PointAtLoc);
        //     DrawDebugSphere(PointAtLoc, 4, 4, 255, SeatIdx * 10, SeatIdx * 10);

        //     // TODO: think about this rot.
        //     // PointAtRot = QuatToRotator(QuatFindBetween(
        //     //     Mesh.GetBoneLocation(PointAtRootBoneNames[SeatIdx], 1), // local
        //     //     PointAtLoc
        //     // ));
        //     PointAtRot = rotator(PointAtLoc - Mesh.GetBoneLocation(PointAtRootBoneNames[SeatIdx], 1));
        //     `pmlog("PointAtRot          :" @ PointAtRot);
        // }

        // PointAtLoc.Z -= 5;

        // Human pawn will update their own LookAt bone location!
        if (!bSeatHasHuman && LookAtControlName != '')
        {
            if (Mesh != None)
            {
                LookAtTargetSkelControls[SeatIdx].BoneTranslation = V;
            }
        }

        // if (SeatIdx > 0 && PointAtControlName != '' && bSeatHasHuman)
        // {
        //     PointAtTargetSkelControls[SeatIdx].BoneTranslation = PointAtLoc;
        //     PointAtTargetSkelControls[SeatIdx].BoneRotation = PointAtRot;
        // }

        // DrawDebugSphere(V, 6, 6, 255, SeatIdx * 25, SeatIdx * 25);
        // DrawDebugSphere(PointAtLoc, 4, 4, 0, SeatIdx * 25, SeatIdx * 25);
    }
}

simulated function SetSeatLookAt(int SeatIndex,
    optional const out vector BoneWorldLoc, optional const out rotator BoneWorldRot)
{
    LookAtTargetSkelControls[SeatIndex].BoneTranslation = BoneWorldLoc;
    LookAtTargetSkelControls[SeatIndex].BoneRotation = BoneWorldRot;
}

simulated function bool GetSeatLookAt(int SeatIndex,
    optional out vector out_Location, optional out rotator out_Rotation)
{
    // TODO: need to add more error checking?

    // if (SeatIndex >= 0 && SeatIndex < Seats.Length)
    // {

    // Seats[SeatIndex].SeatPositions[SeatPositionIndex(SeatIndex,,true)].LookAtInfo.DefaultLookAtTargetName,

    // TODO: instead using socket location here, just return LookAtTargetSkelControls[SeatIndex].BoneTranslation?
    return Mesh.GetSocketWorldLocationAndRotation(
        LookAtTargetSkelControlNames[SeatIndex],
        out_Location,
        out_Rotation
    );

    // }

    // return False;
}

simulated function HandleDriverIKAction(byte DAct)
{
    local ROAnimNodeVehicleCrewIK DriverIK;

    `pmlog("DAct                       :" @ DAct);
    `pmlog("DAct (DriverAction)        :" @ DriverAction(DAct));
    `pmlog("DAct (DriverAction_Custom) :" @ DriverAction_Custom(DAct));

    if (WorldInfo.NetMode == NM_DedicatedServer)
    {
        return;
    }

    DriverIK = GetActiveIKNode(0, 1);

    if (DriverIK != None)
    {
        DriverIK.HandleDriverAction(DriverAction(DAct));
    }
}

simulated function PlayGearShift(bool bContinued)
{
    if (WorldInfo.NetMode == NM_DedicatedServer)
    {
        return;
    }

    if (!bContinued)
    {
        HandleDriverIKAction(DAct_ShiftGears);
    }

    // UROVehicleSimTreaded* ROVSim = Cast<UROVehicleSimTreaded>(SimObj);

    // if ( TargetOutputGear < DelayedOutputGear )
    // {
    // 	PlayLocalVehicleSound(ShiftDownSound, Exhaust_FXSocket);
    // }
    // else if( ROVSim && TargetOutputGear != ROVSim->FirstForwardGear )
    // {
    // 	PlayLocalVehicleSound(ShiftUpSound, Exhaust_FXSocket);
    // }
}

event bool DriverLeave(bool bForceLeave)
{
    local bool bLeft;
    local ROPawn CachedDriver;

    CachedDriver = ROPawn(Driver);
    bLeft = Super.DriverLeave(bForceLeave);

    if (bLeft && CachedDriver != None)
    {
        // Preserve momentum.
        CachedDriver.Velocity = Velocity;
    }

    return bLeft;
}

function PassengerLeave(int SeatIndex)
{
    local ROPawn Left;

    Left = ROPawn(Seats[SeatIndex].StoragePawn);

    if (Left != None)
    {
        // Preserve momentum.
        Left.Velocity = Velocity;
    }

    Super.PassengerLeave(SeatIndex);
}

simulated function SetInputs(float InForward, float InStrafe, float InUp)
{
    // local float Speed;

    // Speed = VSize(Velocity);

    // // Never throttle and brake at the same time!
    // if ((Throttle < 0) && (Speed > 5) && (Speed <= SVehicleSimCar(SimObj).StopThreshold))
    // {
    //     Throttle = 0;
    // }
    // else
    // {
    //     Throttle = InForward;
    // }

    Throttle = InForward;
    Rise = -InUp;
    Steering = InStrafe;
}

function bool DriverEnter(Pawn P)
{
    local bool bEntered;

    bEntered = super.DriverEnter(P);
    if (bEntered)
    {
        // TODO: steering wheel continues from "previous" position
        // when entering driver's seat after exiting it while steering
        // wheel was turned. Physics wheels do not match this rotation though.
        // TODO: this doesn't work, figure something else out.
        if (SteeringWheelSkelControl != None)
        {
            SteeringWheelSkelControl.BoneRotation.Pitch = 0;
            SteeringWheelSkelControl.BoneRotation.Yaw = 0;
            SteeringWheelSkelControl.BoneRotation.Roll = 0;
        }
    }

    return bEntered;
}

// NOTE: HELICOPTER.
// function bool DriverEnter(Pawn P)
// {
// 	local ROPlayerReplicationInfo ROPRI;
// 	local ROTeamInfo ROTI;

// 	ROPRI = ROPlayerReplicationInfo(P.Controller.PlayerReplicationInfo);

// 	if( (bTransportHelicopter && !ROPRI.RoleInfo.bIsTransportPilot) || (!bTransportHelicopter && ROPRI.RoleInfo.bIsTransportPilot) )
// 		return false;

// 	if( ROPRI.RoleInfo.bIsPilot && Super.DriverEnter(P) )
// 	{
// 		if( !bEngineOn )
// 			StartUpEngine();

// 		if( IsTimerActive('ShutDownEngine') )
// 			ClearTimer('ShutDownEngine');

// 		if( ROPRI != none )
// 		{
// 			ROPRI.TeamHelicopterArrayIndex = HelicopterArrayIndex;
// 			ROPRI.TeamHelicopterSeatIndex = 0;

// 			ROTI = ROTeamInfo( ROGameReplicationInfo(WorldInfo.GRI).Teams[Team] );

// 			if( ROTI != none )
// 			{
// 				ROTI.TeamHelicopterPilotNames[HelicopterArrayIndex] = ROPRI.PlayerName;
// 			}
// 		}

// 		return true;
// 	}

// 	return false;
// }

// NOTE: HELICOPTER VERSION!
simulated function SitDriver( ROPawn ROP, int SeatIndex )
{
    local ROPlayerController ROPC;
    local Pawn LocalPawn;

    `pmlog("ROP=" $ ROP $ " SeatIndex= " $ SeatIndex);

    super.SitDriver(ROP, SeatIndex);

    // Here we need to find the local PlayerController for either the SeatPawn
    // or the Pawn we're putting in the seat. Have to search a couple different
    // ways, since this code has to run on the server and the client, and the
    // Pawns get possessed in a different order on the client and the server.
    if( Seats[SeatIndex].SeatPawn != none && Seats[SeatIndex].SeatPawn.Driver != none )
    {
        ROPC = ROPlayerController(Seats[SeatIndex].SeatPawn.Driver.Controller);
    }

    // Couldn't find the Controller for the driver, check the seatpawn
    if( ROPC == none && Seats[SeatIndex].SeatPawn != none )
    {
        ROPC = ROPlayerController(Seats[SeatIndex].SeatPawn.Controller);
    }

    // Look at the controller of the incoming pawn's DrivenVehicle,
    // and see if it matches the local playercontroler
    if( ROPC == none )
    {
        if( ROP.DrivenVehicle.Controller != none && ROP.DrivenVehicle.Controller == GetALocalPlayerController() )
        {
            ROPC = ROPlayerController(ROP.DrivenVehicle.Controller);
        }
    }

    // Another check, if we are looking for the controller for the vehicle itself
    // just check and see if the controller for the local playercontroller is set
    // to this vehicle.
    if( ROPC == none && SeatIndex == 0 )
    {
        if( GetALocalPlayerController() != none && GetALocalPlayerController().Pawn == self )
        {
            ROPC = ROPlayerController(GetALocalPlayerController());
        }
    }

    // Final check, if we are looking for the controller for a particular seat
    // just check and see if the controller for the local playercontroller is set
    // to that seat's seatpawn
    if( ROPC == none  )
    {
        LocalPawn = GetALocalPlayerController().Pawn;

        //`log("Local Pawn = "$LocalPawn$" GetALocalPlayerController() = "$GetALocalPlayerController()$" local Pawn Controller = "$LocalPawn.Controller);

        if( GetALocalPlayerController() != none && LocalPawn == Seats[SeatIndex].SeatPawn )
        {
            ROPC = ROPlayerController(GetALocalPlayerController());
        }
    }

    if( ROPC != none && (WorldInfo.NetMode == NM_Standalone || IsLocalPlayerInThisVehicle()) )
    {
        // Force the driver's view rotation to default to forward instead of some arbitrary angle
        ROPC.SetRotation(rot(0,0,0));

        // TODO: Added this because the above statement is not enough.
        // But WHY is it not enough?
        ROPC.ClientSetRotation(rot(0,0,0));

        // Set Interior engine sounds. Exterior sounds are called by ROPawn.StopDriving
        // SetInteriorEngineSound(true);
    }

    if (ROP != none)
    {
        ROP.Mesh.SetAnimTreeTemplate(PassengerAnimTree);
        ROP.HideGear(true);

        if( ROP.CurrentWeaponAttachment != none )
        {
            ROP.PutAwayWeaponAttachment();
        }

        // Set the proxy health to be whatever our pawn had on entry
        if( Role == ROLE_Authority )
        {
            UpdateSeatProxyHealth(GetSeatProxyIndexForSeatIndex(SeatIndex), ROP.Health, false);
        }
    }

    if( WorldInfo.NetMode != NM_DedicatedServer )
    {
        // Display the vehicle interior if a local player is getting into it
        // Check for IsLocalPlayerInThisVehicle shouldn't normally be required, but it prevents a nasty bug when new players
        // connect and briefly think that they control every pawn, leading to invisible heads for all vehicle passengers - Ch!cken
        if ( ROPC != None && LocalPlayer(ROPC.Player) != none && (WorldInfo.NetMode == NM_Standalone || IsLocalPlayerInThisVehicle()) )
        {

            // If our local playcontroller is getting into this seat set up the
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

            SpawnOrReplaceSeatProxy(SeatIndex, ROP, true);
        }
        else if( ROAIController(ROP.Controller) != none && IsLocalPlayerInThisVehicle() )
        {
            SpawnOrReplaceSeatProxy(SeatIndex, ROP, true);
        }
        else
        {
            SpawnOrReplaceSeatProxy(SeatIndex, ROP, false);
        }

        if( (ROPC != none && ROPC.IsLocalPlayerController() && ROPC.IsFirstPersonCamera()) || IsLocalPlayerInThisVehicle() )
        {
            SetVehicleDepthToForeground();
        }
        else
        {
            SetVehicleDepthToWorld();
        }
    }

    if( ROP != none )
    {
        ROP.SetRelativeRotation(Seats[SeatIndex].SeatRotation);
        ROP.SetRelativeLocation(Seats[SeatIndex].SeatOffset);

        // IK update here to force client replication on vehicle entry,
        // otherwise IK doesn't update until position change.
        ROP.UpdateVehicleIK(self, SeatIndex, SeatPositionIndex(SeatIndex,, true));

        // TODO: NEED TO ADD CUSTOM CONTROLLERS IN PROXY TO PAWN?
        // TODO: Need to update custom IK for Pawn too?
        // TODO: Check PMVehicleCrewProxy custom nodes.
    }
}


// NOTE: From ROVehicleHelicopter.
// simulated function SitDriver(ROPawn ROP, int SeatIndex)
// {
//     local ROPlayerController ROPC;

//     `pmlog("ROP=" $ ROP $ " SeatIndex= " $ SeatIndex);

//     super.SitDriver(ROP, SeatIndex);

//     ROPC = ROPlayerController(FindVehicleLocalPlayerController(ROP, SeatIndex));

//     if ((ROPC != none) && ((WorldInfo.NetMode == NM_Standalone) || IsLocalPlayerInThisVehicle()))
//     {
//         // Force the driver's view rotation to default to forward instead of some arbitrary angle
//         ROPC.SetRotation(rot(0,0,0));
//         // TODO: Added this because the above statement is not enough.
//         //       But WHY is it not enough?
//         ROPC.ClientSetRotation(rot(0,0,0));

//         // Set Interior engine sounds. Exterior sounds are called by ROPawn.StopDriving
//         // TODO: HELOSTUFF, CHECK THIS.
//         // SetInteriorEngineSound(true);
//     }

//     if (ROP != none)
//     {
//         ROP.Mesh.SetAnimTreeTemplate(PassengerAnimTree);
//         ROP.HideGear(true);

//         if (ROP.CurrentWeaponAttachment != none)
//         {
//             ROP.PutAwayWeaponAttachment();
//         }

//         // Set the proxy health to be whatever our pawn had on entry
//         if (Role == ROLE_Authority)
//         {
//             UpdateSeatProxyHealth(GetSeatProxyIndexForSeatIndex(SeatIndex), ROP.Health, false);
//         }
//     }

//     if (WorldInfo.NetMode != NM_DedicatedServer)
//     {
//         // Display the vehicle interior if a local player is getting into it
//         // Check for IsLocalPlayerInThisVehicle shouldn't normally be required, but it prevents a nasty bug when new players
//         // connect and briefly think that they control every pawn, leading to invisible heads for all vehicle passengers - Ch!cken
//         if (ROPC != None && LocalPlayer(ROPC.Player) != none && (WorldInfo.NetMode == NM_Standalone || IsLocalPlayerInThisVehicle()))
//         {
//             // If our local PlayerController is getting into this seat set up the
//             // hands and head meshes so we see what we need to see (like our
//             // third person hands, and don't see what we don't (like our own head)
//             if (ROP != None)
//             {
//                 if( ROP.ThirdPersonHeadphonesMeshComponent != none )
//                 {
//                     ROP.ThirdPersonHeadphonesMeshComponent.SetOwnerNoSee(true);
//                 }

//                 if( ROP.ThirdPersonHeadgearMeshComponent != none )
//                 {
//                     ROP.ThirdPersonHeadgearMeshComponent.SetHidden(true);
//                 }

//                 if( ROP.FaceItemMeshComponent != none )
//                 {
//                     ROP.FaceItemMeshComponent.SetHidden(true);
//                 }

//                 if( ROP.FacialHairMeshComponent != none )
//                 {
//                     ROP.FacialHairMeshComponent.SetHidden(true);
//                 }

//                 ROP.ThirdPersonHeadAndArmsMeshComponent.SetSkeletalMesh(ROP.ArmsOnlyMesh);
//                 ROP.ArmsMesh.SetHidden(true);
//             }

//             SpawnOrReplaceSeatProxyCustom(SeatIndex, ROP, true);

//             // TODO: NOT FOR WHEELED VEHICLES.
//             // Since we are entering a tank we want to spawn all the proxies.
//             // SpawnSeatProxiesCustom(SeatIndex, ROP);
//         }
//         else if (ROAIController(ROP.Controller) != none && IsLocalPlayerInThisVehicle())
//         {
//             SpawnOrReplaceSeatProxyCustom(SeatIndex, ROP, true);
//         }
//         else
//         {
//             SpawnOrReplaceSeatProxyCustom(SeatIndex, ROP, false);
//         }

//         if ((ROPC != none && ROPC.IsLocalPlayerController() && ROPC.IsFirstPersonCamera()) || IsLocalPlayerInThisVehicle())
//         {
//             SetVehicleDepthToForeground();
//         }
//         else
//         {
//             SetVehicleDepthToWorld();
//         }
//     }

//     if (ROP != none)
//     {
//        ROP.SetRelativeRotation(Seats[SeatIndex].SeatRotation);
//        ROP.SetRelativeLocation(Seats[SeatIndex].SeatOffset);
//        // IK update here to force client replication on vehicle entry, otherwise IK doesn't update until position change
//        ROP.UpdateVehicleIK(self, SeatIndex, SeatPositionIndex(SeatIndex,, true));
//     }
// }

// NOTE: FROM HELICOPTER!
// Overridden to prevent non-pilots from taking pilot/copilot seats.
// Has to be intercepted before the super class, otherwise the player will exit the vehicle, possibly in midair
function bool ChangeSeat(Controller ControllerToMove, int RequestedSeat)
{
    // local ROPlayerReplicationInfo ROPRI;
    // local int OldSeatIndex;

    // // Don't allow non-pilots into seats that are limited to pilots only
    // if( RequestedSeat == 0 )
    // {
    // 	ROPRI = ROPlayerReplicationInfo(ControllerToMove.PlayerReplicationInfo);
    // 	if( ROPRI != none && ROPRI.RoleInfo != none )
    // 	{
    // 		if( !ROPRI.RoleInfo.bIsPilot )
    // 		{
    // 			ROPlayerController(ControllerToMove).ReceiveLocalizedMessage(class'ROLocalMessageVehicleTwo', ROMSGVEH_RequiresPilot);
    // 			return false;
    // 		}
    // 		else if( (bTransportHelicopter && !ROPRI.RoleInfo.bIsTransportPilot) ||
    // 				(!bTransportHelicopter && ROPRI.RoleInfo.bIsTransportPilot) )
    // 		{
    // 			ROPlayerController(ControllerToMove).ReceiveLocalizedMessage(class'ROLocalMessageVehicleTwo', ROMSGVEH_WrongPilot);
    // 			return false;
    // 		}
    // 	}
    // }
    // else if( RequestedSeat == SeatIndexCopilot )
    // {
    // 	ROPRI = ROPlayerReplicationInfo(ControllerToMove.PlayerReplicationInfo);
    // 	if( bCopilotMustBePilot && ROPRI != none && ROPRI.RoleInfo != none )
    // 	{
    // 		if( !ROPRI.RoleInfo.bIsPilot )
    // 		{
    // 			ROPlayerController(ControllerToMove).ReceiveLocalizedMessage(class'ROLocalMessageVehicleTwo', ROMSGVEH_RequiresPilot);
    // 			return false;
    // 		}
    // 		else if( (bTransportHelicopter && !ROPRI.RoleInfo.bIsTransportPilot) ||
    // 				(!bTransportHelicopter && ROPRI.RoleInfo.bIsTransportPilot) )
    // 		{
    // 			ROPlayerController(ControllerToMove).ReceiveLocalizedMessage(class'ROLocalMessageVehicleTwo', ROMSGVEH_WrongPilot);
    // 			return false;
    // 		}
    // 	}
    // }

    // // Don't allow pilots to change seats while airborne
    // if( !bVehicleOnGround && !bWasChassisTouchingGroundLastTick )
    // {
    // 	OldSeatIndex = GetSeatIndexForController(ControllerToMove);

    // 	if( OldSeatIndex == 0 || OldSeatIndex == SeatIndexCopilot )
    // 	{
    // 		ROPlayerController(ControllerToMove).ReceiveLocalizedMessage(class'ROLocalMessageVehicleTwo', ROMSGVEH_Airborne);
    // 		return false;
    // 	}
    // }

    return super.ChangeSeat(ControllerToMove, RequestedSeat);
}

function EvaluateBackSeatDrivers()
{
    // No backseat driving.
    BackSeatDriverIndex = 0;
    SetBackSeatDriving(false);
}

// NOTE: HELICOPTER.
// Modified so that our proxy copilots do not prevent a reset when all the human players have left the vehicle
function bool Occupied()
{
    local int i;

    if ( Controller != None )
        return true;

    for ( i=0; i<Seats.Length; i++ )
        if ( !Seats[i].bNonEnterable && Seats[i].SeatPawn != none && Seats[i].SeatPawn.Controller != none )
            return true;

    return false;
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

// TODO: using the helicopter version for now!
// Just a wrapper to call our custom version.
// NOTE: SeatIndex here actually refers to SeatProxyIndex.
//       It is assumed they are both equal for every seat position.
//       This is not true for RO2 tank code so be careful when porting stuff.
simulated function SpawnOrReplaceSeatProxy(int SeatIndex, ROPawn ROP, optional bool bInternalVisibility)
{
    local int i;//,j;
    local VehicleCrewProxy CurrentProxyActor;
    local bool bSetMeshRequired;
    local ROMapInfo ROMI;

    `pmlog("Seat(Proxy)Index=" $ SeatIndex $ " ROP=" $ ROP $ " bInternalVisibility="
        $ bInternalVisibility);

    // Don't spawn the seat proxy actors on the dedicated server (at least for now)
    if( WorldInfo == none || WorldInfo.NetMode == NM_DedicatedServer )
    {
        return;
    }

    ROMI = ROMapInfo(WorldInfo.GetMapInfo());

    // Don't create proxy if vehicle is dead to prevent leave bodies in the air after round has finished
    if (IsPendingKill() || bDeadVehicle)
    {
        return;
    }

    for ( i = 0; i < SeatProxies.Length; i++ )
    {
        // Only create a proxy for the seat the player has entered, or any seats where players can never enter
        if( (SeatIndex == i && ROP != none) || Seats[SeatProxies[i].SeatIndex].bNonEnterable )
        {
            bSetMeshRequired = false;

            // Dismemberment causes serious problems in native code if we try to reuse the existing mesh, so destroy it and create a new one instead
            if( SeatProxies[i].ProxyMeshActor != none && SeatProxies[i].ProxyMeshActor.bIsDismembered )
            {
                SeatProxies[i].ProxyMeshActor.Destroy();
                SeatProxies[i].ProxyMeshActor = none;
            }

            if( SeatProxies[i].ProxyMeshActor == none )
            {
                SeatProxies[i].ProxyMeshActor = Spawn(VehicleCrewProxyClass, self);
                SeatProxies[i].ProxyMeshActor.MyVehicle = self;

                if (PMVehicleCrewProxy(SeatProxies[i].ProxyMeshActor) != None)
                {
                    PMVehicleCrewProxy(SeatProxies[i].ProxyMeshActor).MyPMVehicleWheeled = self;
                }

                SeatProxies[i].ProxyMeshActor.SeatProxyIndex = i;

                CurrentProxyActor = SeatProxies[i].ProxyMeshActor;

                SeatProxies[i].TunicMeshType.Characterization = class'ROPawn'.default.PlayerHIKCharacterization;

                CurrentProxyActor.Mesh.SetShadowParent(Mesh);
                CurrentProxyActor.SetLightingChannels(InteriorLightingChannels);
                CurrentProxyActor.SetLightEnvironment(InteriorLightEnvironment);

                CurrentProxyActor.SetCollision( false, false);
                CurrentProxyActor.bCollideWorld = false;
                CurrentProxyActor.SetBase(none);
                CurrentProxyActor.SetHardAttach(true);
                CurrentProxyActor.SetLocation( Location );
                CurrentProxyActor.SetPhysics( PHYS_None );
                CurrentProxyActor.SetBase( Self, , Mesh, Seats[SeatProxies[i].SeatIndex].SeatBone);

                CurrentProxyActor.SetRelativeLocation( Seats[SeatProxies[i].SeatIndex].SeatOffset );
                CurrentProxyActor.SetRelativeRotation( Seats[SeatProxies[i].SeatIndex].SeatRotation );

                bSetMeshRequired = true;
            }
            else
            {
                CurrentProxyActor = SeatProxies[i].ProxyMeshActor;
            }

            if(CurrentProxyActor != none)
            {
                CurrentProxyActor.bExposedToRain = (ROMI != none && ROMI.RainStrength != RAIN_None) && SeatProxies[i].bExposedToRain;
            }

            // Create the proxy mesh.
            if (!Seats[SeatProxies[i].SeatIndex].bNonEnterable) // Enterable seat.
            {
                CurrentProxyActor.ReplaceProxyMeshWithPawn(ROP);
            }
            else if (bSetMeshRequired)
            {
                CurrentProxyActor.CreateProxyMesh(SeatProxies[i]);
            }

            // Override the animation set
            if ( SeatProxyAnimSet != None )
            {
                CurrentProxyActor.Mesh.AnimSets[0] = SeatProxyAnimSet;
            }

            if (PassengerAnimTree != None)
            {
                // TODO: this should be good here?
                CurrentProxyActor.Mesh.SetAnimTreeTemplate(PassengerAnimTree);
            }

            if( bInternalVisibility )
            {
                SetSeatProxyVisibilityInterior();
            }
            else
            {
                SetSeatProxyVisibilityExterior();
            }

            // Seat is enterable.
            if( !Seats[SeatProxies[i].SeatIndex].bNonEnterable )
            {
                CurrentProxyActor.HideMesh(true);
            }
            else
            {
                CurrentProxyActor.UpdateVehicleIK(self, SeatProxies[i].SeatIndex, SeatProxies[i].PositionIndex);
                if( SeatProxies[i].Health > 0 )
                {
                    ChangeCrewCollision(true, SeatProxies[i].SeatIndex);
                }
            }
        }
    }
}

// TODO: NOT FOR WHEELED!
// // TODO: Try to simplify this logic.
// // NOTE: From ROVehicleHelicopter with some heavy modifications.
// // NOTE: Only use bForceSetVisible to make seat proxies for non-local pawns visible!
// /**
//  * Spawn or update a single proxy (or multiple, depending on the boolean flags)
//  * for playing death animations on. Match the outfit to that of the Pawn in the same seat.
//  *
//  * @param SeatIndex                 The pawn's SeatIndex. NOTE: This is actually SeatProxyIndex.
//  * @param ROP                       The pawn in this SeatIndex.
//  * @param bInternalVisibility       Set visibility to interior for the seat proxy or proxies handled.
//  * @param bForceCreateProxy         If set, always loop through all SeatProxies (unless overridden by bOnlySeatIndex).
//  * @param bForceSetVisible          If set, force seat proxy visible in this SeatIndex.
//  * @param bOnlySeatIndex            If set, only handle this seat index.
//  */
// simulated function SpawnOrReplaceSeatProxyCustom(
//     int SeatIndex,
//     ROPawn ROP,
//     optional bool bInternalVisibility = false,
//     optional bool bForceCreateProxy = false,
//     optional bool bForceSetVisible = false,
//     optional bool bOnlySeatIndex = false)
// {
//     local int i;
//     local VehicleCrewProxy CurrentProxyActor;
//     local ROMapInfo ROMI;
//     local bool bSetMeshRequired;
//     local bool bPlayerEnterableSeat;
//     local bool bIsThisPawnsSeat;

//     // Don't spawn the seat proxy actors on the dedicated server (at least for now).
//     if (WorldInfo == none || WorldInfo.NetMode == NM_DedicatedServer)
//     {
//         return;
//     }

//     `pmlog("SeatIndex=" $ SeatIndex $ " ROP=" $ ROP $ " bInternalVisibility="
//         $ bInternalVisibility $ " bForceCreateProxy=" $ bForceCreateProxy $ " bForceSetVisible="
//         $ bForceSetVisible $ " bOnlySeatIndex=" $ bOnlySeatIndex);

//     // `pmlog(GetScriptTrace());

//     // Don't create proxy if vehicle is dead to prevent leave bodies in the air after round has finished.
//     if (IsPendingKill() || bDeadVehicle)
//     {
//         return;
//     }

//     ROMI = ROMapInfo(WorldInfo.GetMapInfo());

//     for (i = 0; i < SeatProxies.Length; i++)
//     {
//         bPlayerEnterableSeat = !Seats[SeatProxies[i].SeatIndex].bNonEnterable;
//         bIsThisPawnsSeat = (SeatIndex == i);

//         // bOnlySeatIndex is higher priority than other checks.
//         if (bOnlySeatIndex && !bIsThisPawnsSeat)
//         {
//             continue;
//         }

//         // Only create a proxy for the seat the player has entered, or any seats where players can never enter.
//         // OR if bForceCreateProxy is set.
//         // OR if bForceSetVisible is set and it's this pawn's seat.
//         if (bForceCreateProxy || (bIsThisPawnsSeat && (ROP != none)) || !bPlayerEnterableSeat || (bForceSetVisible && bIsThisPawnsSeat))
//         {
//             bSetMeshRequired = false;

//             // Dismemberment causes serious problems in native code if we try to reuse the existing mesh, so destroy it and create a new one instead.
//             if (SeatProxies[i].ProxyMeshActor != none && SeatProxies[i].ProxyMeshActor.bIsDismembered)
//             {
//                 SeatProxies[i].ProxyMeshActor.Destroy();
//                 SeatProxies[i].ProxyMeshActor = none;
//             }

//             if (SeatProxies[i].ProxyMeshActor == none)
//             {
//                 SeatProxies[i].ProxyMeshActor = Spawn(VehicleCrewProxyClass, self);
//                 SeatProxies[i].ProxyMeshActor.MyVehicle = self;
//                 SeatProxies[i].ProxyMeshActor.SeatProxyIndex = i;

//                 CurrentProxyActor = SeatProxies[i].ProxyMeshActor;

//                 SeatProxies[i].TunicMeshType.Characterization = class'ROPawn'.default.PlayerHIKCharacterization;

//                 CurrentProxyActor.Mesh.SetShadowParent(Mesh);
//                 CurrentProxyActor.SetLightingChannels(InteriorLightingChannels);
//                 CurrentProxyActor.SetLightEnvironment(InteriorLightEnvironment);

//                 CurrentProxyActor.SetCollision(false, false);
//                 CurrentProxyActor.bCollideWorld = false;
//                 CurrentProxyActor.SetBase(none);
//                 CurrentProxyActor.SetHardAttach(true);
//                 CurrentProxyActor.SetLocation(Location);
//                 CurrentProxyActor.SetPhysics(PHYS_None);
//                 CurrentProxyActor.SetBase(Self, , Mesh, Seats[SeatProxies[i].SeatIndex].SeatBone);

//                 CurrentProxyActor.SetRelativeLocation(Seats[SeatProxies[i].SeatIndex].SeatOffset);
//                 CurrentProxyActor.SetRelativeRotation(Seats[SeatProxies[i].SeatIndex].SeatRotation);

//                 bSetMeshRequired = true;
//             }
//             else
//             {
//                 CurrentProxyActor = SeatProxies[i].ProxyMeshActor;
//             }

//             // TODO: this check is not needed.
//             if (CurrentProxyActor != none)
//             {
//                 CurrentProxyActor.bExposedToRain = (
//                     ROMI != none && ROMI.RainStrength != RAIN_None) && SeatProxies[i].bExposedToRain;
//             }

//             // Create the proxy mesh for player-enterable seat from the Pawn.
//             // TODO: if we can move into loader position we may want to rethink this logic.
//             if (bPlayerEnterableSeat && (ROP != None) && bIsThisPawnsSeat)
//             {
//                 CurrentProxyActor.ReplaceProxyMeshWithPawn(ROP);
//             }
//             // Create it from the SeatProxy's mesh info (usually the default mesh).
//             else if (bSetMeshRequired)
//             {
//                 CurrentProxyActor.CreateProxyMesh(SeatProxies[i]);
//             }

//             // Override the animation set.
//             if (SeatProxyAnimSet != None)
//             {
//                 CurrentProxyActor.Mesh.AnimSets[0] = SeatProxyAnimSet;
//             }

//             if (bInternalVisibility)
//             {
//                 SetSeatProxyVisibilityInteriorByIndex(i);
//             }
//             else
//             {
//                 SetSeatProxyVisibilityExteriorByIndex(i);
//             }

//             // bForceSetVisible means we want to force visibility for *this pawn's* seat.
//             if (bForceSetVisible && bIsThisPawnsSeat)
//             {
//                 SetProxyMeshVisibility(true, CurrentProxyActor, i, true);
//             }
//             // Hide player-enterable seat proxies or when force-creating them. They will be unhidden when needed.
//             // NOTE: Tank should always show all living non-local-player proxies.
//             else if (bPlayerEnterableSeat || bForceCreateProxy)
//             {
//                 SetProxyMeshVisibility(false, CurrentProxyActor, i, true);
//             }
//             // Non-enterable (loaders, etc.). Always visible.
//             // TODO: If we should be able to enter loader's seat, we need to re-think this logic.
//             else if (!bPlayerEnterableSeat)
//             {
//                 SetProxyMeshVisibility(true, CurrentProxyActor, i, true);
//             }
//             // Fallback option is to hide. Probably shouldn't get there though.
//             else
//             {
//                 SetProxyMeshVisibility(false, CurrentProxyActor, i, true);
//             }
//         }
//     }
// }

// TODO: NOT FOR WHEELED!
// TODO: Should use this in every place that changes proxy actor visibility to update collision too.
//       We don't use crew collision for anything in tanks yet, but we might want to do that later on.
// simulated function SetProxyMeshVisibility(bool bSetVisible, VehicleCrewProxy ProxyActor, int SeatProxyIndex,
//     optional bool bEnableCrewCollision = True)
// {
//     `pmlog("bSetVisible=" $ bSetVisible $ " ProxyActor=" $ ProxyActor $ " SeatProxyIndex="
//         $ SeatProxyIndex $ " bEnableCrewCollision=" $ bEnableCrewCollision);

//     if (ProxyActor != None)
//     {
//         ProxyActor.HideMesh(!bSetVisible);
//         ProxyActor.UpdateVehicleIK(self, SeatProxies[SeatProxyIndex].SeatIndex, SeatProxies[SeatProxyIndex].PositionIndex);
//     }

//     if ((SeatProxies[SeatProxyIndex].Health <= 0) && bEnableCrewCollision)
//     {
//         bEnableCrewCollision = False;
//         `pmlog("overriding bEnableCrewCollision to False, since SeatProxy is dead!");
//     }
//     ChangeCrewCollision(bEnableCrewCollision, SeatProxies[SeatProxyIndex].SeatIndex);
// }

// TODO: NOT FOR WHEELED!
// // NOTE: Overridden to use SpawnOrReplaceSeatProxyCustom().
// // TODO: Is this needed? Looks like we're doing all this twice now?
// /**
//  * Spawn the SeatProxy ProxyMeshActors on the client for SeatProxies you could
//  * possibly see in third person.
//  */
// simulated function SpawnExternallyVisibleSeatProxies()
// {
//     local int i;
//     local int j;
//     local bool bCanBecomeVisible;

//     `pmlog("spawning externally visible seat proxies...");

//     // Don't spawn the seat proxy actors on the dedicated server (at least for now).
//     if (WorldInfo.NetMode == NM_DedicatedServer)
//     {
//         return;
//     }

//     for (i = 0; i < SeatProxies.Length; i++)
//     {
//         bCanBecomeVisible = false;

//         for (j = 0; j < Seats[SeatProxies[i].SeatIndex].SeatPositions.Length; j++)
//         {
//             if ((Seats[SeatProxies[i].SeatIndex].SeatPositions[j].SeatProxyIndex == i)
//                 && Seats[SeatProxies[i].SeatIndex].SeatPositions[j].bDriverVisible)
//             {
//                 bCanBecomeVisible = true;
//                 break;
//             }
//         }

//         `pmlog("SeatProxies[" $ i $ "]: bCanBecomeVisible=" $ bCanBecomeVisible);

//         if ((SeatProxies[i].ProxyMeshActor == None) && bCanBecomeVisible)
//         {
//             SpawnOrReplaceSeatProxyCustom(
//                 i,                                    // SeatIndex
//                 None,                                 // ROP
//                 False,                                // bInternalVisibility
//                 True,                                 // bForceCreateProxy
//                 False,                                // bForceSetVisible
//                 True                                  // bOnlySeatIndex
//             );
//         }
//     }
// }

// // NOTE: From ROVehicleHelicopter.
// // TODO: check hide/unhide logic again. Differs from ROVehicle.
// /**
//  * Set the SeatProxies visibility to the foreground depth group
//  *
//  * @param   DriverIndex         - if set denotes the local player's SeatIndex
//  */
// simulated function SetSeatProxyVisibilityInterior(int DriverIndex =-1)
// {
//     local int i;

//     `pmlog("DriverIndex=" $ DriverIndex);
//     // `pmlog(GetScriptTrace());

//     for (i = 0; i < SeatProxies.Length; i++)
//     {
//         `pmlog("Before logic : SeatProxies[" $ i $ "] HiddenGame=" $ SeatProxies[i].ProxyMeshActor.Mesh.HiddenGame,
//             SeatProxies[i].ProxyMeshActor != None);

//         if (SeatProxies[i].ProxyMeshActor != none)
//         {
//             SeatProxies[i].ProxyMeshActor.SetVisibilityToInterior();
//             SeatProxies[i].ProxyMeshActor.SetLightingChannels(InteriorLightingChannels);
//             SeatProxies[i].ProxyMeshActor.SetLightEnvironment(InteriorLightEnvironment);
//         }

//         // Hide seat proxy for the driver.
//         if ((DriverIndex >= 0) && (GetSeatProxyForSeatIndex(DriverIndex) == SeatProxies[i]))
//         {
//             if (GetSeatProxyForSeatIndex(DriverIndex).ProxyMeshActor != none)
//             {
//                 GetSeatProxyForSeatIndex(DriverIndex).ProxyMeshActor.HideMesh(true);
//                 `pmlog("    Hiding proxy for seat" @ SeatProxies[i].SeatIndex);
//             }
//         }
//         // Hide local proxy seat (even if DriverIndex is unset).
//         // TODO: this check doesn't work as expected!
//         else if (IsLocalSeatProxy(i))
//         {
//             SeatProxies[i].ProxyMeshActor.HideMesh(true);
//             `pmlog("    Hiding proxy for local seat" @ SeatProxies[i].SeatIndex);
//         }
//         else
//         {
//             /*
//             // Unhide this mesh if no pawn is sitting here and the proxy is dead, or if it's a non-enterable seat.
//             if (
//                 (((SeatProxies[i].Health <= 0) && (DriverIndex < 0)) || (GetDriverForSeatIndex(SeatProxies[i].SeatIndex) == none)
//                 ) || Seats[SeatProxies[i].SeatIndex].bNonEnterable)
//             */
//             // NOTE: Actually, since this is a tank, we want to show all non-local proxies.
//             // if (True)
//             // {
//                 // Unhide the mesh for the interior seat proxies.
//                 if (SeatProxies[i].ProxyMeshActor != none)
//                 {
//                     SeatProxies[i].ProxyMeshActor.HideMesh(false);
//                     // `pmlog("Unhiding proxy for seat" @ SeatProxies[i].SeatIndex @ "as health is" @ SeatProxies[i].Health);
//                     `pmlog("    Unhiding proxy for seat" @ SeatProxies[i].SeatIndex);
//                 }
//             // }
//         }

//         `pmlog("After logic  : SeatProxies[" $ i $ "] HiddenGame=" $ SeatProxies[i].ProxyMeshActor.Mesh.HiddenGame,
//             SeatProxies[i].ProxyMeshActor != None);
//     }
// }

// // NOTE: From ROVehicleHelicopter.
// // TODO: check hide/unhide logic again. Differs from ROVehicle.
// /**
//  * Set the SeatProxies visibility to the world depth group if they can
//  * become visible.
//  *
//  * @param   DriverIndex         - If set denotes the local player's SeatIndex
//  */
// simulated function SetSeatProxyVisibilityExterior(optional int DriverIndex =-1)
// {
//     local int i,j;
//     local bool bCanBecomeVisible;

//     `pmlog("DriverIndex=" $ DriverIndex);

//     for (i = 0; i < SeatProxies.Length; i++)
//     {
//         `pmlog("Before logic : SeatProxies[" $ i $ "] HiddenGame=" $ SeatProxies[i].ProxyMeshActor.Mesh.HiddenGame,
//             SeatProxies[i].ProxyMeshActor != None);

//         bCanBecomeVisible = false;

//         for (j = 0; j < Seats[SeatProxies[i].SeatIndex].SeatPositions.Length; j++)
//         {
//             if ((Seats[SeatProxies[i].SeatIndex].SeatPositions[j].SeatProxyIndex == i)
//                 && Seats[SeatProxies[i].SeatIndex].SeatPositions[j].bDriverVisible)
//             {
//                 bCanBecomeVisible = true;
//                 break;
//             }
//         }

//         if (SeatProxies[i].ProxyMeshActor != none)
//         {
//             SeatProxies[i].ProxyMeshActor.SetVisibilityToExterior();
//             SeatProxies[i].ProxyMeshActor.SetLightingChannels(ExteriorLightingChannels);
//             SeatProxies[i].ProxyMeshActor.SetLightEnvironment(LightEnvironment);

//             // Don't display the proxy mesh for the driver.
//             if ((DriverIndex >= 0) && (GetSeatProxyForSeatIndex(DriverIndex) == SeatProxies[i]))
//             {
//                 GetSeatProxyForSeatIndex(DriverIndex).ProxyMeshActor.HideMesh(true);
//                 `pmlog("Hiding proxy for seat" @ SeatProxies[i].SeatIndex);
//             }
//             else if (IsLocalSeatProxy(i))
//             {
//                 SeatProxies[i].ProxyMeshActor.HideMesh(true);
//                 `pmlog("Hiding proxy for local seat" @ SeatProxies[i].SeatIndex);
//             }
//             else
//             {
//                 // Display meshes for third person proxies that could be seen.
//                 // Since this is a tank, we want to show all non-local proxies.
//                 if (bCanBecomeVisible
//                     /*
//                     && (
//                         ((SeatProxies[i].Health <= 0) && (DriverIndex < 0))
//                         || (GetDriverForSeatIndex(SeatProxies[i].SeatIndex) == none)
//                         || Seats[SeatProxies[i].SeatIndex].bNonEnterable)
//                     */
//                     )
//                 {
//                     // Unhide the mesh for the exterior seatproxies.
//                     SeatProxies[i].ProxyMeshActor.HideMesh(false);
//                     `pmlog("Unhiding proxy for seat" @ SeatProxies[i].SeatIndex);
//                 }
//             }
//         }

//         `pmlog("After logic  : SeatProxies[" $ i $ "] HiddenGame=" $ SeatProxies[i].ProxyMeshActor.Mesh.HiddenGame,
//             SeatProxies[i].ProxyMeshActor != None);
//     }
// }

// TODO: FROM HELICOPTER!
/**
 * Set the SeatProxies visibility to the foregraound depth group
 * Now only unhide the proxy if it's dead
 *
 * @param	DriverIndex			- if set denotes the local player's SeatIndex
 */
simulated function SetSeatProxyVisibilityInterior(int DriverIndex =-1)
{
    local int i;

    `pmlog("DriverIndex=" $ DriverIndex);

    for ( i = 0; i < SeatProxies.Length; i++ )
    {
        if( SeatProxies[i].ProxyMeshActor != none )
        {
            SeatProxies[i].ProxyMeshActor.SetVisibilityToInterior();
            SeatProxies[i].ProxyMeshActor.SetLightingChannels(InteriorLightingChannels);
            SeatProxies[i].ProxyMeshActor.SetLightEnvironment(InteriorLightEnvironment);
        }

        if( DriverIndex >= 0 && GetSeatProxyForSeatIndex(DriverIndex) == SeatProxies[i] )
        {
            if ( GetSeatProxyForSeatIndex(DriverIndex).ProxyMeshActor != none )
            {
                GetSeatProxyForSeatIndex(DriverIndex).ProxyMeshActor.HideMesh(true);
            }
        }
        else
        {
            // Unhide this mesh if no pawn is sitting here and the proxy is dead, or if it's a non-enterable seat
            if( (SeatProxies[i].Health <= 0 && (DriverIndex < 0 ||
                GetDriverForSeatIndex(SeatProxies[i].SeatIndex) == none )) || Seats[SeatProxies[i].SeatIndex].bNonEnterable )
            {
                // Unhide the mesh for the interior seatproxies
                if( SeatProxies[i].ProxyMeshActor != none )
                {
                    SeatProxies[i].ProxyMeshActor.HideMesh(false);
                //	`log("Unhiding proxy for seat"@SeatProxies[i].SeatIndex@"as health is"@SeatProxies[i].Health);
                }
            }
        }
    }
}

// TODO: FROM HELICOPTER!
/**
 * Set the SeatProxies visibility to the world depth group if they can
 * become visible.
 * Now only unhide them if the proxy is dead
 *
 * @param	DriverIndex			- If set denotes the local player's SeatIndex
 */
simulated function SetSeatProxyVisibilityExterior(optional int DriverIndex =-1)
{
    local int i,j;
    local bool bCanBecomeVisible;

    `pmlog("DriverIndex=" $ DriverIndex);

    for ( i = 0; i < SeatProxies.Length; i++ )
    {
        bCanBecomeVisible = false;

        for ( j = 0; j < Seats[SeatProxies[i].SeatIndex].SeatPositions.Length; j++ )
        {
            if( Seats[SeatProxies[i].SeatIndex].SeatPositions[j].SeatProxyIndex == i &&
                Seats[SeatProxies[i].SeatIndex].SeatPositions[j].bDriverVisible )
            {
                bCanBecomeVisible = true;
                break;
            }
        }

        if( SeatProxies[i].ProxyMeshActor != none )
        {
            SeatProxies[i].ProxyMeshActor.SetVisibilityToExterior();
            SeatProxies[i].ProxyMeshActor.SetLightingChannels(ExteriorLightingChannels);
            SeatProxies[i].ProxyMeshActor.SetLightEnvironment(LightEnvironment);

            // Don't display the proxy mesh for the driver
            if( DriverIndex >= 0 && GetSeatProxyForSeatIndex(DriverIndex) == SeatProxies[i] )
            {
                GetSeatProxyForSeatIndex(DriverIndex).ProxyMeshActor.HideMesh(true);
            }
            else
            {
                // Display meshes for third person proxies that could be seen
                if( bCanBecomeVisible && (SeatProxies[i].Health <= 0 && (DriverIndex < 0 ||
                    GetDriverForSeatIndex(SeatProxies[i].SeatIndex) == none )) || Seats[SeatProxies[i].SeatIndex].bNonEnterable )
                {
                    // Unhide the mesh for the exterior seatproxies
                    SeatProxies[i].ProxyMeshActor.HideMesh(false);
                }
            }
        }
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
                    SpawnOrReplaceSeatProxy(ProxySeatIdx, ROPawn(Seats[ProxySeatIdx].StoragePawn),
                        IsLocalPlayerInThisVehicle());

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
// TODO: USING HELICOPTER VERSION FOR NOW!
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
// simulated function HandleSeatTransition(ROPawn DriverPawn, int NewSeatIndex, int OldSeatIndex, bool bInstantTransition)
// {
//     `pmlog("DriverPawn=" $ DriverPawn $ " NewSeatIndex=" $ NewSeatIndex $ " OldSeatIndex="
//         $ OldSeatIndex $ " bInstantTransition=" $ bInstantTransition);

//     if (bInstantTransition && (GetSeatProxyForSeatIndex(NewSeatIndex).Health <= 0))
//     {
//         `pmlog("!!!!!!!!!!!!!!!!!!!!! WARNING: INSTANT TRANSITION TO DEAD PROXY, HOW DID WE GET HERE?");
//         `pmlog(GetScriptTrace());
//     }

//     LogSeatProxyStates(self $ "_" $ GetFuncName() $ "(): before");

//     super.HandleSeatTransition(DriverPawn, NewSeatIndex, OldSeatIndex, bInstantTransition);

//     // Non-animated transition.
//     if (bInstantTransition)
//     {
//         // Copied from ROVehicle.HandleSeatTransition, adds new positions for transports.
//         // We don't actually use this functionality on transports currently, but it's left to handle potential mod vehicles
//         if( Role == ROLE_Authority )
//         {
//             if( OldSeatIndex == 4 )
//             {
//                 SetTimer(1.0, false, 'HandlePostInstantSeatTransFour');
//             }
//             else if( OldSeatIndex == 5 )
//             {
//                 SetTimer(1.0, false, 'HandlePostInstantSeatTransFive');
//             }
//             else if( OldSeatIndex == 6 )
//             {
//                 SetTimer(1.0, false, 'HandlePostInstantSeatTransSix');
//             }
//             else if( OldSeatIndex == 7 )
//             {
//                 SetTimer(1.0, false, 'HandlePostInstantSeatTransSeven');
//             }
//             else if( OldSeatIndex == 8 )
//             {
//                 SetTimer(1.0, false, 'HandlePostInstantSeatTransEight');
//             }
//             else if( OldSeatIndex == 9 )
//             {
//                 SetTimer(1.0, false, 'HandlePostInstantSeatTransNine');
//             }
//         }

//         // Set new seat proxy from the moving pawn.
//         // TODO: should we call this here or later in this branch??
//         SpawnOrReplaceSeatProxyCustom(
//             NewSeatIndex,                                  // SeatIndex
//             DriverPawn,                                    // ROP
//             IsLocalPlayerInThisVehicle(),                  // bInternalVisibility
//             False,                                         // bForceCreateProxy
//             False,                                         // bForceSetVisible
//             True                                           // bOnlySeatIndex
//         );

//         // Set old seat proxy from the StoragePawn (or default mesh if StoragePawn is null).
//         // Set bForceCreateProxy to make sure we do it even if StoragePawn is null.
//         SpawnOrReplaceSeatProxyCustom(
//             OldSeatIndex,                                   // SeatIndex
//             ROPawn(Seats[OldSeatIndex].StoragePawn),        // ROP
//             IsLocalPlayerInThisVehicle(),                   // bInternalVisibility
//             True,                                           // bForceCreateProxy
//             False,                                          // bForceSetVisible
//             True                                            // bOnlySeatIndex
//         );

//         // Turn off or on the OLD proxy mesh depending upon the health of the Proxy.
//         // TODO: why is ROVehicleTank checking for NetMode here but not for the other hide/unhide calls?
//         //       Is this SP only logic on purpose?
//         if ((WorldInfo.NetMode != NM_DedicatedServer) && (GetSeatProxyForSeatIndex(OldSeatIndex).ProxyMeshActor != none))
//         {
//             `pmlog("Enter (WorldInfo.NetMode != NM_DedicatedServer) branch, NetMode=" $ WorldInfo.NetMode);

//             // OLD proxy alive.
//             if (GetSeatProxyForSeatIndex(OldSeatIndex).Health > 0)
//             {
//                 // Old proxy has bDriverVisible and local player in the vic.
//                 if (Seats[OldSeatIndex].SeatPositions[GetSeatProxyForSeatIndex(OldSeatIndex).PositionIndex].bDriverVisible || IsLocalPlayerInThisVehicle())
//                 {
//                     GetSeatProxyForSeatIndex(OldSeatIndex).ProxyMeshActor.HideMesh(false);
//                     `pmlog("SeatProxies[" $ OldSeatIndex $ "] Setting HiddenGame to false because proxy is alive, HiddenGame = "
//                         $ GetSeatProxyForSeatIndex(OldSeatIndex).ProxyMeshActor.Mesh.HiddenGame);

//                     // Update and re-activate IK for the OLD Proxy Mesh...
//                     GetSeatProxyForSeatIndex(OldSeatIndex).ProxyMeshActor.UpdateVehicleIK(self, OldSeatIndex, SeatPositionIndex(OldSeatIndex,,true));
//                 }
//             }
//             // OLD proxy is dead and this is an instant transition.
//             else
//             {
//                 // Seat no longer enterable -> show proxy even if it's dead.
//                 if (Seats[OldSeatIndex].bNonEnterable)
//                 {
//                     GetSeatProxyForSeatIndex(OldSeatIndex).ProxyMeshActor.HideMesh(false);
//                     `pmlog("SeatProxies[" $ OldSeatIndex $ "] Setting HiddenGame to false because proxy is non-enterable, HiddenGame = "
//                         $ SeatProxies[OldSeatIndex].ProxyMeshActor.Mesh.HiddenGame);
//                 }
//                 // We transitioned instantly out of a dead seat. How did this happen? Should probably leave old proxy visible?
//                 else
//                 {
//                     GetSeatProxyForSeatIndex(OldSeatIndex).ProxyMeshActor.HideMesh(true);
//                     `pmlog("SeatProxies[" $ OldSeatIndex $ "] Setting HiddenGame to true because proxy's Health is 0, HiddenGame = "
//                         $ SeatProxies[OldSeatIndex].ProxyMeshActor.Mesh.HiddenGame);
//                 }
//             }
//         }

//         // TODO: This is already called in SpawnOrReplaceSeatProxyCustom() for bInstantTransition...
//         // Update the driver IK.
//         // if (DriverPawn != none)
//         // {
//         //     DriverPawn.UpdateVehicleIK(self, NewSeatIndex, SeatPositionIndex(NewSeatIndex,,true));
//         // }
//     }

//     // NOTE: Combined From ROVehicleTank and ROVehicleHelicopter.
//     // Health follows the player moving if they animated transition out of a seat.
//     if (Role == ROLE_Authority)
//     {
//         // Instant transition -> health follows the player.
//         if (bInstantTransition)
//         {
//             UpdateSeatProxyHealth(GetSeatProxyIndexForSeatIndex(NewSeatIndex), GetSeatProxyForSeatIndex(OldSeatIndex).Health, true);
//             `pmlog("Old Seat Health = " $ GetSeatProxyForSeatIndex(OldSeatIndex).Health);
//             `pmlog("New Seat Health = " $ GetSeatProxyForSeatIndex(NewSeatIndex).Health);
//         }
//         // Animated transition, old proxy is dead -> seat health to 0 (?).
//         else
//         {
//             UpdateSeatProxyHealth(GetSeatProxyIndexForSeatIndex(NewSeatIndex), GetSeatProxyForSeatIndex(OldSeatIndex).Health, true);
//             UpdateSeatProxyHealth(GetSeatProxyIndexForSeatIndex(OldSeatIndex), 0, true);
//             `pmlog("Old Seat Health = " $ GetSeatProxyForSeatIndex(OldSeatIndex).Health);
//             `pmlog("New Seat Health = " $ GetSeatProxyForSeatIndex(NewSeatIndex).Health);
//         }
//     }

//     // NOTE: Combined From ROVehicleTank and ROVehicleHelicopter.
//     if (GetSeatProxyForSeatIndex(OldSeatIndex).ProxyMeshActor != none)
//     {
//         // Animated transition -> hide old seat proxy. NOTE: we're only doing animated transitions
//         // if the target seat is empty/dead and we are moving out of our position to replace that new seat...
//         if (!bInstantTransition)
//         {
//             GetSeatProxyForSeatIndex(OldSeatIndex).ProxyMeshActor.HideMesh(true);
//             `pmlog("SeatProxies[" $ OldSeatIndex $ "] Setting HiddenGame to true because transition was animated, HiddenGame = "
//                     $ SeatProxies[OldSeatIndex].ProxyMeshActor.Mesh.HiddenGame);
//         }
//         // Instant transition -> check health and enterability.
//         // NOTE: This should be covered already in the first if(bInstantTransition) branch for SP... Or is it?
//         else
//         {
//             // Old seat is non-enterable -> always show proxy (ignore health).
//             // TODO: is this even possible for tanks? Seats' bNonEnterable values shouldn't change for tanks...
//             //       This branch would happen if we move out of loader's position (which we shouldn't be able
//             //       to enter anyway, in the first place).
//             if (Seats[OldSeatIndex].bNonEnterable)
//             {
//                 GetSeatProxyForSeatIndex(OldSeatIndex).ProxyMeshActor.HideMesh(false);
//                 `pmlog("SeatProxies[" $ OldSeatIndex $ "] Setting HiddenGame to false because proxy is non-enterable, HiddenGame = "
//                     $ SeatProxies[OldSeatIndex].ProxyMeshActor.Mesh.HiddenGame);
//             }
//             // TODO: Need to think about this. If we move out of a dead position, the OLD proxy should be hidden,
//             //       since the only way we got there was if the proxy was dead before we move into the position,
//             //       so we should leave it in dead state after we move away.
//             //       If the OLD proxy is alive, that means we are doing instant transitions and it should be left visible.
//             // Conclusion: lots of convoluted logic (and unnecessary) checks in this function for scenarios that shouldn't happen anyway...
//             else
//             {
//                 // Old seat proxy is alive -> show proxy.
//                 if (GetSeatProxyForSeatIndex(OldSeatIndex).Health > 0)
//                 {
//                     GetSeatProxyForSeatIndex(OldSeatIndex).ProxyMeshActor.HideMesh(false);
//                     `pmlog("SeatProxies[" $ OldSeatIndex $ "] Setting HiddenGame to false because proxy alive, HiddenGame = "
//                         $ SeatProxies[OldSeatIndex].ProxyMeshActor.Mesh.HiddenGame);
//                 }
//                 // Old seat proxy is dead -> hide it. How did we move out of a dead proxy instantly?
//                 else
//                 {
//                     GetSeatProxyForSeatIndex(OldSeatIndex).ProxyMeshActor.HideMesh(true);
//                     `pmlog("SeatProxies[" $ OldSeatIndex $ "] Setting HiddenGame to true because proxy is dead, HiddenGame = "
//                         $ SeatProxies[OldSeatIndex].ProxyMeshActor.Mesh.HiddenGame);
//                 }
//             }
//         }
//     }

//     // NOTE: for animated transitions, SpawnOrReplaceSeatProxyCustom is called in FinishTransition,
//     //       which is triggered by a timer, individually in each vehicle's subclass code.

//     LogSeatProxyStates(self $ "_" $ GetFuncName() $ "(): after");
// }

/**
 * Called when a passenger enters the vehicle
 *
 * @param P				The Pawn entering the vehicle
 * @param SeatIndex		The seat where he is to sit
 */
function bool PassengerEnter(Pawn P, int SeatIndex)
{
    local bool bNewPawnControllerHuman;

    // do not let the pawn enter the vehicle if the pawn itself is a vehicle
    if( Vehicle(P) != none )
    {
        return false;
    }

    // Restrict someone not on the same team.
    if (bTeamLocked && (WorldInfo.Game.bTeamGame && !WorldInfo.GRI.OnSameTeam(P, self)))
    {
        return false;
    }

    if (SeatIndex <= 0 || SeatIndex >= Seats.Length)
    {
        `warn("Attempted to add a passenger to unavailable passenger seat" @ SeatIndex);
        return false;
    }

    if ( PlayerController(P.Controller) != None )
    {
        bNewPawnControllerHuman = true;
    }

    if ( !Seats[SeatIndex].bNonEnterable && !Seats[SeatIndex].SeatPawn.DriverEnter(p) )
    {
        return false;
    }
    else if( bNewPawnControllerHuman )
    {
        bHadHumanCrew = true;
        ClearTimer('DestroyIfEmpty');
    }

    // Force an updated client ammo count whenever a new player jumps into a weapon seat
    if (Seats[SeatIndex].Gun != none)
    {
        Seats[SeatIndex].Gun.SetClientAmmoCount(Seats[SeatIndex].Gun.AmmoCount);
    }

    SetSeatStoragePawn(SeatIndex, P);

    bHasBeenDriven = true;

    EvaluateBackSeatDrivers();

    return true;
}

// // NOTE: HELICOPTER!
// function bool PassengerEnter(Pawn P, int SeatIndex)
// {
//     local bool TempBool;
//     local ROPlayerReplicationInfo ROPRI;

//     ROPRI = ROPlayerReplicationInfo(P.Controller.PlayerReplicationInfo);

//     if (SeatIndex < 0 || SeatIndex > Seats.length)
//     {
//         return false;
//     }

//     // if( SeatIndex == SeatIndexCopilot && bCopilotMustBePilot &&
//     // 	(!ROPRI.RoleInfo.bIsPilot ||
//     // 	(bTransportHelicopter && !ROPRI.RoleInfo.bIsTransportPilot) ||
//     // 	(!bTransportHelicopter && ROPRI.RoleInfo.bIsTransportPilot)) )
//     // {
//     // 	return false;
//     // }

//     // Cache this because we need to run our backseat driver check AFTER the super has run
//     TempBool = Super.PassengerEnter(P, SeatIndex);

//     if( !bDriving && bBackSeatDriving )
//     {
//         // if( !bEngineOn )
//         // 	StartUpEngine();

//         //if( IsTimerActive('ShutDownEngine') )
//         //	ClearTimer('ShutDownEngine');
//     }

//     return TempBool;
// }

// NOTE: HELICOPTER!
// function PassengerLeave(int SeatIndex)
// {
// 	local ROPawn Left;

// 	Left = ROPawn(Seats[SeatIndex].StoragePawn);

// 	if( !Left.bSwitchingVehicleSeats && Left.Health > 0 && Left.bCanHeloDespawn )
// 	{
// 		Left.bCanHeloDespawn = false; // cannot despawn if we leave!
// 		// if(Controller != none)
// 		// {
// 		// 	// `warn("Score for helo drop");
// 		// 	ROGameInfo(WorldInfo.Game).ScoreHeloDropOff(Controller); // If this is true, we must have spawned in. Therefore +1 the driver
// 		// }
// 	}

// 	Super.PassengerLeave(SeatIndex);

// 	/*if( !bDriving && !bBackSeatDriving && bEngineOn )
// 	{
// 		// Delay this check long enough to see if we get a new backseat driver before we actually shutdown
// 		SetTimer(0.25, false, 'ShutDownEngine');
// 	}*/
// }

/**
 * The pawn Driver has tried to take control of this vehicle
 *
 * @param	P		The pawn who wants to drive this vehicle
 */
function bool TryToDriveSeat(Pawn P, optional byte SeatIdx = 255)
{
    local vector X,Y,Z;
    local bool bEnteredVehicle;

    // Does the vehicle need to be uprighted?
    if ( bIsInverted && bMustBeUpright && VSize(Velocity) <= 5.0f )
    {
        if ( bCanFlip )
        {
            bIsUprighting = true;
            UprightStartTime = WorldInfo.TimeSeconds;
            GetAxes(Rotation,X,Y,Z);
            bFlipRight = ((P.Location - Location) dot Y) > 0;
        }
        return false;
    }

    if ( !CanEnterVehicle(P) || (Vehicle(P) != None) )
    {
        return false;
    }

    // Check vehicle Locking....
    // Must be a non-disabled same team (or no team game) vehicle
    if (!bIsDisabled && (!bTeamLocked || !WorldInfo.Game.bTeamGame || WorldInfo.GRI.OnSameTeam(self,P)))
    {

        if( !AnySeatAvailable() )
        {
            return false;
        }

        if(SeatIdx == 0) 	// attempting to enter driver seat
        {
            if (SeatAvailable(0))
            {
                bEnteredVehicle = (Driver == None) ? DriverEnter(P) : false;
            }
        }
        else if(SeatIdx == 255)		// don't care which seat we get
        {
            // bEnteredVehicle = (Driver == None) ? DriverEnter(P) : PassengerEnter(P, GetFirstAvailableSeat());
            bEnteredVehicle = (SeatAvailable(0)) ? DriverEnter(P) : PassengerEnter(P, GetFirstAvailableSeat());
        }
        else 	// attempt to enter a specific seat
        {
            if (SeatAvailable(SeatIdx))
            {
                bEnteredVehicle = PassengerEnter(P, SeatIdx);
            }
        }

        if( bEnteredVehicle )
        {
            SetTexturesToBeResident( true );
        }

        return bEnteredVehicle;
    }

    VehicleLocked( P );
    return false;
}

// NOTE: HELICOPTER.
// Passengers in helicopters include everyone who is not the pilot or copilot
simulated function int GetFreePassengerSeatIndex()
{
    local int i;

    for ( i = 0; i < Seats.Length; i++ )
    {
        if( !Seats[i].bNonEnterable && (Seats[i].SeatPawn == none || Seats[i].SeatPawn.Controller == none) )
        {
            if( Left(Seats[i].TurretVarPrefix,9) ~= "Passenger" /*|| Left(Seats[i].TurretVarPrefix,6) ~= "DoorMG"*/ )
                return i;
            // else if( i == SeatIndexCopilot && !bCopilotMustBePilot )
            // 	return i;
        }
    }

    return -1;
}

simulated function HandleSeatTransition(ROPawn DriverPawn, int NewSeatIndex, int OldSeatIndex, bool bInstantTransition)
{
    super.HandleSeatTransition(DriverPawn, NewSeatIndex, OldSeatIndex, bInstantTransition);

    if( bInstantTransition )
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

        SpawnOrReplaceSeatProxy(NewSeatIndex, DriverPawn, IsLocalPlayerInThisVehicle());
    }

    // Update the driver IK.
    if (DriverPawn != none)
    {
        // TODO: NEED TO ADD CUSTOM CONTROLLERS IN PROXY TO PAWN!
        DriverPawn.UpdateVehicleIK(self, NewSeatIndex, SeatPositionIndex(NewSeatIndex,, true));
    }

    // Health follows the player
    if( Role == ROLE_Authority )
    {
        UpdateSeatProxyHealth(GetSeatProxyIndexForSeatIndex(NewSeatIndex), GetSeatProxyForSeatIndex(OldSeatIndex).Health, true);
    }

    // Always hide the Proxymesh for the now unoccupied seat we just left
    if( GetSeatProxyForSeatIndex(OldSeatIndex).ProxyMeshActor != none )
    {
        // Actually, that's a lie. Show the proxy if the seat is no longer enterable
        if( Seats[OldSeatIndex].bNonEnterable )
        {
            GetSeatProxyForSeatIndex(OldSeatIndex).ProxyMeshActor.HideMesh(false);
        }
        else
        {
            GetSeatProxyForSeatIndex(OldSeatIndex).ProxyMeshActor.HideMesh(true);
        }
    }
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
    super.UpdateSeatProxyHealth(SeatProxyIndex, NewHealth, bIsTransition);
}

simulated function bool CanEnterVehicle(Pawn P)
{
    return !bDeadVehicle && super.CanEnterVehicle(P);
}

simulated function ChangeCrewCollision(bool bEnable, int SeatIndex)
{
    local int i;

    // // Hide or unhide our driver collision cylinders
    // for( i = CrewHitZoneStart; i <= CrewHitZoneEnd; i++ )
    // {
    // 	if( VehHitZones[i].CrewSeatIndex == SeatIndex )
    // 	{
    // 		if( bEnable )
    // 		{
    // 			Mesh.UnhideBoneByName(VehHitZones[i].CrewBoneName);
    // 		}
    // 		else
    // 		{
    // 			Mesh.HideBoneByName(VehHitZones[i].CrewBoneName,PBO_Disable);
    // 		}
    // 	}
    // }
}

// Fired by a timer in each vehicle subclass code.
// NOTE: Added SpawnOrReplaceSeatProxyCustom.
simulated function FinishTransition(int SeatTransitionedTo)
{
    `pmlog("SeatTransitionedTo:" @ SeatTransitionedTo);

    super.FinishTransition(SeatTransitionedTo);

    // local ROPlayerController ROPC;
    // local ROPawn P;

    // `pmlog("SeatTransitionedTo=" $ SeatTransitionedTo);

    // // Find the local PlayerController for this transition.
    // ROPC = ROPlayerController(Seats[SeatTransitionedTo].SeatPawn.Controller);

    // if (ROPC != None && LocalPlayer(ROPC.Player) != none)
    // {
    //     // Set the FOV to the initial FOV for this position when the transition is complete.
    //     ROPC.HandleTransitionFOV(Seats[SeatTransitionedTo].SeatPositions[Seats[SeatTransitionedTo].InitialPositionIndex].ViewFOV, 0.0);
    // }

    // P = ROPawn(Seats[SeatTransitionedTo].StoragePawn);
    // if (P != None)
    // {
    //     // To set correct customization etc. for the new seat.
    //     SpawnOrReplaceSeatProxyCustom(
    //         SeatTransitionedTo,                  // SeatIndex
    //         P,                                   // ROP
    //         IsLocalPlayerInThisVehicle(),        // bInternalVisibility
    //         False,                               // bForceCreateProxy
    //         False,                               // bForceSetVisible
    //         True                                 // bOnlySeatIndex
    //     );
    // }
    // else
    // {
    //     // If this happens, should we run some default error handling version of SpawnOrReplaceSeatProxyCustom()?
    //     // Did the player get kicked/disconnected before the transition ended? Did they exit the vehicle
    //     // somehow during the transition?
    //     // Or is StoragePawn set after FinishTransition??
    //     `pmlog("!!! ERROR !!! SeatTransitionedTo=" $ SeatTransitionedTo $ " Pawn is NULL!");
    // }

    // Seats[SeatTransitionedTo].bTransitioningToSeat = false;
    // Seats[SeatTransitionedTo].SeatTransitionBoneName = '';
    // Seats[SeatTransitionedTo].TransitionPawn = none;
    // Seats[SeatTransitionedTo].TransitionProxy = none;
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

            SpawnOrReplaceSeatProxy(ProxySeatIdx, ROPawn(Seats[ProxySeatIdx].StoragePawn),
                IsLocalPlayerInThisVehicle());

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

    super.DrivingStatusChanged();

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

// /**
//  * Spawn all seat proxies and set non-local-player proxies visible.
//  *
//  * @param SeatIndex indicates the local player's seat index.
//  * @param ROP       the local player's pawn.
//  */
// simulated function SpawnSeatProxiesCustom(int SeatIndex, optional ROPawn ROP = None)
// {
//     local int i;
//     local ROPawn LocalPawn;

//     if (WorldInfo.NetMode == NM_DedicatedServer)
//     {
//         return;
//     }

//     `pmlog("SeatIndex=" $ SeatIndex);

//     for (i = 0; i < Seats.Length; ++i)
//     {
//         if (i == SeatIndex)
//         {
//             if (ROP == None)
//             {
//                 LocalPawn = ROPawn(Seats[i].StoragePawn);
//             }
//             else
//             {
//                 LocalPawn = ROP;
//             }

//             // This is the seat for *this local player*:
//             // Internally visible, non-force-create, non-force-set-visible.
//             SpawnOrReplaceSeatProxyCustom(
//                 i,                                    // SeatIndex
//                 LocalPawn,                            // ROP
//                 IsLocalPlayerInThisVehicle(),         // bInternalVisibility
//                 False,                                // bForceCreateProxy
//                 False,                                // bForceSetVisible
//                 True                                  // bOnlySeatIndex
//             );

//             // Just to be safe, do this here. Should not be needed though...
//             // TODO: Check if we need this call and remove if we don't!
//             SetProxyMeshVisibility(false, GetSeatProxyForSeatIndex(SeatIndex).ProxyMeshActor, i, true);
//         }
//         else
//         {
//             // Seats for other, non-local players (or empty seats). Force set visible.
//             // If StoragePawn exists, it will be used for the proxy mesh.
//             SpawnOrReplaceSeatProxyCustom(
//                 i,                                    // SeatIndex
//                 ROPawn(Seats[i].StoragePawn),         // ROP
//                 IsLocalPlayerInThisVehicle(),         // bInternalVisibility
//                 True,                                 // bForceCreateProxy
//                 True,                                 // bForceSetVisible
//                 True                                  // bOnlySeatIndex
//             );
//         }
//     }
// }

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

simulated function GetSVehicleDebug(out Array<String> DebugInfo)
{
    local ROVehicleSimCar Sim;
    local int Idx;
    local rotator Rot;

    Sim = ROVehicleSimCar(SimObj);

    Super.GetSVehicleDebug(DebugInfo);

    DebugInfo[DebugInfo.Length] = "----PMVehicle----:";
    DebugInfo[DebugInfo.Length] = "OutputGear | DelayedOutputGear :" @ OutputGear @ "|" @ DelayedOutputGear;
    DebugInfo[DebugInfo.Length] = "TargetOutputGear   : " $ TargetOutputGear;
    DebugInfo[DebugInfo.Length] = "ShiftTimeRemaining : " $ ShiftTimeRemaining;

    DebugInfo[DebugInfo.Length] = "ForwardVel: " $ ForwardVel;
    DebugInfo[DebugInfo.Length] = "ActualThrottle: " $ Sim.ActualThrottle;
    DebugInfo[DebugInfo.Length] = "RPM: " $ EngineRPM;
    DebugInfo[DebugInfo.Length] = "Torque: " $ EvalInterpCurveFloat(Sim.TorqueVSpeedCurve, VSize(Velocity));

    Rot = QuatToRotator(Mesh.GetBoneQuaternion(SteeringWheelBoneName, 1));

    DebugInfo[DebugInfo.Length] = "Steering: " $ SteeringWheelSkelControl.BoneRotation.Pitch * UnrRotToDeg
        @ SteeringWheelSkelControl.BoneRotation.Yaw * UnrRotToDeg
        @ SteeringWheelSkelControl.BoneRotation.Roll * UnrRotToDeg
        @ "|" @ Rot.Pitch * UnrRotToDeg @ Rot.Yaw * UnrRotToDeg @ Rot.Roll * UnrRotToDeg;

    DebugInfo[DebugInfo.Length] = "Wheel : SuspensionPosition : SpinVel (rad/s) : ChassisTq : BrakeTq : MotorTq";
    for (Idx = 0; Idx < Wheels.Length; ++Idx)
    {
        DebugInfo[DebugInfo.Length] = "Wheels[" @ Idx
            $ "]:" @ Wheels[Idx].SuspensionPosition
            $ " :" @ Wheels[Idx].SpinVel
            $ " :" @ Wheels[Idx].ChassisTorque
            $ " :" @ Wheels[Idx].BrakeTorque
            $ " :" @ Wheels[Idx].MotorTorque;
    }
}

DefaultProperties
{
    // This is the same in VehicleCrewProxy, not sure why it's even needed.
    PassengerAnimTree=AnimTree'RM_Common_Animation.Anim.CHR_Tanker_animtree_custom'

    VehicleCrewProxyClass=class'PMVehicleCrewProxy'

    TurretSocketName=Chassis

    InertiaTensorMultiplier=(x=5.0,y=2.0,z=2.0)

    bInfantryCanUse=True
    bStayUpright=False
    UprightLiftStrength=1
    UprightTime=2
    UprightTorqueStrength=1
    bCanFlip=False

    // TODO: make a reset mechanism.
    bNeverReset=True

    SpeedoMinDegree=5461
    SpeedoMaxDegree=60075
    SpeedoMaxSpeed=1365 // 100 km/h.

    // Transmission.
    DelayedOutputGear=1
    ClutchInTime=0.2
    GearShiftTime=0.4

    Health=500

    // TODO: for minimal display? Need something similar?
    // TransportArrayIndex=255

    WeaponPawnClass=class'ROTransportWeaponPawn'
    ClientWeaponPawnClass=class'ROTransportClientSideWeaponPawn'

    bHasTurret=false

    // CrewHitZoneStart=0
    // CrewHitZoneEnd=0

    // TODO: 2 long and 1.5 lat slip seems like a good tuning base point.

    Begin Object Name=SimObject
        ThrottleSpeed=0.4
    End Object

    // Begin Object Name=RRWheel
    // End Object

    // Begin Object Name=LRWheel
    // End Object

    // Begin Object Name=RFWheel
    // End Object

    // Begin Object Name=LFWheel
    // End Object

    DebugPointAtDistance=20.0

    SteeringWheelRotScale=15.0
    SteeringRightSwapAngleOn=80
    SteeringRightSwapAngleOff=120

    LookAtTargetSkelControlNames(0)=LookAt_Driver
    LookAtTargetSkelControlNames(2)=LookAt_Passenger_FrontRight
    LookAtTargetSkelControlNames(2)=LookAt_Passenger_RearRight
    LookAtTargetSkelControlNames(3)=LookAt_Passenger_RearLeft

    PointAtTargetSkelControlNames(0)=PointAt_Driver
    PointAtTargetSkelControlNames(1)=PointAt_Passenger_FrontRight
    PointAtTargetSkelControlNames(2)=PointAt_Passenger_RearRight
    PointAtTargetSkelControlNames(3)=PointAt_Passenger_RearLeft

    // PointAtRootBoneNames(0)=Root_PointAt_Driver
    PointAtRootBoneNames(0)=Root_Driver
    PointAtRootBoneNames(1)=Root_PointAt_Passenger_FrontRight
    PointAtRootBoneNames(2)=Root_PointAt_Passenger_RearRight
    PointAtRootBoneNames(3)=Root_PointAt_Passenger_RearLeft

    BrakePedalSkelControlName=Pedal_Brake
    SteeringWheelSkelControlName=SteeringWheel
    SteeringWheelBoneName=SteeringWheel
}
