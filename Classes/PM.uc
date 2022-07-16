class PM extends ROMutator
    config(Mutator_PM);

function PreBeginPlay()
{
    ROGameInfo(WorldInfo.Game).PlayerControllerClass = class'PMPlayerController';
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
