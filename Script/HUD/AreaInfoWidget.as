import Components.AreaInfoComponent;


UCLASS(Abstract)
class UAreaInfoWidget : UUserWidget
{
	UPROPERTY(Instanced, Meta=(BindWidget))
	private UTextBlock AreaInfoText;

	private APawn Pawn;

	void BindToPawn(APawn InPawn)
	{
		Pawn = InPawn;

		Pawn.OnActorBeginOverlap.AddUFunction(this, n"PawnBeginOverlap");
		Pawn.OnActorEndOverlap.AddUFunction(this, n"PawnEndOverlap");

		UpdateAreaText();
	}

	UFUNCTION(NotBlueprintCallable)
	private void PawnBeginOverlap(AActor OverlappedActor, AActor OtherActor)
	{
		auto AreaInfo = UAreaInfoComponent::Get(OtherActor);
		if (AreaInfo != nullptr)
		{
			UpdateAreaText();
		}
	}

	UFUNCTION(NotBlueprintCallable)
	private void PawnEndOverlap(AActor OverlappedActor, AActor OtherActor)
	{
		auto AreaInfo = UAreaInfoComponent::Get(OtherActor);
		if (AreaInfo != nullptr)
		{
			UpdateAreaText();
		}
	}

	private void UpdateAreaText()
	{
		TArray<AActor> OverlappingAreas;
		Pawn.GetOverlappingActors(OverlappingAreas, ATriggerVolume::StaticClass());
		FString AreaName = "Outside";
		float SmallestAreaSizeSquared = MAX_flt;
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
					AreaName = GetDisplayString(AreaInfo);
				}
			}
		}
		AreaInfoText.SetText(FText::FromString(AreaName));
	}

	private FString GetDisplayString(UAreaInfoComponent AreaInfo) const
	{
		FString AreaName = AreaInfo.AreaName;
		const int NumMurders = AreaInfo.GetNumMurdered();
		if (NumMurders == 1)
		{
			AreaName += " (1 murder)";
		}
		else if (NumMurders > 1)
		{
			AreaName += " (" + NumMurders + " murders)";
		}
		return AreaName;
	}
};
