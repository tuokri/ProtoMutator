class PMPawn extends ROPawn;

// TODO: disabled custom controls and nodes when playing full body anims?

// TODO: palm twist not needed.
// TODO: hand pose controllers.
var(Animation) name LeftHandPalmTwistSkelControlName;
var(Animation) SkelControl_TwistBone LeftHandPalmTwistSkelControl;

var(Animation) name NeckLookAtSkelControlName;
// Rotates neck towards head look at location.
var(Animation) SkelControlLookAt NeckLookAtSkelControl;
var(Animation) name HeadLookAtSkelControlName;
// Controls head look at location (in world space).
var(Animation) SkelControlLookAt HeadLookAtSkelControl;
var(Animation) bool bHeadLookAtEnabled;
// Cached LookAt location.
var(Animation) vector HeadLookAtLocation;
// Cached rotation of LookAt direction.
var(Animation) rotator HeadLookAtRotation;

// Cached vehicle reference.
var() PMVehicleWheeled LastPMVehicleWheeled;
// Cached seat index.
var() int LastSeatIndex;

simulated event Tick(float DeltaTime)
{
    super.Tick(DeltaTime);

    if (bHeadLookAtEnabled && HeadLookAtSkelControl != None)
    {
        UpdateHeadLookAt();
    }
}

simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
    super.PostInitAnimTree(SkelComp);

    if (SkelComp == Mesh)
    {
        if (LeftHandPalmTwistSkelControlName != '')
        {
            LeftHandPalmTwistSkelControl = SkelControl_TwistBone(
                Mesh.FindSkelControl(LeftHandPalmTwistSkelControlName));

            if (LeftHandPalmTwistSkelControl != None)
            {
                LeftHandPalmTwistSkelControl.SetSkelControlActive(False);
            }
        }

        if (HeadLookAtSkelControlName != '')
        {
            HeadLookAtSkelControl = SkelControlLookAt(
                Mesh.FindSkelControl(HeadLookAtSkelControlName));

            if (HeadLookAtSkelControl != None)
            {
                HeadLookAtSkelControl.SetSkelControlActive(False);
                HeadLookAtSkelControl.TargetLocationSpace = BCS_WorldSpace;
            }
        }

        if (NeckLookAtSkelControlName != '')
        {
            NeckLookAtSkelControl = SkelControlLookAt(
                Mesh.FindSkelControl(NeckLookAtSkelControlName));

            // TODO: since proxies shouldn't ever be player-controlled,
            // do we even need to set this to true, ever? Maybe for debugging?
            if (NeckLookAtSkelControl != None)
            {
                NeckLookAtSkelControl.SetSkelControlActive(False);
            }
        }
    }
}

simulated function UpdateVehicleIK(ROVehicle InVehicle, int InSeatIndex, byte InPositionIndex)
{
    local VehicleSeat CurrentSeat;
    local PositionInfo CurrentSeatPosition;
    local VehicleLookAtInfo LookAtInfo;

    // No need to update the IK on the dedicated server since IK is disabled
    // See UROAnimNodeVehicleCrewIK::TickAnim()
    if( WorldInfo.NetMode == NM_DedicatedServer )
    {
        return;
    }

    // Hand and foot IK
    if( VehicleIKNode != none && VehicleIKSolverNode != none && VehicleIKSolverNode.Weight > 0.0f )
    {
        VehicleIKNode.UpdateDriverIK(InVehicle, InSeatIndex, InPositionIndex);
        VehicleIKNode.bEnableBodyMovement = False;
    }

    // Look-at IK
    if( VehicleLookAtNode != none && VehicleLookAtSolverNode != none && VehicleLookAtSolverNode.Weight > 0.0f )
    {
        VehicleLookAtNode.UpdateDriverLookAt(InVehicle, InSeatIndex, InPositionIndex);
    }

    // Height displacement
    if( VehicleHeightDisplacementNode != none && VehicleHeightDisplacementSolverNode != none && VehicleHeightDisplacementSolverNode.Weight > 0.0f )
    {
        VehicleHeightDisplacementNode.UpdateDriverHeightDisplacement(InVehicle, InSeatIndex, InPositionIndex);
    }

    // Enabled for driver.
    // SetLeftHandPalmTwistActive(InSeatIndex == 0);

    if (InVehicle != none
        && InSeatIndex < InVehicle.Seats.Length
        && InPositionIndex < InVehicle.Seats[InSeatIndex].SeatPositions.Length)
    {
        // Get a reference to the VehicleIK info used.
        CurrentSeat = InVehicle.Seats[InSeatIndex];
        CurrentSeatPosition = CurrentSeat.SeatPositions[InPositionIndex];
        if (CurrentSeat.CurrentInteraction.bInteractionActive)
        {
            LookAtInfo = CurrentSeat.CurrentInteraction.LookAtInfo;
        }
        else
        {
            LookAtInfo = CurrentSeatPosition.LookAtInfo;
        }

        // Toggle Look-at.
        bHeadLookAtEnabled = LookAtInfo.LookAtEnabled;

        if (HeadLookAtSkelControl != None)
        {
            if (bHeadLookAtEnabled)
            {
                HeadLookAtSkelControl.SetSkelControlStrength(
                    FClamp(LookAtInfo.HeadInfluence, 0.0, 1.0),
                    HeadLookAtSkelControl.BlendInTime
                );
            }
            else
            {
                HeadLookAtSkelControl.SetSkelControlActive(bHeadLookAtEnabled);
            }
        }

        if (NeckLookAtSkelControl != None)
        {
            if (bHeadLookAtEnabled)
            {
                NeckLookAtSkelControl.SetSkelControlStrength(
                    FClamp(LookAtInfo.HeadInfluence, 0.0, 1.0),
                    NeckLookAtSkelControl.BlendInTime
                );
            }
            else
            {
                NeckLookAtSkelControl.SetSkelControlActive(bHeadLookAtEnabled);
            }
        }
    }

    // Disabled initially.
    SetHandsAnimation(ROSkeletalMeshComponent(Mesh).GetCurrentAnimSeqName(false));
    EnableLeftHandPose(false);
    EnableRightHandPose(false);
}

simulated function UpdateHeadLookAt()
{
    if (LastPMVehicleWheeled == None)
    {
        LastPMVehicleWheeled = PMVehicleWheeled(GetVehicle());
    }
    if (LastPMVehicleWheeled != None)
    {
        LastSeatIndex = GetSeatIndex();
        if (LastSeatIndex != INDEX_NONE)
        {
            LastPMVehicleWheeled.GetControllerForSeatIndex(LastSeatIndex
                ).GetPlayerViewPoint(HeadLookAtLocation, HeadLookAtRotation);
            HeadLookAtLocation += Normal(vector(HeadLookAtRotation)) * 5000; // TODO: think about this distance.

            LastPMVehicleWheeled.SetSeatLookAt(LastSeatIndex, HeadLookAtLocation);
            HeadLookAtSkelControl.TargetLocation = HeadLookAtLocation;
        }
        // TODO: else: some fallback option?
        else
        {
            `pmlog("WARNING! GetSeatIndex() not valid!");
        }
    }
    // TODO: else: some fallback option?
    else
    {
        `pmlog("WARNING! PMVehicleWheeled(GetVehicle()) not valid!");
    }
}

simulated function SetLeftHandPalmTwistActive(bool bActive)
{
    if (LeftHandPalmTwistSkelControl != None)
    {
        LeftHandPalmTwistSkelControl.SetSkelControlActive(bActive);
    }
}

simulated function SetHeadLookAtActive(bool bActive)
{
    if (HeadLookAtSkelControl != None)
    {
        HeadLookAtSkelControl.SetSkelControlActive(bActive);
    }
}

function TakeFallingDamage()
{
    local float EffectiveSpeed;
    local float SpeedOverMax;
    local float HurtRatio;
    local float ActualDamage;
    local float SpeedXY;

    // Take damage when landing at high "horizontal" speed.
    // TODO: needs tuning.
    SpeedXY = VSize2D(Velocity) * 1.75;

    `pmlog("SpeedXY:" @ SpeedXY);

    if ((Velocity.Z < -0.5 * MaxFallSpeed) || (SpeedXY < 0.5 * MaxFallSpeed))
    {
        if ( Role == ROLE_Authority )
        {
            MakeNoise(1.0);
            if (Velocity.Z < -1 * MaxFallSpeed)
            {
                EffectiveSpeed = FMax(Velocity.Z * -1, SpeedXY);

                if (TouchingWaterVolume())
                {
                    EffectiveSpeed -= 250;
                    // Velocity.Z += 100;
                }
                if (EffectiveSpeed > MaxFallSpeed)
                {
                    // See how much we are over the MaxFallSpeed, and scale
                    // damage as a function of how far over the MaxFallSpeed
                    // we are in relation to the LethalFallSpeed
                    SpeedOverMax = EffectiveSpeed - MaxFallSpeed;
                    HurtRatio = SpeedOverMax/(LethalFallSpeed - MaxFallSpeed);

                    ActualDamage = 100 * HurtRatio;

                    // reduce the zone health by the actual damage, and prevent the player from taking negative zone damage
                    // Damage the legs
                    if( ActualDamage > 35 )
                    {
                        // Slow the player down if they hurt their legs badly enough
                        if( ROGameInfo(WorldInfo.Game) != none && ROGameInfo(WorldInfo.Game).bLegDamageSlowsPlayer )
                        {
                            LegInjuryTime = WorldInfo.TimeSeconds;
                            LegInjuryAmount = 255;
                            SetSprinting(false);
                        }

                        // Right Thigh
                        PlayerHitZones[14].ZoneHealth -= Min(ActualDamage, Max(PlayerHitZones[14].ZoneHealth, 0));
                        PackHitZoneHealth(14); // Pack this Hit Zone's new Health into the replicated array

                        // Left Thigh
                        PlayerHitZones[18].ZoneHealth -= Min(ActualDamage, Max(PlayerHitZones[18].ZoneHealth, 0));
                        PackHitZoneHealth(18); // Pack this Hit Zone's new Health into the replicated array
                    }

                    if( ActualDamage > 15 )
                    {
                        // Right Calf
                        PlayerHitZones[16].ZoneHealth -= Min(ActualDamage, Max(PlayerHitZones[16].ZoneHealth, 0));
                        PackHitZoneHealth(16); // Pack this Hit Zone's new Health into the replicated array

                        // Left Calf
                        PlayerHitZones[20].ZoneHealth -= Min(ActualDamage, Max(PlayerHitZones[20].ZoneHealth, 0));
                        PackHitZoneHealth(20); // Pack this Hit Zone's new Health into the replicated array
                    }

                    if( ActualDamage > 0 )
                    {
                        // Right Foot
                        PlayerHitZones[17].ZoneHealth -= Min(ActualDamage, Max(PlayerHitZones[17].ZoneHealth, 0));
                        PackHitZoneHealth(17); // Pack this Hit Zone's new Health into the replicated array

                        // Left Foot
                        PlayerHitZones[21].ZoneHealth -= Min(ActualDamage, Max(PlayerHitZones[21].ZoneHealth, 0));
                        PackHitZoneHealth(21); // Pack this Hit Zone's new Health into the replicated array
                    }
                    //`log("ActualDamage Is "$ActualDamage$" HurtRatio = "$HurtRatio$" EffectiveSpeed = "$EffectiveSpeed$" MaxFallSpeed = "$MaxFallSpeed$" LethalFallSpeed = "$LethalFallSpeed);

                    TakeDamage(100 * HurtRatio, None, Location, vect(0,0,0), class'DmgType_Fell');
                }
            }
        }
    }
    else if (Velocity.Z < -1.4 * JumpZ)
        MakeNoise(0.5);
    else if ( Velocity.Z < -0.8 * JumpZ )
        MakeNoise(0.2);
}

DefaultProperties
{
    LeftHandPalmTwistSkelControlName=CHR_LArmPalm_Twist
    HeadLookAtSkelControlName=LookAt_Head
}
