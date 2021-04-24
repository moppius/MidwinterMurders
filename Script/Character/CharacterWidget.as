import Character.CharacterComponent;

UCLASS(Abstract)
class UCharacterInfoWidget : UUserWidget
{
	UPROPERTY(NotEditable, Instanced, Meta = (BindWidget))
	private UTextBlock NameText;


	private const FVector CharacterInfoWidgetOffset = FVector(0.f, 0.f, 150.f);
	private const float InfoVisibilityDistance = 500.f;


	void Setup(AController InController)
	{
		auto CharacterInfo = UCharacterComponent::Get(InController);
		NameText.Text = FText::FromString(CharacterInfo.CharacterName.GetFullName());
	}

	void UpdateWidget(APawn OwningPawn)
	{
		auto PlayerPawn = Gameplay::GetPlayerPawn(0);
		if (PlayerPawn.GetDistanceTo(OwningPawn) > InfoVisibilityDistance)
		{
			SetVisibility(ESlateVisibility::Collapsed);
		}
		else
		{
			SetVisibility(ESlateVisibility::SelfHitTestInvisible);
			FVector2D ScreenPosition;
			WidgetLayout::ProjectWorldLocationToWidgetPosition(
				Gameplay::GetPlayerController(0),
				OwningPawn.GetActorLocation() + CharacterInfoWidgetOffset,
				ScreenPosition,
				true
			);
			SetPositionInViewport(ScreenPosition, false);
		}
	}
};
