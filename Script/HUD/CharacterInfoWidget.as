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
		CharacterInfo.OnDesireAdded.AddUFunction(this, n"DesireAdded");
		CharacterInfo.OnDesireRemoved.AddUFunction(this, n"DesireRemoved");
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

	UFUNCTION(NotBlueprintCallable)
	private void DesireAdded(UCharacterComponent CharacterComponent, UDesireBase NewDesire)
	{
		ActiveDesires.Add(NewDesire);
	}

	UFUNCTION(NotBlueprintCallable)
	private void DesireRemoved(UCharacterComponent CharacterComponent, UDesireBase RemovedDesire)
	{
		ActiveDesires.Remove(RemovedDesire);
	}

	private void UpdateDesireText()
	{
		if (Desire::Debug.GetInt() > 0)
		{
			DesireText.SetVisibility(ESlateVisibility::SelfHitTestInvisible);
			FString DesireString;
			for (auto Desire : ActiveDesires)
			{
				DesireString += Desire.GetDisplayString() + "(" + Desire.GetWeight() + "), \n";
			}
			DesireText.SetText(FText::FromString(DesireString));
		}
		else
		{
			DesireText.SetVisibility(ESlateVisibility::Collapsed);
		}
	}
};
