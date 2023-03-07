class PM extends ROMutator
    config(Mutator_PM);

function PreBeginPlay()
{
    local ROGameInfo ROGI;

    ROGI = ROGameInfo(WorldInfo.Game);

    ROGI.PlayerControllerClass = class'PMPlayerController';

    ROGI.NorthRoleContentClasses.LevelContentClasses[0] = "ProtoMutator.PMNorthPawn";
	ROGI.SouthRoleContentClasses.LevelContentClasses[0] = "ProtoMutator.PMSouthPawn";
	ROGI.SouthRoleFlamerContentClass = "ProtoMutator.PMSouthPawnFlamer";
    ROGI.SouthRolePilotContentClass = "ProtoMutator.PMSouthPawnPilot";

    SetHUD();

    `pmlog("mutator init");

    super.PreBeginPlay();
}

function NotifyLogin(Controller NewPlayer)
{
    super.NotifyLogin(NewPlayer);
    ClientSetHUD();
}

reliable client function ClientSetHUD()
{
    SetHUD();
}

function SetHUD()
{
    ROGameInfo(WorldInfo.Game).HUDType = class'PMHUD';
}

DefaultProperties
{

}
