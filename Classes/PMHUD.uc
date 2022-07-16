class PMHUD extends ROHUD;

event PostBeginPlay()
{
    super.PostBeginPlay();

    VehicleListWidget = Spawn(DefaultVehicleListWidget, PlayerOwner);
    VehicleListWidget.Initialize(PlayerOwner);
    HUDWidgetList.AddItem(VehicleListWidget);
}

DefaultProperties
{
    DefaultHelicopterInfoWidget=class'PMHUDWidgetHelicopterInfo'
}
