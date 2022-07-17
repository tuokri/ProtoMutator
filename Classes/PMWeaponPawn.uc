class PMWeaponPawn extends ROWeaponPawn;

/**
 * This function is called when the driver's status has changed.
 * NOTE: Overridden to replace the call to SpawnSeatProxies.
 */
simulated function DrivingStatusChanged()
{
    local ROPlayerController ROPC;
    local int OverrideInitialPositionIndex;
    local bool bDidInitialCommanderPlacement;
    local bool bWantsInitialCommanderPlacement;

    // Don't continue if the initial replication hasn't happened yet. We
    // need those replicated values for the code below to work right.
    // We'll call this funciton again when the initial replication is complete
    // - Ramm
    if( WorldInfo.NetMode == NM_Client && !bInitialReplicationComplete )
    {
        return;
    }

    // Skip ROWeaponPawn::DrivingStatusChanged.
    super(ROVehicleBase).DrivingStatusChanged();

    `pmlog("bDriving=" $ bDriving);

    // Below is setup for owner and server only.  This resolves some problems where sim
    // proxies do bad things when a vehicle becomes relevant!
    if (bDriving && Role != ROLE_SimulatedProxy)
    {
        if (Driver != None)
        {
            ROPC = ROPlayerController(Driver.Controller);
        }

        // Couldn't find the Controller for the driver, check the seatpawn
        if( ROPC == none )
        {
            ROPC = ROPlayerController(Controller);
        }

        if( ROPC != none && ROPlayerReplicationInfo(ROPC.PlayerReplicationInfo) != none && ROPlayerReplicationInfo(ROPC.PlayerReplicationInfo).RoleInfo.bIsTankCommander )
        {
            bWantsInitialCommanderPlacement = true;
        }

        // Make the commander spawn initially with his head out of the hatch
        if( bWantsInitialCommanderPlacement && !MyVehicle.bInitialCommanderPositioningComplete && MySeatIndex == MyVehicle.GetCommanderSeatIndex() )
        {
            OverrideInitialPositionIndex = 1;
            MyVehicle.bInitialCommanderPositioningComplete = true;
            bDidInitialCommanderPlacement = true;
        }
        else
        {
            OverrideInitialPositionIndex = MyVehicle.Seats[MySeatIndex].InitialPositionIndex;
        }

        // Initialize the position indexes
        MyVehicle.Seats[MySeatIndex].PreviousPositionIndex = OverrideInitialPositionIndex;
        if( WorldInfo.Netmode == NM_Client )
        {
            MyVehicle.SetPositionIndex(MySeatIndex, OverrideInitialPositionIndex, true);
        }
        else
        {
            MyVehicle.SetPositionIndex(MySeatIndex, OverrideInitialPositionIndex);
        }
        MyVehicle.Seats[MySeatIndex].CameraTag = MyVehicle.Seats[MySeatIndex].SeatPositions[OverrideInitialPositionIndex].PositionCameraTag;
        bAllowCameraRotation = !MyVehicle.Seats[MySeatIndex].SeatPositions[OverrideInitialPositionIndex].bCamRotationFollowSocket;

        // If we are transitioning into a position with locked camera rotation, update the desired aim so we look where the gun was pointing before
        if(  ROPC != None && MyVehicle.Seats[MySeatIndex].SeatPositions[OverrideInitialPositionIndex].bCamRotationFollowSocket )
        {
            ROPC.DesiredVehicleAim = MyVehicle.SeatWeaponRotation(MySeatIndex,,true);
        }

        if (ROPC != None && LocalPlayer(ROPC.Player) != none)
        {
            // If the vehicle we are driving is a tank, spawn the seat proxies
            // ROVehicleTank(MyVehicle).SpawnSeatProxies();
            if (PMVehicleTank(MyVehicle) != None)
            {
                PMVehicleTank(MyVehicle).SpawnSeatProxiesCustom(MySeatIndex);
            }

            `pmlog("PMVehicleTank(MyVehicle)=" $ PMVehicleTank(MyVehicle));

            // Let's save some time and do it once.
            if( ROPC.myHUD != none
                && ROHUD(ROPC.myHUD) != none
                && ROHUD(ROPC.myHUD).OrdersWidget != none )
            {
               OrdersWidget = ROHUD(ROPC.myHUD).OrdersWidget;
            }
            // Fix CLBIT-2612 -Nate.
            else if(ROPC.myHUD != none
                && ROHUD(ROPC.myHUD) != none
                && ROHUD(ROPC.myHUD).CompactVoiceCommsWidget != none)
            {
                CompactVoiceComms = ROHUD(ROPC.myHUD).CompactVoiceCommsWidget;
            }

        }
        else
        {
            // Clean up orders widget
            if ( OrdersWidget != none && OrdersWidget.bVisible )
            {
                Hide3dWidget();
                OrdersWidget.Hide();
                OrdersWidget = none;
            }

            // Fix CLBIT-2612 -Nate.
            if(CompactVoiceComms != none && CompactVoiceComms.bVisible)
            {
                Hide3dWidget();
                CompactVoiceComms.Hide();
                CompactVoiceComms = None;
            }
        }

        // Switch to the interior model when we enter the vehicle
        if ( MyVehicle != none && ROPC != None && LocalPlayer(ROPC.Player) != none )
        {
            if (Driver != None)
            {
                ROPawnTanker(Driver).ShowFirstPersonHands();
            }

            MyVehicle.SetVehicleDepthToForeground();

            if( MyVehicle.SeatProxies[MyVehicle.Seats[MySeatIndex].SeatPositions[OverrideInitialPositionIndex].SeatProxyIndex].ProxyMeshActor != none)
            {
                MyVehicle.SeatProxies[MyVehicle.Seats[MySeatIndex].SeatPositions[OverrideInitialPositionIndex].SeatProxyIndex].ProxyMeshActor.HideMesh(true);
            }
        }

        // Since we did the initial commander placement, update the transitioning and anim flags here
        if( bDidInitialCommanderPlacement )
        {
            MyVehicle.HandleFinishRemoteSeatPawnPositionTransitioningByIndex(MySeatIndex);
        }
    }
    else
    {
        // Clean up orders widget
        if ( OrdersWidget != none && OrdersWidget.bVisible )
        {
            Hide3dWidget();
            OrdersWidget.Hide();
            OrdersWidget = none;
        }

        if(CompactVoiceComms != none && CompactVoiceComms.bVisible)
        {
            Hide3dWidget();
            CompactVoiceComms.Hide();
            CompactVoiceComms = None;
        }

    }

    if( !bDriving && MyVehicleWeapon != none )
    {
        MyVehicleWeapon.ForceEndFire();
    }
}

DefaultProperties
{

}
