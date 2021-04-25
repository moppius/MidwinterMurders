import Components.TimeOfDayManager;


UCLASS(Abstract)
class UTimeOfDayWidget : UUserWidget
{
	UPROPERTY(NotEditable, Instanced, Meta = (BindWidget))
	private UTextBlock TimeText;

	private UTimeOfDayManagerComponent TimeOfDayManager;


	UFUNCTION(BlueprintOverride)
	void Construct()
	{
		TimeOfDayManager = UTimeOfDayManagerComponent::Get(Gameplay::GetGameMode());
	}

	UFUNCTION(BlueprintOverride)
	void Tick(FGeometry MyGeometry, float InDeltaTime)
	{
		TimeText.SetText(TimeOfDay::GetTimeText(TimeOfDayManager.GetTimeOfDay()));
	}
};
