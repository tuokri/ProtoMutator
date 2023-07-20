class PMPlayerController extends ROPlayerController;

var MaterialInterface DebugCachedMat;

simulated event PostBeginPlay()
{
    // local StaticMesh Test;
    // local SeqAct_GetProperty GetProp;
    // local EditorEngine Ed;
    // local bool bResult;
    // local int i;
    // local array<string> Names;
    // local GameEngine GE;
    // local FullyLoadedPackagesInfo PackageInfo;
    // local name PackageToLoad;
    // local SeqVar_Object ObjIn;
    // local SeqVar_Object ObjOut;

    super.PostBeginPlay();

    if (WorldInfo.NetMode == NM_Standalone)
    {
        GetPM().SetHUD();
    }

    // GE = GameEngine(class'Engine'.static.GetEngine());
    // `pmlog("GameEngine = " $ GE);

    // bResult = GetPerObjectConfigSections(class'EditorEngine', Names);
    // `pmlog("bResult = " $ bResult);
    // if (bResult)
    // {
    //     for (i = 0; i < Names.Length; ++i)
    //     {
    //         `pmlog("Names[" $ i $ "]: " $ Names[i]);
    //     }
    // }

    // ForEach GE.PackagesToFullyLoad(PackageInfo)
    // {
    //     ForEach PackageInfo.PackagesToLoad(PackageToLoad)
    //     {
    //         `pmlog("PackageToLoad = " $ PackageToLoad);
    //     }
    // }

    // Ed = EditorEngine(FindObject("Transient.EditorEngine_0", class'EditorEngine'));
    // `pmlog("Transient.EditorEngine_0 = " $ Ed);

    // Test = new(self) class'StaticMesh';
    // Test.LODInfo[0].Elements[0].bEnableCollision = false;

    // GetProp = new(self) class'SeqAct_GetProperty';
    // ObjOut = new(self) class'SeqVar_Object';
    // GetProp.PropertyName = 'ForceLoadMods';
    // GetProp.Targets[0] = Ed;
    // // GetProp.VariableLinks[0].LinkedVariables[0] = Ed;
    // GetProp.VariableLinks[1].LinkedVariables[0] = ObjOut;
    // GetProp.ForceActivateInput(0);
    // `pmlog("Transient.EditorEngine_0.ForceLoadMods:");
    // `pmlog("ObjOut.GetObjectValue() = " $ ObjOut.GetObjectValue());

    // GetProp = new(self) class'SeqAct_GetProperty';
    // ObjOut = new(self) class'SeqVar_Object';

    // `pmlog("GetProp  = " $ GetProp);
    // `pmlog("ObjOut   = " $ ObjOut);

    // GetProp.PropertyName = 'EditorEngine';
    // GetProp.Targets[0] = GE;
    // // GetProp.VariableLinks[0].LinkedVariables[0] = GE;
    // GetProp.VariableLinks[1].LinkedVariables[0] = ObjOut;
    // GetProp.ForceActivateInput(0);
    // `pmlog("GameEngine.EditorEngine:");
    // `pmlog("ObjOut.GetObjectValue() = " $ ObjOut.GetObjectValue());

    // bResult = GetPerObjectConfigSections(class'EditorEngine', Names);
    // `pmlog("bResult = " $ bResult);
    // for (i = 0; i < Names.Length; ++i)
    // {
    //     `pmlog("Names[" $ i $ "]: " $ Names[i]);
    // }

    // ForEach GE.PackagesToFullyLoad(PackageInfo)
    // {
    //     ForEach PackageInfo.PackagesToLoad(PackageToLoad)
    //     {
    //         `pmlog("PackageToLoad = " $ PackageToLoad);
    //     }
    // }
}

function PM GetPM()
{
    return PM(WorldInfo.Game.BaseMutator);
}

function RightLeftLean()
{
    ServerLeanLeft(bWantsToLeanLeft);
}

function LeftRightLean()
{
    ServerLeanRight(bWantsToLeanRight);
}

exec function LeanRight()
{
    if (Pawn != None)
    {
        if (ROPawn(Pawn) != None)
        {
            ROPawn(Pawn).LeanRight();
        }
    }

    ServerLeanRight(True);
}

exec function LeanLeft()
{
    if (Pawn != None)
    {
        if (ROPawn(Pawn) != None)
        {
            ROPawn(Pawn).LeanLeft();
        }
    }

    ServerLeanLeft(True);
}

exec function LeanRightReleased()
{
    if (Pawn != None)
    {
        if (ROPawn(Pawn) != None)
        {
            ROPawn(Pawn).LeanRightReleased();
        }
    }

    ServerLeanRight(false);
}

exec function LeanLeftReleased()
{
    if (Pawn != None)
    {
        if (ROPawn(Pawn) != None)
        {
            ROPawn(Pawn).LeanLeftReleased();
        }
    }

    ServerLeanLeft(False);
}

reliable protected server function ServerLeanRight(bool leanstate)
{
    bWantsToLeanRight = leanstate;

    if( Pawn != none )
    {
        if( ROPawn(Pawn) != none )
        {
            if (leanstate)
            {
                ROPawn(Pawn).LeanRight();
            }
            else
            {
                ROPawn(Pawn).LeanRightReleased();
                bWantsToLeanRight = false;

                if( bWantsToLeanLeft )
                {
                    SetTimer(0.2f, false, 'RightLeftLean');
                }
            }
        }
        else if ( leanstate && ROVWeap_TankTurret(ROWeaponPawn(Pawn).MyVehicleWeapon) != none )
        {
            bWantsToLeanRight = false;
            ROVWeap_TankTurret(ROWeaponPawn(Pawn).MyVehicleWeapon).IncrementRange();
        }
    }
}

reliable protected server function ServerLeanLeft(bool leanstate)
{
    bWantsToLeanLeft = leanstate;

    if( Pawn != none )
    {
        if( ROPawn(Pawn) != none )
        {
            if (leanstate)
            {
                ROPawn(Pawn).LeanLeft();
            }
            else
            {
                ROPawn(Pawn).LeanLeftReleased();

                if( bWantsToLeanRight )
                {
                    SetTimer(0.2f, false, 'LeftRightLean');
                }
            }
        }
        else if ( leanstate && ROVWeap_TankTurret(ROWeaponPawn(Pawn).MyVehicleWeapon) != none )
        {
            bWantsToLeanLeft = false;
            ROVWeap_TankTurret(ROWeaponPawn(Pawn).MyVehicleWeapon).DecrementRange();
        }
    }
}

// -------------------- DEBUG HELPERS --------------------
`if(`isdefined(DEBUG_BUILD))

simulated exec function Camera(name NewMode)
{
    ServerCamera(NewMode);
}

reliable server function ServerCamera(name NewMode)
{
    if (NewMode == '1st')
    {
        NewMode = 'FirstPerson';
    }
    else if (NewMode == '3rd')
    {
        NewMode = 'ThirdPerson';
    }
    else if (NewMode == 'free')
    {
        NewMode = 'FreeCam';
    }
    else if (NewMode == 'fixed')
    {
        NewMode = 'Fixed';
    }

    SetCameraMode(NewMode);

    if (PlayerCamera != None)
    {
        `pmlog("CameraStyle=" $ PlayerCamera.CameraStyle);
        ClientMessage("CameraStyle=" $ PlayerCamera.CameraStyle);
    }
}

simulated exec function BlowUpVehiclesForceTurretBlowOff()
{
    ServerBlowUpVehicles(true, 3, true);
}

simulated exec function BlowUpVehicles(optional bool bHitAmmo = false, optional int DeadVehicleType = 999,
    optional bool bForceBlowOffTurret = false)
{
    ServerBlowUpVehicles(bHitAmmo, DeadVehicleType, bForceBlowOffTurret);
}

// NOTE: From ROVehicle:
//       1 is explosion, 2 is ammo explosion, 3 is ammo explosion w/ turret blowoff.
// TODO: add more types... For slow cook-off, non-explosion crew escape anim, etc...
private reliable server function ServerBlowUpVehicles(optional bool bHitAmmo = false,
    optional int DeadVehicleType = 999, optional bool bForceBlowOffTurret = false)
{
    local ROVehicle ROV;
    local int i;

    ForEach AllActors(class'ROVehicle', ROV)
    {
        ROV.bHitAmmo = bHitAmmo || bForceBlowOffTurret;

        if (bForceBlowOffTurret && PMVehicleTank(ROV) != None)
        {
            PMVehicleTank(ROV).BlowupVehicleForcedTurretBlowOff();
        }
        else
        {
            ROV.BlowupVehicle();
        }

        // Useless? Is set in ROV.BlowupVehicle()?
        if (DeadVehicleType != 999)
        {
            ROV.DeadVehicleType = DeadVehicleType;
        }

        // Clean up seats and seat proxies for now to avoid log spam.
        // TODO: need to change this debug helper when experimenting with crew death animations.
        for (i = 0; i < ROV.Seats.Length; i++)
        {
            if (!ROV.Seats[i].bNonEnterable
                && ROV.Seats[i].SeatPawn != None
                && ROV.Seats[i].StoragePawn != None
                && ROV.Seats[i].SeatPawn.IsHumanControlled())
            {
                ROPawn(ROV.Seats[i].StoragePawn).Died(self, class'RODamageType_CannonShell_AP', ROV.Location);
            }
        }
        for (i = 0; i < ROV.SeatProxies.Length; i++)
        {
            if (ROV.SeatProxies[i].ProxyMeshActor != none)
            {
                ROV.SeatProxies[i].ProxyMeshActor.SetBase(none);
                ROV.SeatProxies[i].ProxyMeshActor.Destroy();
                ROV.SeatProxies[i].ProxyMeshActor = none;
            }
        }
    }
}

simulated exec function SpawnVehicle(string VehicleContentClass)
{
    ServerSpawnVehicle(VehicleContentClass);
}

simulated exec function SpawnPanzerIVG()
{
    SpawnVehicle("ProtoMutator.PMVehicle_PanzerIVG_Content");
}

simulated exec function SpawnRenault4CV_2()
{
    SpawnVehicle("ProtoMutator.PMVehicle_Renault4CV_2_Content");
}

reliable server function ServerSpawnVehicle(string VehicleContentClass)
{
    local vector EndShot;
    local vector CamLoc;
    local vector HitLoc;
    local vector HitNorm;
    local rotator CamRot;
    local class<ROVehicle> VehicleClass;
    local ROVehicle ROV;

    GetPlayerViewPoint(CamLoc, CamRot);
    EndShot = CamLoc + (Normal(vector(CamRot)) * 10000.0);

    Trace(HitLoc, HitNorm, EndShot, CamLoc, true, vect(10,10,10));

    if (IsZero(HitLoc))
    {
        `pmlog(self $ " trace failed, using fallback spawn location");
        HitLoc = CamLoc + (vector(CamRot) * 250);
    }

    HitLoc.Z += 150;

    `pmlog(self $ " attempting to spawn" @ VehicleContentClass @ "at" @ HitLoc);
    ClientMessage(self $ " attempting to spawn" @ VehicleContentClass @ "at" @ HitLoc);

    VehicleClass = class<ROVehicle>(DynamicLoadObject(VehicleContentClass, class'Class'));
    if (VehicleClass != none)
    {
        ROV = Spawn(VehicleClass, , , HitLoc);
        ROV.Mesh.AddImpulse(vect(0,0,1), ROV.Location);
        ROV.SetTeamNum(GetTeamNum());
        ClientMessage(self $ " spawned" @ VehicleClass @ ROV @ "at" @ ROV.Location);
        `pmlog(self $ " spawned" @ VehicleClass @ ROV @ "at" @ ROV.Location);
    }
}

simulated function PMVehicleTank GetMyPMTank()
{
    if (PMVehicleTank(Pawn) != None)
    {
        return PMVehicleTank(Pawn);
    }
    else if (ROWeaponPawn(Pawn) != None)
    {
        return PMVehicleTank(ROWeaponPawn(Pawn).MyVehicle);
    }
    else
    {
        return PMVehicleTank(Pawn.DrivenVehicle);
    }
}

simulated exec function LogMyVehicleSeatProxyStates()
{
    if (GetMyPMTank() != None)
    {
        GetMyPMTank().LogSeatProxyStates(GetMyPMTank());
    }
}

simulated exec function KillDriver(int DriverToKill)
{
    DoKillDriver(DriverToKill);
    ServerKillDriver(DriverToKill);
}

reliable server function ServerKillDriver(int DriverToKill)
{
    DoKillDriver(DriverToKill);
}

simulated function DoKillDriver(int DriverToKill)
{
    if (GetMyPMTank() != None)
    {
        GetMyPMTank().DebugKillDriver(DriverToKill);
    }
}

simulated exec function KillProxy(int ProxyIndexToKill)
{
    DoKillProxy(ProxyIndexToKill);
    ServerKillProxy(ProxyIndexToKill);
}

simulated function DoKillProxy(int ProxyIndexToKill)
{
    if (GetMyPMTank() != None)
    {
        GetMyPMTank().DebugKillProxy(ProxyIndexToKill);
    }
}

reliable server function ServerKillProxy(int ProxyIndexToKill)
{
    DoKillProxy(ProxyIndexToKill);
}

simulated exec function RefreshProxies()
{
    if (GetMyPMTank() != None)
    {
        GetMyPMTank().DebugRefreshProxies();
    }
}

simulated exec function ReviveProxies()
{
    if (GetMyPMTank() != None)
    {
        GetMyPMTank().DebugReviveProxies();
    }
}

simulated exec function DestroyProxies()
{
    if (GetMyPMTank() != None)
    {
        GetMyPMTank().DebugDestroyProxies();
    }
}

simulated exec function DamageProxy(int ProxyIndex, int DamageAmount)
{
    DoDamageProxy(ProxyIndex, DamageAmount);
    ServerDamageProxy(ProxyIndex, DamageAmount);
}

reliable server function ServerDamageProxy(int ProxyIndex, int DamageAmount)
{
    DoDamageProxy(ProxyIndex, DamageAmount);
}

simulated function DoDamageProxy(int ProxyIndex, int DamageAmount)
{
    if (GetMyPMTank() != None)
    {
        GetMyPMTank().DebugDamageProxy(ProxyIndex, DamageAmount);
    }
}

simulated exec function SetTankTrackSplineArrowSize(optional int ArrowSize = 5)
{
    local PMVehicleTank Tank;
    local int i;
    local int j;

    ForEach AllActors(class'PMVehicleTank', Tank)
    {
        for (i = 0; i < Tank.TrackSplineActorsLeft.Length; ++i)
        {
            for (j = 0; j < Tank.TrackSplineActorsLeft[i].Connections.Length; ++j)
            {
                Tank.TrackSplineActorsLeft[i].Connections[j].SplineComponent.SplineArrowSize = ArrowSize;
            }
        }

        for (i = 0; i < Tank.TrackSplineActorsRight.Length; ++i)
        {
            for (j = 0; j < Tank.TrackSplineActorsRight[i].Connections.Length; ++j)
            {
                Tank.TrackSplineActorsRight[i].Connections[j].SplineComponent.SplineArrowSize = ArrowSize;
            }
        }
    }
}

simulated exec function SetTankTrackSplinesDepthToForeground(optional bool bForeGround = True)
{
    local PMVehicleTank Tank;
    local int i;
    local int j;
    local ESceneDepthPriorityGroup DepthPrio;

    // ConsoleCommand("show splines");

    DepthPrio = bForeGround ? SDPG_Foreground : SDPG_World;

    ForEach AllActors(class'PMVehicleTank', Tank)
    {
        for (i = 0; i < Tank.TrackSplineActorsLeft.Length; ++i)
        {
            for (j = 0; j < Tank.TrackSplineActorsLeft[i].Connections.Length; ++j)
            {
                Tank.TrackSplineActorsLeft[i].Connections[j].SplineComponent.SetDepthPriorityGroup(DepthPrio);
            }
        }

        for (i = 0; i < Tank.TrackSplineActorsRight.Length; ++i)
        {
            for (j = 0; j < Tank.TrackSplineActorsRight[i].Connections.Length; ++j)
            {
                Tank.TrackSplineActorsRight[i].Connections[j].SplineComponent.SetDepthPriorityGroup(DepthPrio);
            }
        }
    }
}

simulated exec function HideTrack(optional int TrackMaterialIndex = 1)
{
    local MaterialInterface InvisibleMat;
    local MaterialInterface MatToSet;
    local MaterialInterface CurrentMat;
    local PMVehicleTank Tank;

    InvisibleMat = Material'M_VN_Common_Characters.Materials.M_Hair_NoTransp';

    ForEach AllActors(class'PMVehicleTank', Tank)
    {
        CurrentMat = Tank.Mesh.GetMaterial(TrackMaterialIndex);

        if (CurrentMat == InvisibleMat)
        {
            MatToSet = DebugCachedMat;
        }
        else
        {
            DebugCachedMat = CurrentMat;
            MatToSet = InvisibleMat;
        }

        Tank.Mesh.SetMaterial(TrackMaterialIndex, MatToSet);
    }
}

simulated exec function SetDrawSplineTangents(bool bDraw)
{
    local PMVehicleTank Tank;

    ForEach AllActors(class'PMVehicleTank', Tank)
    {
        Tank.bDebugDrawSplineTangents = bDraw;
    }
}

simulated exec function SpawnActor(string ActorClass)
{
    ServerSpawnActor(ActorClass);
}

simulated exec function SpawnDynamicSMA()
{
    ServerSpawnActor("ProtoMutator.PMDynamicSMActor");
}

reliable server function ServerSpawnActor(string ActorClass)
{
    local vector EndShot;
    local vector CamLoc;
    local vector HitLoc;
    local vector HitNorm;
    local rotator CamRot;
    local class<Actor> LoadedActorClass;
    local Actor A;

    GetPlayerViewPoint(CamLoc, CamRot);
    EndShot = CamLoc + (vector(CamRot) * 10000.0);

    Trace(HitLoc, HitNorm, EndShot, CamLoc, true, vect(10,10,10));

    if (IsZero(HitLoc))
    {
        `pmlog(self $ " trace failed, using fallback spawn location");
        HitLoc = CamLoc + (vector(CamRot) * 250);
    }

    HitLoc.Z += 50;

    `pmlog(self $ " attempting to spawn" @ ActorClass @ "at" @ HitLoc);
    ClientMessage(self $ " attempting to spawn" @ ActorClass @ "at" @ HitLoc);

    LoadedActorClass = class<Actor>(DynamicLoadObject(ActorClass, class'Class'));
    if (LoadedActorClass != none)
    {
        A = Spawn(LoadedActorClass, , , HitLoc);
        ClientMessage(self $ " spawned" @ LoadedActorClass @ A @ "at" @ A.Location);
        `pmlog(self $ " spawned" @ LoadedActorClass @ A @ "at" @ A.Location);
    }
}

simulated exec function FindObjectX(string FullObjectName, optional string ObjectClassName = "Object")
{
    local class<Object> ObjectClass;
    ObjectClass = class<Object>(DynamicLoadObject(ObjectClassName, class'Class'));
    `pmlog("Loaded class: " $ ObjectClass);
    `pmlog("Found object: " $ FindObject(FullObjectName, ObjectClass));
}

simulated exec function AttachMeToVehicle(optional string AttachBone)
{
    `pmlog("AttachBone:" @ AttachBone);
    DoAttachMeToVehicle(AttachBone);
    if (WorldInfo.NetMode == NM_Client)
    {
        ServerAttachMeToVehicle(AttachBone);
    }
}

simulated function DoAttachMeToVehicle(optional string AttachBone)
{
    local ROVehicle ROV;
    local vector BoneLoc;
    local rotator BoneRot;

    if (AttachBone == "")
    {
        `pmlog("clearing attachment");
        bIgnoreMoveInput = 0;
        Pawn.SetHardAttach(false);
        Pawn.bCollideWorld = true;
        Pawn.SetCollision(true, true);
        Pawn.SetBase(none);
        Pawn.SetPhysics(PHYS_Falling);
        Pawn.bIgnoreBaseRotation = false;
        Pawn.bShadowParented = false;
        return;
    }

    ForEach VisibleActors(class'ROVehicle', ROV, 5000, Pawn.Location)
    {
        `pmlog("attaching to ROV:" @ ROV);
        bIgnoreMoveInput = 1;
        Pawn.SetCollision(false, false);
        Pawn.bCollideWorld = false;
        Pawn.SetBase(none);
        Pawn.SetHardAttach(false);
        Pawn.SetPhysics(PHYS_Interpolating);
        Pawn.SetBase(ROV, , ROV.Mesh, name(AttachBone));
        Pawn.SetPhysics(PHYS_Interpolating); // Need to set again after SetBase().
        // Pawn.bIgnoreBaseRotation = true;
        Pawn.bShadowParented = true;

        BoneLoc = ROV.Mesh.GetBoneLocation(name(AttachBone), 1);
        BoneRot = rot(0,0,0);
        Pawn.SetRelativeLocation(BoneLoc);
        Pawn.SetRelativeRotation(BoneRot);

        return;
    }
}

reliable server function ServerAttachMeToVehicle(optional string AttachBone)
{
    DoAttachMeToVehicle(AttachBone);
}

function SetDisableTeamSwapTimer()
{
    // "Developer sanity".
    return;
}

`endif // DEBUG_BUILD

DefaultProperties
{
    bDebugDamage=True
}
