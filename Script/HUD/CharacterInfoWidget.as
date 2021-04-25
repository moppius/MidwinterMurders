import Character.CharacterComponent;
import Components.HealthComponent;


UCLASS(Abstract)
class UCharacterInfoWidget : UUserWidget
{
	UPROPERTY(NotEditable, Instanced, Meta = (BindWidget))
	private UTextBlock NameText;

	UPROPERTY(NotEditable, Instanced, Meta = (BindWidget))
	private UTextBlock AgeText;

	UPROPERTY(NotEditable, Instanced, Meta = (BindWidget))
	private UTextBlock DesireText;


	private const FVector CharacterInfoWidgetOffset = FVector(0.f, 0.f, 150.f);
	private const float InfoVisibilityDistance = 1500.f;

	private TArray<UDesireBase> ActiveDesires;
	private bool bHasDied = false;


	void Setup(AController InController)
	{
		auto CharacterInfo = UCharacterComponent::Get(InController);
		NameText.SetText(FText::FromString(CharacterInfo.CharacterName.GetFullName()));
		AgeText.SetText(FText::FromString("Age " + FMath::TruncToInt(CharacterInfo.Age)));
		ActiveDesires = CharacterInfo.GetDesires();
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

			auto HealthComponent = UHealthComponent::Get(OwningPawn);
			if (!HealthComponent.IsDead())
			{
				UpdateDesireText();
			}
			else if (!bHasDied)
			{
				DesireText.SetVisibility(ESlateVisibility::Collapsed);
				AgeText.SetText(FText::FromString(AgeText.GetText().ToString() + " (DEAD)"));
				bHasDied = true;
			}
		}
	}

	private void UpdateDesireText()
	{
		if (Desire::Debug.GetInt() > 0)
		{
			DesireText.SetVisibility(ESlateVisibility::SelfHitTestInvisible);
			FString DesireString;
			for (auto Desire : ActiveDesires)
			{
				if (Desire.GetWeight() > 0.f)
				{
					const int DesirePercent = FMath::RoundToInt(Desire.GetWeight() * 100.f);
					DesireString += Desire.GetDisplayString() + " (" + DesirePercent + "%), \n";
				}
			}
			DesireText.SetText(FText::FromString(DesireString));
		}
		else
		{
			DesireText.SetVisibility(ESlateVisibility::Collapsed);
		}
	}
};
