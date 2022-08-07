class PMTrackSplineActor extends SplineActor;

DefaultProperties
{
    Components.Remove(Sprite)

    SplineActorTangent=(X=10.0)

    bMovable=True
    bStatic=False

    Physics=PHYS_Interpolating

    RemoteRole=ROLE_None

    TickGroup=TG_PreAsyncWork
}
