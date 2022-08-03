class PMPlayerController extends ROPlayerController;

simulated event PostBeginPlay()
{
    super.PostBeginPlay();

    if (WorldInfo.NetMode == NM_Standalone)
    {
        GetPM().SetHUD();
    }
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
`ifdef(DEBUG_BUILD)

exec function Camera(name NewMode)
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

exec function BlowUpVehiclesForceTurretBlowOff()
{
    ServerBlowUpVehicles(true, 3, true);
}

exec function BlowUpVehicles(optional bool bHitAmmo = false, optional int DeadVehicleType = 999,
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

exec function SpawnVehicle(string TankContentClass)
{
    ServerSpawnVehicle(TankContentClass);
}

exec function SpawnPanzerIVG()
{
    SpawnVehicle("ProtoMutator.PMVehicle_PanzerIVG_Content");
}

reliable server function ServerSpawnVehicle(string TankContentClass)
{
    local vector EndShot;
    local vector CamLoc;
    local vector HitLoc;
    local vector HitNorm;
    local rotator CamRot;
    local class<ROVehicle> VehicleClass;
    local ROVehicle ROV;

    GetPlayerViewPoint(CamLoc, CamRot);
    EndShot = CamLoc + (vector(CamRot) * 10000.0);

    Trace(HitLoc, HitNorm, EndShot, CamLoc, true, vect(10,10,10));

    if (IsZero(HitLoc))
    {
        `pmlog(self $ " trace failed, using fallback spawn location");
        HitLoc = CamLoc + (vector(CamRot) * 250);
    }

    HitLoc.Z += 250;

    `pmlog(self $ " attempting to spawn" @ TankContentClass @ "at" @ HitLoc);
    ClientMessage(self $ " attempting to spawn" @ TankContentClass @ "at" @ HitLoc);

    VehicleClass = class<ROVehicle>(DynamicLoadObject(TankContentClass, class'Class'));
    if (VehicleClass != none)
    {
        ROV = Spawn(VehicleClass, , , HitLoc);
        ROV.Mesh.AddImpulse(vect(0,0,1), ROV.Location);
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

`endif // DEBUG_BUILD

DefaultProperties
{
}
