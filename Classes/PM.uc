class PM extends ROMutator
    config(Mutator_PM);

function PreBeginPlay()
{
    ROGameInfo(WorldInfo.Game).PlayerControllerClass = class'PMPlayerController';
    `pmlog("mutator init");

    super.PreBeginPlay();
}

DefaultProperties
{

}
