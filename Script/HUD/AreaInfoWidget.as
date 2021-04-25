import Components.AreaInfoComponent;


UCLASS(Abstract)
class UAreaInfoWidget : UUserWidget
{
	UPROPERTY(Instanced, Meta=(BindWidget))
	private UTextBlock AreaInfoText;

	private UAreaInfoComponent CurrentAreaInfo;
	private APawn Pawn;

	void BindToPawn(APawn InPawn)
	{
		Pawn = InPawn;

		Pawn.OnActorBeginOverlap.AddUFunction(this, n"PawnBeginOverlap");
		Pawn.OnActorEndOverlap.AddUFunction(this, n"PawnEndOverlap");

		UpdateCurrentArea();
	}

	UFUNCTION(NotBlueprintCallable)
	private void PawnBeginOverlap(AActor OverlappedActor, AActor OtherActor)
	{
		auto AreaInfo = UAreaInfoComponent::Get(OtherActor);
		if (AreaInfo != nullptr)
		{
			UpdateCurrentArea();
		}
	}

	UFUNCTION(NotBlueprintCallable)
	private void PawnEndOverlap(AActor OverlappedActor, AActor OtherActor)
	{
		auto AreaInfo = UAreaInfoComponent::Get(OtherActor);
		if (AreaInfo != nullptr)
		{
			UpdateCurrentArea();
		}
	}

	private void UpdateCurrentArea()
	{
		TArray<AActor> OverlappingAreas;
		Pawn.GetOverlappingActors(OverlappingAreas, ATriggerVolume::StaticClass());

		float SmallestAreaSizeSquared = MAX_flt;
		CurrentAreaInfo = nullptr;
		for (auto Area : OverlappingAreas)
		{
			auto AreaInfo = UAreaInfoComponent::Get(Area);
			if (AreaInfo != nullptr)
			{
				FVector Origin;
				FVector BoxExtent;
				Area.GetActorBounds(true, Origin, BoxExtent);
				const float AreaSizeSquared = BoxExtent.SizeSquared();
				if (AreaSizeSquared < SmallestAreaSizeSquared)
				{
					SmallestAreaSizeSquared = AreaSizeSquared;
					CurrentAreaInfo = AreaInfo;
				}
			}
		}

		UpdateDisplayText();
	}

	private void UpdateDisplayText() const
	{
		if (CurrentAreaInfo == nullptr)
		{
			AreaInfoText.SetText(FText::FromString("Unknown Area"));
			return;
		}

		FString AreaName = CurrentAreaInfo.AreaName;
		const int NumMurders = CurrentAreaInfo.GetNumMurdered();
		if (NumMurders == 1)
		{
			AreaName += " (1 murder)";
		}
		else if (NumMurders > 1)
		{
			AreaName += " (" + NumMurders + " murders)";
		}
		AreaInfoText.SetText(FText::FromString(AreaName));
	}
};
