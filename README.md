# ProtoMutator

RS2 vehicle prototyping mutator with minimal dependencies to other mod code for quicker workflow.

## Console commands

Look in [PMPlayerController.uc](Classes/PMPlayerController.uc) for full list of console commands i.e. the functions declared as `exec function`.

`camera MODE` change camera to `MODE`, where `MODE` is one of `[1st, 3rd, free, fixed]`

`SpawnPanzerIVG` spawn Panzer IVG in fron of the player

`BlowUpVehiclesForceTurretBlowOff` destroy all vehicles with ammo explosion that blows the turret off.
