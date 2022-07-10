class PMVehicleCrewProxy extends VehicleCrewProxy;

/**
 * Set the blend node to play the idle animation once the full body animation has finished
 */
simulated event OnAnimEnd(AnimNodeSequence SeqNode, float PlayedTime, float ExcessTime)
{
    local SeatProxy CurrentSeatProxy;

    if( FullBodyBlendNode != none )
    {
        FullBodyBlendNode.SetBlendTarget(0.0f, 0.1f);
    }

    // Update the proxy's IK once an transition (FullBodyAnimation) has finished.
    // This is done as a failsafe since animators can change the IK parameters during
    // a transition animation using anim notifies.
    CurrentSeatProxy = MyVehicle.SeatProxies[SeatProxyIndex];
    UpdateVehicleIK(MyVehicle, CurrentSeatProxy.SeatIndex, CurrentSeatProxy.PositionIndex);
    `pmlog("UpdateVehicleIK called for seat index " $ CurrentSeatProxy.SeatIndex $ " and position index " $ CurrentSeatProxy.PositionIndex);
}

simulated function PlayFullBodyAnimation(name AnimationName, float BlendTime = 0.1f, bool bLoop = false)
{
    `pmlog("AnimationName=" $ AnimationName $ " BlendTime=" $ BlendTime $ " bLoop=" $ bLoop);

    if (AnimationName == '')
    {
        `pmlog("WARNING: animation name missing!");
        ROPlayerController(MyVehicle.Driver.Controller).ClientMessage(
            self $ "->" $ GetFuncName() $ "(): WARNING: animation name missing!");
        return;
    }

    if (FullBodyBlendNode != none && FullBodySequencePlayerNode != none)
    {
        FullBodyBlendNode.SetBlendTarget(1.0f, BlendTime);
        FullBodySequencePlayerNode.SetAnim(AnimationName);
        FullBodySequencePlayerNode.PlayAnim(bLoop);
    }
    else
    {
        `log("No full body node available to play full body animation!");
    }
}

DefaultProperties
{

}
