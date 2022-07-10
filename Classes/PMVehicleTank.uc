// ROVehicleTank with some useful code taken from ROVehicleHelicopter.
class PMVehicleTank extends ROVehicleTank;

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
    local Pawn LocalPawn;

    `pmlog("ROP=" $ ROP $ " SeatIndex= " $ SeatIndex);

    // NOTE: Ignore ROVehicleTank::SitDriver.
    super(ROVehicleTreaded).SitDriver(ROP, SeatIndex);

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
        if ((ROP.DrivenVehicle.Controller != none) && (ROP.DrivenVehicle.Controller == GetALocalPlayerController()))
        {
            ROPC = ROPlayerController(ROP.DrivenVehicle.Controller);
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

        `pmlog("Local Pawn = " $ LocalPawn $ " GetALocalPlayerController() = " $ GetALocalPlayerController() $ " local Pawn Controller = " $ LocalPawn.Controller);

        if ((GetALocalPlayerController() != none) && (LocalPawn == Seats[SeatIndex].SeatPawn))
        {
            ROPC = ROPlayerController(GetALocalPlayerController());
        }
    }

    if ((ROPC != none) && ((WorldInfo.NetMode == NM_Standalone) || IsLocalPlayerInThisVehicle()))
    {
        // Force the driver's view rotation to default to forward instead of some arbitrary angle
        ROPC.SetRotation(rot(0,0,0));
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

            SpawnOrReplaceSeatProxy(SeatIndex, ROP, true);
        }
        else if (ROAIController(ROP.Controller) != none && IsLocalPlayerInThisVehicle())
        {
            SpawnOrReplaceSeatProxy(SeatIndex, ROP, true);
        }
        else
        {
            SpawnOrReplaceSeatProxy(SeatIndex, ROP, false);
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

// NOTE: From ROVehicleHelicopter.
simulated function SpawnOrReplaceSeatProxy(int SeatIndex, ROPawn ROP, optional bool bInternalVisibility)
{
    local int i;
    local VehicleCrewProxy CurrentProxyActor;
    local bool bSetMeshRequired;
    local ROMapInfo ROMI;

    // Don't spawn the seat proxy actors on the dedicated server (at least for now).
    if( WorldInfo == none || WorldInfo.NetMode == NM_DedicatedServer )
    {
        return;
    }

    ROMI = ROMapInfo(WorldInfo.GetMapInfo());

    // Don't create proxy if vehicle is dead to prevent leave bodies in the air after round has finished.
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
                SeatProxies[i].ProxyMeshActor = Spawn(class'PMVehicleCrewProxy',self);
                SeatProxies[i].ProxyMeshActor.MyVehicle = self;
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

                CurrentProxyActor.SetRelativeLocation( vect(0,0,0) );
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
            if( !Seats[SeatProxies[i].SeatIndex].bNonEnterable )
            {
                CurrentProxyActor.ReplaceProxyMeshWithPawn(ROP);
            }
            else if( bSetMeshRequired )
            {
                CurrentProxyActor.CreateProxyMesh(SeatProxies[i]);
            }

            // Override the animation set.
            if ( SeatProxyAnimSet != None )
            {
                CurrentProxyActor.Mesh.AnimSets[0] = SeatProxyAnimSet;
            }

            if( bInternalVisibility )
            {
                SetSeatProxyVisibilityInterior();
            }
            else
            {
                SetSeatProxyVisibilityExterior();
            }

            if (!Seats[SeatProxies[i].SeatIndex].bNonEnterable)
            {
                CurrentProxyActor.HideMesh(true);
            }
            else
            {
                CurrentProxyActor.UpdateVehicleIK(self, SeatProxies[i].SeatIndex, SeatProxies[i].PositionIndex);
                if (SeatProxies[i].Health > 0)
                {
                    ChangeCrewCollision(true, SeatProxies[i].SeatIndex);
                }
            }
        }
    }
}

// NOTE: From ROVehicleHelicopter.
// TODO: check hide/unhide logic again. Differs from ROVehicle.
/**
 * Set the SeatProxies visibility to the foreground depth group
 * Now only unhide the proxy if it's dead
 *
 * @param   DriverIndex         - if set denotes the local player's SeatIndex
 */
simulated function SetSeatProxyVisibilityInterior(int DriverIndex =-1)
{
    local int i;

    for (i = 0; i < SeatProxies.Length; i++)
    {
        if (SeatProxies[i].ProxyMeshActor != none)
        {
            SeatProxies[i].ProxyMeshActor.SetVisibilityToInterior();
            SeatProxies[i].ProxyMeshActor.SetLightingChannels(InteriorLightingChannels);
            SeatProxies[i].ProxyMeshActor.SetLightEnvironment(InteriorLightEnvironment);
        }

        if (DriverIndex >= 0 && GetSeatProxyForSeatIndex(DriverIndex) == SeatProxies[i])
        {
            if (GetSeatProxyForSeatIndex(DriverIndex).ProxyMeshActor != none)
            {
                GetSeatProxyForSeatIndex(DriverIndex).ProxyMeshActor.HideMesh(true);
            }
        }
        else
        {
            // Unhide this mesh if no pawn is sitting here and the proxy is dead, or if it's a non-enterable seat.
            if( (SeatProxies[i].Health <= 0 && (DriverIndex < 0 ||
                GetDriverForSeatIndex(SeatProxies[i].SeatIndex) == none )) || Seats[SeatProxies[i].SeatIndex].bNonEnterable )
            {
                // Unhide the mesh for the interior seat proxies.
                if( SeatProxies[i].ProxyMeshActor != none )
                {
                    SeatProxies[i].ProxyMeshActor.HideMesh(false);
                    `pmlog("Unhiding proxy for seat" @ SeatProxies[i].SeatIndex @ "as health is" @ SeatProxies[i].Health);
                }
            }
        }
    }
}

// NOTE: From ROVehicleHelicopter.
// TODO: check hide/unhide logic again. Differs from ROVehicle.
/**
 * Set the SeatProxies visibility to the world depth group if they can
 * become visible.
 * Now only unhide them if the proxy is dead
 *
 * @param   DriverIndex         - If set denotes the local player's SeatIndex
 */
simulated function SetSeatProxyVisibilityExterior(optional int DriverIndex =-1)
{
    local int i,j;
    local bool bCanBecomeVisible;

    `pmlog("DriverIndex=" $ DriverIndex);

    for ( i = 0; i < SeatProxies.Length; i++ )
    {
        `pmlog("Before logic : SeatProxies[" $ i $ "] HiddenGame=" $ SeatProxies[i].ProxyMeshActor.Mesh.HiddenGame,
            SeatProxies[i].ProxyMeshActor != None);

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

        `pmlog("After logic  : SeatProxies[" $ i $ "] HiddenGame=" $ SeatProxies[i].ProxyMeshActor.Mesh.HiddenGame,
            SeatProxies[i].ProxyMeshActor != None);
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
                    SpawnOrReplaceSeatProxy(ProxySeatIdx, ROPawn(Seats[ProxySeatIdx].StoragePawn), IsLocalPlayerInThisVehicle());

                    // Hide the proxy if the seat is vacant.
                    if (Seats[ProxySeatIdx].SeatPositions[SeatProxies[i].PositionIndex].bDriverVisible)
                    {
                        Seats[ProxySeatIdx].PositionBlend.HandleAnimPlay(Seats[ProxySeatIdx].SeatPositions[SeatPositionIndex(ProxySeatIdx,,true)].PositionIdleAnim, true);

                        if (Seats[ProxySeatIdx].bNonEnterable)
                        {
                            SeatProxies[i].ProxyMeshActor.HideMesh(false);
                            ChangeCrewCollision(true, ProxySeatIdx);
                        }
                        else
                        {
                            SeatProxies[i].ProxyMeshActor.HideMesh(true);
                        }
                    }
                }
                // If the seat proxy is dead, unhide it.
                else if (SeatProxies[i].Health <= 0)
                {
                    // Driver proxy died
                    if (ProxySeatIdx == 0)
                    {
                        // Set the current move order
                        CurrentMoveOrder.Forward = 0;
                        CurrentMoveOrder.Strafe = 0;
                        CurrentMoveOrder.Up = 0;
                    }

                    // Play anim instead of hide in ROAnimNodeBlendDriverDeath.
                    if (Seats[ProxySeatIdx].SeatPositions[SeatProxies[i].PositionIndex].bDriverVisible)
                    {
                        //Seats[ProxySeatIdx].PositionBlend.HandleAnimPlay(Seats[ProxySeatIdx].SeatPositions[Seats[ProxySeatIdx].InitialPositionIndex].PositionIdleAnim, true);

                        SeatProxies[i].ProxyMeshActor.HideMesh(false);

                        if (Seats[ProxySeatIdx].bNonEnterable)
                        {
                            ChangeCrewCollision(false, ProxySeatIdx);
                        }
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
simulated function HandleSeatTransition(ROPawn DriverPawn, int NewSeatIndex, int OldSeatIndex, bool bInstantTransition)
{
    `pmlog("DriverPawn=" $ DriverPawn $ " NewSeatIndex=" $ NewSeatIndex $ " OldSeatIndex=" $ OldSeatIndex $ " bInstantTransition=" $ bInstantTransition);

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

        // TODO: should we call this here or later in this branch??
        SpawnOrReplaceSeatProxy(NewSeatIndex, DriverPawn, IsLocalPlayerInThisVehicle());

        // Turn off or on the OLD proxy mesh depending upon the health of the Proxy.
        // TODO: why is ROVehicleTank checking for NetMode here but not for the other hide/unhide calls?
        //       Is this SP only logic on purpose?
        if ((WorldInfo.NetMode != NM_DedicatedServer) && (GetSeatProxyForSeatIndex(OldSeatIndex).ProxyMeshActor != none))
        {
            `pmlog("Enter (WorldInfo.NetMode != NM_DedicatedServer) branch, NetMode=" $ WorldInfo.NetMode);

            // OLD proxy alive.
            if (GetSeatProxyForSeatIndex(OldSeatIndex).Health > 0)
            {
                // Proxy has bDriverVisible and local player in the vic.
                if (Seats[OldSeatIndex].SeatPositions[GetSeatProxyForSeatIndex(OldSeatIndex).PositionIndex].bDriverVisible || IsLocalPlayerInThisVehicle())
                {
                    GetSeatProxyForSeatIndex(OldSeatIndex).ProxyMeshActor.HideMesh(false);
                    `pmlog("SeatProxies[" $ OldSeatIndex $ "] Setting HiddenGame to false because proxy is alive, HiddenGame = "
                        $ GetSeatProxyForSeatIndex(OldSeatIndex).ProxyMeshActor.Mesh.HiddenGame);

                    // Update and re-activate IK for the Proxy Mesh...
                    GetSeatProxyForSeatIndex(OldSeatIndex).ProxyMeshActor.UpdateVehicleIK(self, OldSeatIndex, SeatPositionIndex(OldSeatIndex,,true));
                }
            }
            // OLD proxy dead.
            else
            {
                // Seat no longer enterable -> show proxy even if it's dead...
                if (Seats[OldSeatIndex].bNonEnterable)
                {
                    GetSeatProxyForSeatIndex(OldSeatIndex).ProxyMeshActor.HideMesh(false);
                    `pmlog("SeatProxies[" $ OldSeatIndex $ "] Setting HiddenGame to false because proxy is non-enterable, HiddenGame = "
                        $ SeatProxies[OldSeatIndex].ProxyMeshActor.Mesh.HiddenGame);
                }
                else
                {
                    GetSeatProxyForSeatIndex(OldSeatIndex).ProxyMeshActor.HideMesh(true);
                    `pmlog("SeatProxies[" $ OldSeatIndex $ "] Setting HiddenGame to true because proxy's Health is 0, HiddenGame = "
                        $ SeatProxies[OldSeatIndex].ProxyMeshActor.Mesh.HiddenGame);
                }
            }
        }
    }

    // Update the driver IK.
    // For both animated and non-animated. TODO: should we call this for both methods??
    if (DriverPawn != none)
    {
        DriverPawn.UpdateVehicleIK(self, NewSeatIndex, SeatPositionIndex(NewSeatIndex,,true));
    }

    // NOTE: Combined From ROVehicleTank and ROVehicleHelicopter.
    // Health follows the player moving if they animated transition out of a seat
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
                // Old seat proxy is dead -> hide it.
                else
                {
                    GetSeatProxyForSeatIndex(OldSeatIndex).ProxyMeshActor.HideMesh(true);
                    `pmlog("SeatProxies[" $ OldSeatIndex $ "] Setting HiddenGame to true because proxy is dead, HiddenGame = "
                        $ SeatProxies[OldSeatIndex].ProxyMeshActor.Mesh.HiddenGame);
                }
            }
        }
    }

    // NOTE: for animated transitions, SpawnOrReplaceSeatProxy is called in FinishTransition,
    //       which is triggered by a timer, individually in each vehicle's subclass code.

    LogSeatProxyStates(self $ "_" $ GetFuncName() $ "(): after");
}

/**
 * Use on the server to update the health of a SeatProxy. This function will
 * set the health of the SeatProxy, and call the function to replicate the
 * health to the client.
 * @param   SeatProxyIndex        The seatproxy you want to Update the health for
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
/*
simulated function ChangeCrewCollision(bool bEnable, int SeatIndex)
{
    local int i;

    // Hide or unhide our driver collision cylinders.
    for (i = CrewHitZoneStart; i <= CrewHitZoneEnd; i++)
    {
        if (VehHitZones[i].CrewSeatIndex == SeatIndex)
        {
            if (bEnable)
            {
                Mesh.UnhideBoneByName(VehHitZones[i].CrewBoneName);
            }
            else
            {
                Mesh.HideBoneByName(VehHitZones[i].CrewBoneName, PBO_Disable);
            }
        }
    }
}
*/

// Fired by a timer in each vehicle subclass code.
// NOTE: Added SpawnOrReplaceSeatProxy.
simulated function FinishTransition(int SeatTransitionedTo)
{
    local ROPlayerController ROPC;
    local ROPawn P;

    `pmlog("SeatTransitionedTo=" $ SeatTransitionedTo);

    // Find the local PlayerController for this transition.
    ROPC = ROPlayerController(Seats[SeatTransitionedTo].SeatPawn.Controller);

    if (ROPC != None && LocalPlayer(ROPC.Player) != none)
    {
        // Set the FOV to the initial FOV for this position when the transition is complete
        ROPC.HandleTransitionFOV(Seats[SeatTransitionedTo].SeatPositions[Seats[SeatTransitionedTo].InitialPositionIndex].ViewFOV, 0.0);

        P = ROPawn(ROPC.Pawn);

        // TODO: Do we need to use SeatProxy.StoragePawn here? Just log a warning and if the pawns don't
        //       match and revisit this function if this warning is ever triggered.
        `pmlog("*** *** *** *** *** *** WARNING, POTENTIAL BUG, CHECK THIS LOGIC AGAIN: ROPawn(ROPC.Pawn)="
            $ P $ " Seats[" $ SeatTransitionedTo $ "].StoragePawn=" $ Seats[SeatTransitionedTo].StoragePawn,
            P != Seats[SeatTransitionedTo].StoragePawn);

        if (P != None)
        {
            // To set correct customization etc...
            SpawnOrReplaceSeatProxy(SeatTransitionedTo, P, IsLocalPlayerInThisVehicle());
        }
        else
        {
            // If this happens, should we run some default error handling version of SpawnOrReplaceSeatProxy()?
            // Did the player get kicked/disconnected before the transition ended? Did they exit the vehicle
            // somehow during the transition?
            `pmlog("!!! ERROR !!! SeatTransitionedTo=" $ SeatTransitionedTo $ " ROPC.Pawn is NULL!");
        }
    }

    Seats[SeatTransitionedTo].bTransitioningToSeat = false;
    Seats[SeatTransitionedTo].SeatTransitionBoneName = '';
    Seats[SeatTransitionedTo].TransitionPawn = none;
    Seats[SeatTransitionedTo].TransitionProxy = none;
}

/**
 * Call this function to blow up the vehicle
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

// TODO: Just a debug helper. Delete this or disable with preprocessor.
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
    local ROSkeletalMeshComponent SM;

    `pmlog(Msg $ ": SeatProxies:");
    `log("**** **** **** **** **** ****");
    for (i = 0; i < SeatProxies.Length; ++i)
    {
        SP = SeatProxies[i];
        SM = SP.ProxyMeshActor.Mesh;
        if (SM != None)
        {
            HiddenStatusStr = string(SM.HiddenGame);
        }
        else
        {
            HiddenStatusStr = "(mesh==null)";
        }

        `log("  SeatProxies[" $ i $ "]: Health=" $ SP.Health $ " SeatIndex= " $ SP.SeatIndex
            $ " PositionIndex=" $ SP.PositionIndex $ " HiddenGame= " $ HiddenStatusStr $ " ProxyMeshActor=" $ SP.ProxyMeshActor);
    }
    `log("**** **** **** **** **** ****");
}

DefaultProperties
{
    // This is the same in VehicleCrewProxy, not sure why it's even needed.
    PassengerAnimTree=AnimTree'CHR_Playeranimtree_Master.CHR_Tanker_animtree'

    // For debugging.
    bInfantryCanUse=True
}
