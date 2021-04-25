class AMMHUD : AHUD
{
	UPROPERTY(EditDefaultsOnly, Category=MidwinterMurdersHUD)
	private const TSubclassOf<UUserWidget> HUDWidgetClass;

	private UUserWidget HUDWidget;


	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		if (ensure(HUDWidgetClass.IsValid()))
		{
			HUDWidget = WidgetBlueprint::CreateWidget(HUDWidgetClass.Get(), OwningPlayerController);
			HUDWidget.AddToPlayerScreen();
		}
	}
};
