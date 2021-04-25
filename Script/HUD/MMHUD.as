import HUD.AreaInfoWidget;
import HUD.HUDNotificationWidget;
import HUD.TimeOfDayWidget;


class AMMHUD : AHUD
{
	UPROPERTY(EditDefaultsOnly, Category=MidwinterMurdersHUD)
	private const TSubclassOf<UMMHUDWidget> HUDWidgetClass;

	private UMMHUDWidget HUDWidget;


	void AddNotification(FString InNotification, float InDuration)
	{
		HUDWidget.NotificationWidget.AddNotification(InNotification, InDuration);
	}

	void ReceivePossess(APawn PossessedPawn)
	{
		if (ensure(HUDWidgetClass.IsValid()))
		{
			HUDWidget = Cast<UMMHUDWidget>(
				WidgetBlueprint::CreateWidget(HUDWidgetClass.Get(), OwningPlayerController)
			);
			HUDWidget.AddToPlayerScreen();
			HUDWidget.NotificationWidget.AddNotification("You are in the village of Midwinter.", 3.f);
		}

		HUDWidget.AreaInfoWidget.BindToPawn(PossessedPawn);
	}
};


UCLASS(Abstract)
class UMMHUDWidget : UUserWidget
{
	UPROPERTY(NotEditable, Instanced, Meta = (BindWidget))
	UTimeOfDayWidget TimeOfDayWidget;

	UPROPERTY(NotEditable, Instanced, Meta = (BindWidget))
	UHUDNotificationWidget NotificationWidget;

	UPROPERTY(NotEditable, Instanced, Meta = (BindWidget))
	UAreaInfoWidget AreaInfoWidget;
};
