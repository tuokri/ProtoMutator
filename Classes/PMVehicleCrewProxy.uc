class PMVehicleCrewProxy extends VehicleCrewProxy;

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
var() PMVehicleWheeled MyPMVehicleWheeled;

// TODO: proxy hand poses.
// 1. spawn in vehicle, normal state -> play same anim as normal node is playing.
//     this means HandsBlendNode is disabled!
// 2. want to do some special action (squeeze steering wheel, gestures?)
//     -> enable HandsBlendNode
var ROAnimNodeHandPoseBlend HandsBlendNode;
var	AnimNodeSequence HandsSequencePlayerNode;

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
        HandsBlendNode = ROAnimNodeHandPoseBlend(Mesh.FindAnimNode('Blend_Hands'));
        HandsSequencePlayerNode = AnimNodeSequence(Mesh.FindAnimNode('Seq_HandsAnim'));

        // Disabled initially, enabled on demand.
        // ROPawn disables these in AttachDriver.
        EnableLeftHandPose(false);
        EnableRightHandPose(false);

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

            // TODO: since proxies shouldn't ever be player-controlled,
            // do we even need to set this to true, ever? Maybe for debugging?
            if (HeadLookAtSkelControl != None)
            {
                HeadLookAtSkelControl.SetSkelControlActive(False);
                // TODO: should this be component space?
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

/** Function to enable/disable the left hand weapon pose.*/
simulated function EnableLeftHandPose(optional bool bEnable=true)
{
    if(HandsBlendNode != none)
    {
        HandsBlendNode.EnableLeftHandPose(bEnable);
    }
}

/** Function to enable/disable the right hand weapon pose. */
simulated function EnableRightHandPose(optional bool bEnable=true)
{
    if (HandsBlendNode != none)
    {
        HandsBlendNode.EnableRightHandPose(bEnable);
    }
}

simulated function SetHandsAnimation(name AnimationName)
{
    if (HandsSequencePlayerNode != none)
    {
        HandsSequencePlayerNode.SetAnim(AnimationName);
        HandsSequencePlayerNode.SetPosition(0.0f, false);
    }
}

simulated function UpdateVehicleIK(ROVehicle InVehicle, int InSeatIndex, byte InPositionIndex)
{
    local VehicleSeat CurrentSeat;
    local PositionInfo CurrentSeatPosition;
    local VehicleLookAtInfo LookAtInfo;

    super.UpdateVehicleIK(InVehicle, InSeatIndex, InPositionIndex);

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
                UpdateHeadLookAt();

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
    SetHandsAnimation(Mesh.GetCurrentAnimSeqName(false));
    EnableLeftHandPose(false);
    EnableRightHandPose(false);
}

simulated function UpdateHeadLookAt()
{
    if (MyPMVehicleWheeled != None)
    {
        if (MyPMVehicleWheeled.GetSeatLookAt(
                MyPMVehicleWheeled.SeatProxies[SeatProxyIndex].SeatIndex,
                HeadLookAtLocation))
        {
            HeadLookAtSkelControl.TargetLocation = HeadLookAtLocation;
        }
        else
        {
            // TODO: use some safe default location here? Or just disable LookAt?
            `pmlog("WARNING! GetSeatLookAt() not valid!");
        }
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

DefaultProperties
{
    LeftHandPalmTwistSkelControlName=CHR_LArmPalm_Twist
    HeadLookAtSkelControlName=LookAt_Head

    Begin Object Name=ProxySkeletalMeshComponent
        AnimTreeTemplate=AnimTree'RM_Common_Animation.Anim.CHR_Tanker_animtree_custom'
    End Object
}
