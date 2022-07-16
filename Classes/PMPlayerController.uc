class PMPlayerController extends ROPlayerController;

simulated event PostBeginPlay()
{
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
    local vector X;
    local vector Y;
    local vector Z;
    local vector EndShot;
    local vector StartShot;
    local vector CamLoc;
    local rotator CamRot;
    local class<ROVehicle> VehicleClass;
    Local ROVehicle ROV;

    GetPlayerViewPoint(CamLoc, CamRot);
    GetAxes(CamRot, X, Y, Z);
    StartShot = CamLoc;
    EndShot = StartShot + (200.0 * X);

    `pmlog(self $ " attempting to spawn" @ TankContentClass @ "at" @ EndShot);
    ClientMessage(self $ " attempting to spawn" @ TankContentClass @ "at" @ EndShot);

    VehicleClass = class<ROVehicle>(DynamicLoadObject(TankContentClass, class'Class'));
    if (VehicleClass != none)
    {
        ROV = Spawn(VehicleClass, , , EndShot);
        ROV.Mesh.AddImpulse(vect(0,0,1), ROV.Location);
        ClientMessage(self $ " spawned" @ VehicleClass @ ROV @ "at" @ ROV.Location);
        `pmlog(self $ " spawned" @ VehicleClass @ ROV @ "at" @ ROV.Location);
    }
}

exec function LogMyVehicleSeatProxyStates()
{
    local PMVehicleTank Tank;

    Tank = PMVehicleTank(Pawn);

    if (Tank != None)
    {
        Tank.LogSeatProxyStates(Tank);
    }
}

DefaultProperties
{

}
