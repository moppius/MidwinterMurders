import AI.Desires;
import AI.Utils;
import Tags;


class UDesireDrink : UDesireBase
{
	default Type = EDesire::Drink;

	private TArray<AActor> AllDrinkAreas;


	void BeginPlay_Implementation(FDesireRequirements& DesireRequirements) override
	{
		Gameplay::GetAllActorsOfClassWithTag(ATriggerVolume::StaticClass(), Tags::Drink, AllDrinkAreas);
		if (!ensure(AllDrinkAreas.Num() > 0, "No areas tagged as Drink!"))
		{
			bIsFinished = true;
		}
	}

	FString GetDisplayString() const override
	{
		return IsOverlappingDrinkArea() ? "Drinking" : "Wants to drink";
	}

	FVector GetMoveLocation() const override
	{
		return AIUtils::GetClosestActor(Controller.GetControlledPawn(), AllDrinkAreas).GetActorLocation();
	}

	private void Tick_Implementation(
		float DeltaSeconds,
		FDesireRequirements& DesireRequirements,
		const FPersonality& Personality) override
	{
		if (IsOverlappingDrinkArea())
		{
			DesireRequirements.Boredom -= 0.01f * DeltaSeconds;
			DesireRequirements.Thirst -= 0.1f * DeltaSeconds;
			if (DesireRequirements.Thirst <= 0.1f)
			{
				bIsFinished = true;
			}
		}
	}

	private bool IsOverlappingDrinkArea() const
	{
		TArray<AActor> OverlappingActors;
		Controller.GetControlledPawn().GetOverlappingActors(OverlappingActors, ATriggerVolume::StaticClass());
		for (AActor Actor : OverlappingActors)
		{
			if (Actor.Tags.Contains(Tags::Drink))
			{
				return true;
			}
		}
		return false;
	}
};
