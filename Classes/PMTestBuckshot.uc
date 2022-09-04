class PMTestBuckshot extends IZH43Buckshot;

var float StartTime;
var float LastTime;
var int Steps;
var float LastFlightTime;
var float Distance;
var vector LastLoc;
var vector StartLoc;

simulated event PostBeginPlay()
{
    super.PostBeginPlay();
    LastFlightTime = 0;
    Distance = 0;
    LastLoc = Location;
    StartLoc = Location;
    StartTime = WorldInfo.TimeSeconds;
    Steps = 0;
}

simulated event Tick(float DeltaTime)
{
    local float FlightTimeDelta;

    super.Tick(DeltaTime);

    FlightTimeDelta = FlightTime - LastFlightTime;
    LastFlightTime = FlightTime;
    Distance += Abs(VSize(LastLoc - Location)) / 50;
    LastLoc = Location;
    LastTime = WorldInfo.TimeSeconds;
    ++Steps;

    `pmlog(self
        $ "\nDeltaTime              = " $ DeltaTime
        $ "\nProj.FlightTime        = " $ FlightTime
        $ "\nFlightTimeDelta        = " $ FlightTimeDelta
        $ "\nVelocity (m/s)         = " $ VSize(Velocity) / 50
        $ "\nDistance (m)           = " $ Distance
        $ "\nDamage                 = " $ CalculateBulletDamageRS2(VSizeSq(Velocity) / (Speed * Speed))
        $ "\nVelocity.Z             = " $ Velocity.Z
        $ "\nAcceleration           = " $ Acceleration
        $ "\nBCInverse              = " $ BCInverse
    );
}

simulated event Destroyed()
{
    `pmlog("TotalDistance  (m) = " $ Abs(VSize(StartLoc - Location)) / 50);
    `pmlog("BulletDrop (Z) (m) = " $ (Location.Z - StartLoc.Z) / 50);
    `pmlog("Steps              = " $ Steps);
    `pmlog("StartTime (s)      = " $ StartTime);
    `pmlog("LastTime (s)       = " $ LastTime);
    `pmlog("***");
    `pmlog("WorldInfo.MaxPhysicsSubsteps                            = " $ WorldInfo.MaxPhysicsSubsteps);
    `pmlog("***");
    `pmlog("WorldInfo.PhysicsProperties.PrimaryScene.bFixedTimeStep = " $ WorldInfo.PhysicsProperties.PrimaryScene.bFixedTimeStep);
    `pmlog("WorldInfo.PhysicsProperties.PrimaryScene.TimeStep       = " $ WorldInfo.PhysicsProperties.PrimaryScene.TimeStep);
    `pmlog("WorldInfo.PhysicsProperties.PrimaryScene.MaxSubSteps    = " $ WorldInfo.PhysicsProperties.PrimaryScene.MaxSubSteps);
    `pmlog("***");
    `pmlog("WorldInfo.PhysicsProperties.CompartmentRigidBody.bFixedTimeStep = " $ WorldInfo.PhysicsProperties.CompartmentRigidBody.bFixedTimeStep);
    `pmlog("WorldInfo.PhysicsProperties.CompartmentRigidBody.TimeStep       = " $ WorldInfo.PhysicsProperties.CompartmentRigidBody.TimeStep);
    `pmlog("WorldInfo.PhysicsProperties.CompartmentRigidBody.MaxSubSteps    = " $ WorldInfo.PhysicsProperties.CompartmentRigidBody.MaxSubSteps);

    super.Destroyed();
}
