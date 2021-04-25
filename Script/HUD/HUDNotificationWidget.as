struct FHUDNotification
{
	FText Text;

	private float Duration;
	private bool bIsPermanent = false;
	private bool bIsDone = false;


	FHUDNotification(FString InNotification, float InDuration)
	{
		Text = FText::FromString(InNotification);
		Duration = InDuration;
		bIsPermanent = FMath::IsNearlyZero(Duration);
	}

	void Tick(float DeltaSeconds)
	{
		if (!bIsDone)
		{
			Duration -= DeltaSeconds;
			if (Duration <= 0.f)
			{
				bIsDone = true;
			}
		}
	}

	bool IsDone() const
	{
		return !bIsPermanent && bIsDone;
	}
};


UCLASS(Abstract)
class UHUDNotificationWidget : UUserWidget
{
	UPROPERTY(NotEditable, Instanced, Meta = (BindWidget))
	private UTextBlock NotificationText;

	private TArray<FHUDNotification> Notifications;


	void AddNotification(FString InNotification, float InDuration)
	{
		Notifications.Add(FHUDNotification(InNotification, InDuration));
	}

	UFUNCTION(BlueprintOverride)
	void Tick(FGeometry MyGeometry, float InDeltaTime)
	{
		int NumNotifications = Notifications.Num();
		if (NumNotifications > 0)
		{
			for (int i = NumNotifications; i > 0; i--)
			{
				Notifications[i - 1].Tick(InDeltaTime);
				if (Notifications[i - 1].IsDone())
				{
					Notifications.RemoveAt(i - 1);
				}
			}
			NumNotifications = Notifications.Num();
			if (NumNotifications > 0)
			{
				NotificationText.SetVisibility(ESlateVisibility::HitTestInvisible);
				NotificationText.SetText(Notifications[NumNotifications - 1].Text);
				return;
			}
		}

		NotificationText.SetVisibility(ESlateVisibility::Collapsed);
	}
};
