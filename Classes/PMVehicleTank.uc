// ROVehicleTank with some useful code taken from ROVehicleHelicopter.
class PMVehicleTank extends ROVehicleTank;

/** Animtree for characters riding in this vehicle. */
// TODO: useless variable as it doesn't differ from VehicleCrewProxy default AnimTree...
var Animtree PassengerAnimTree;

// NOTE: From ROVehicleHelicopter.
simulated function SitDriver( ROPawn ROP, int SeatIndex )
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

        `pmlog("Local Pawn = " $ LocalPawn $ " GetALocalPlayerController() = " $ GetALocalPlayerController() $ " local Pawn Controller = " $ LocalPawn.Controller);

        if( GetALocalPlayerController() != none && LocalPawn == Seats[SeatIndex].SeatPawn )
        {
            ROPC = ROPlayerController(GetALocalPlayerController());
        }
    }

    if( ROPC != none && (WorldInfo.NetMode == NM_Standalone || IsLocalPlayerInThisVehicle()) )
    {
        // Force the driver's view rotation to default to forward instead of some arbitrary angle
        ROPC.SetRotation(rot(0,0,0));
        // Set Interior engine sounds. Exterior sounds are called by ROPawn.StopDriving
        // TODO: HELOSTUFF, CHECK THIS.
        // SetInteriorEngineSound(true);
    }

    if( ROP != none )
    {
        ROP.Mesh.SetAnimTreeTemplate(PassengerAnimTree);
        ROP.HideGear(true);
        if( ROP.CurrentWeaponAttachment != none )
            ROP.PutAwayWeaponAttachment();

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
            SpawnOrReplaceSeatProxy(SeatIndex, ROP, false);

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
       // IK update here to force client replication on vehicle entry, otherwise IK doesn't update until position change
       ROP.UpdateVehicleIK(self, SeatIndex, SeatPositionIndex(SeatIndex,, true));
    }
}

// NOTE: From ROVehicleHelicopter.
simulated function SpawnOrReplaceSeatProxy(int SeatIndex, ROPawn ROP, optional bool bInternalVisibility)
{
    local int i;//,j;
    local VehicleCrewProxy CurrentProxyActor;
    local bool bSetMeshRequired;
    local ROMapInfo ROMI;

    // Don't spawn the seat proxy actors on the dedicated server (at least for now)
    if( WorldInfo == none || WorldInfo.NetMode == NM_DedicatedServer )
    {
        return;
    }

    ROMI = ROMapInfo(WorldInfo.GetMapInfo());

    // Don't create proxy if vehicle is dead to prevent leave bodies in the air after round has finished
    if (IsPendingKill() || bDeadVehicle)
        return;

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

            // Create the proxy mesh
            if( !Seats[SeatProxies[i].SeatIndex].bNonEnterable )
            {
                CurrentProxyActor.ReplaceProxyMeshWithPawn(ROP);
            }
            else if( bSetMeshRequired )
            {
                CurrentProxyActor.CreateProxyMesh(SeatProxies[i]);
            }

            // Override the animation set
            if ( SeatProxyAnimSet != None )
            {
                CurrentProxyActor.Mesh.AnimSets[0] = SeatProxyAnimSet;
            }

            if( bInternalVisibility )
                SetSeatProxyVisibilityInterior();
            else
                SetSeatProxyVisibilityExterior();

            if( !Seats[SeatProxies[i].SeatIndex].bNonEnterable )
                CurrentProxyActor.HideMesh(true);
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

// NOTE: From ROVehicleHelicopter.
// TODO: check hide/unhide logic again. Differs from ROVehicle.
/**
 * Set the SeatProxies visibility to the foregraound depth group
 * Now only unhide the proxy if it's dead
 *
 * @param   DriverIndex         - if set denotes the local player's SeatIndex
 */
simulated function SetSeatProxyVisibilityInterior(int DriverIndex =-1)
{
    local int i;

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
    local int i, ProxySeatIdx;
    local bool bRevivingProxy;

    `pmlog("");

    for ( i = 0; i < SeatProxies.Length; i++ )
    {
        `pmlog("Before logic : SeatProxies[" $ i $ "] Health=" $ SeatProxies[i].Health $ " HiddenGame=" $ SeatProxies[i].ProxyMeshActor.Mesh.HiddenGame,
            SeatProxies[i].ProxyMeshActor != None);

        bRevivingProxy = false;
        ProxySeatIdx = SeatProxies[i].SeatIndex;

        if (SeatProxies[i].Health != GetSeatProxyHealth(i))
        {

            if( SeatProxies[i].Health <=0 && GetSeatProxyHealth(i) > 0 )
            {
                bRevivingProxy = true;

                /* NOTE: HELOSTUFF.
                // TODO: for tanks, do we need to do other shit here? Probably not...
                if( i == 0 && bBackSeatDriving )
                    StopCopilotFlyingPosition();
                */
            }

            SeatProxies[i].Health = GetSeatProxyHealth(i);

            if( SeatProxies[i].ProxyMeshActor != none )
            {
                // Bring the proxy "back to life"
                if( bRevivingProxy )
                {
                    SeatProxies[i].ProxyMeshActor.ClearBloodOverlay();

                    // Replace it entirely to get rid of gore
                    SpawnOrReplaceSeatProxy(ProxySeatIdx, ROPawn(Seats[ProxySeatIdx].StoragePawn), IsLocalPlayerInThisVehicle() );

                    // Hide the proxy if the seat is vacant
                    if( Seats[ProxySeatIdx].SeatPositions[SeatProxies[i].PositionIndex].bDriverVisible )
                    {
                        Seats[ProxySeatIdx].PositionBlend.HandleAnimPlay(Seats[ProxySeatIdx].SeatPositions[SeatPositionIndex(ProxySeatIdx,,true)].PositionIdleAnim, true);

                        if( Seats[ProxySeatIdx].bNonEnterable )
                        {
                            SeatProxies[i].ProxyMeshActor.HideMesh(false);
                            ChangeCrewCollision(true, ProxySeatIdx);
                        }
                        else
                            SeatProxies[i].ProxyMeshActor.HideMesh(true);
                    }
                }
                // If the seat proxy is dead, unhide it
                else if( SeatProxies[i].Health <= 0  )
                {
                    // Driver proxy died
                    if( ProxySeatIdx == 0)
                    {
                        // Set the current move order
                        CurrentMoveOrder.Forward = 0;
                        CurrentMoveOrder.Strafe = 0;
                        CurrentMoveOrder.Up = 0;
                    }

                    // Play anim instead of hide in ROAnimNodeBlendDriverDeath
                    if( Seats[ProxySeatIdx].SeatPositions[SeatProxies[i].PositionIndex].bDriverVisible )
                    {
                        //Seats[ProxySeatIdx].PositionBlend.HandleAnimPlay(Seats[ProxySeatIdx].SeatPositions[Seats[ProxySeatIdx].InitialPositionIndex].PositionIdleAnim, true);

                        SeatProxies[i].ProxyMeshActor.HideMesh(false);

                        if( Seats[ProxySeatIdx].bNonEnterable )
                        {
                            ChangeCrewCollision(false, ProxySeatIdx);
                        }
                    }
                }
            }
        }

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

    LogSeatProxyStates(self $ "::" $ GetFuncName() $ "before");

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

    LogSeatProxyStates(self $ "::" $ GetFuncName() $ "after");
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
    // Ignore ROVehicleTank::UpdateSeatProxyHealth
    super(ROVehicleTreaded).UpdateSeatProxyHealth(SeatProxyIndex, NewHealth, bIsTransition);
}

simulated function bool CanEnterVehicle(Pawn P)
{
    return !bDeadVehicle && super.CanEnterVehicle(P);
}

// NOTE: Added SpawnOrReplaceSeatProxy.
simulated function FinishTransition(int SeatTransitionedTo)
{
    local ROPlayerController ROPC;
    local ROPawn P;

    `pmlog("SeatTransitionedTo=" $ SeatTransitionedTo);

    // Find the local playercontroller for this transition.
    ROPC = ROPlayerController(Seats[SeatTransitionedTo].SeatPawn.Controller);

    if (ROPC != None && LocalPlayer(ROPC.Player) != none)
    {
        // Set the FOV to the initial FOV for this position when the transition is complete
        ROPC.HandleTransitionFOV(Seats[SeatTransitionedTo].SeatPositions[Seats[SeatTransitionedTo].InitialPositionIndex].ViewFOV, 0.0);

        P = ROPawn(ROPC.Pawn);
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

// Debug helper.
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
        DeadVehicleType = 3;
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

simulated function LogSeatProxyStates(string Msg)
{
    `pmlog(Msg);
}

DefaultProperties
{
    // This is the same in VehicleCrewProxy, not sure why it's even needed.
    PassengerAnimTree=AnimTree'CHR_Playeranimtree_Master.CHR_Tanker_animtree'
}
