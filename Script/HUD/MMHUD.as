import HUD.HUDNotificationWidget;
class AMMHUD : AHUD
{
	UPROPERTY(EditDefaultsOnly, Category=MidwinterMurdersHUD)
	private const TSubclassOf<UMMHUDWidget> HUDWidgetClass;

	private UMMHUDWidget HUDWidget;


	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		if (ensure(HUDWidgetClass.IsValid()))
		{
			HUDWidget = Cast<UMMHUDWidget>(
				WidgetBlueprint::CreateWidget(HUDWidgetClass.Get(), OwningPlayerController)
			);
			HUDWidget.AddToPlayerScreen();
			HUDWidget.NotificationWidget.AddNotification("You are in the village of Midwinter.", 3.f);
		}
	}

	void PlayerDied()
	{
		HUDWidget.NotificationWidget.AddNotification("You were murdered!", 0.f);
	}
};


UCLASS(Abstract)
class UMMHUDWidget : UUserWidget
{
	UPROPERTY(NotEditable, Instanced, Meta = (BindWidget))
	UHUDNotificationWidget NotificationWidget;
};
