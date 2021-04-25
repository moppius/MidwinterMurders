import AI.DesireBase;
import AI.Utils;
import Tags;


class UDesireDrink : UDesireBase
{
	default Type = EDesire::Drink;

	private TArray<AActor> AllDrinkAreas;


	protected void BeginPlay_Implementation(FDesireRequirements& DesireRequirements) override
	{
		Gameplay::GetAllActorsOfClassWithTag(ATriggerVolume::StaticClass(), Tags::Drink, AllDrinkAreas);
		ensure(AllDrinkAreas.Num() > 0, "No areas tagged as Drink!");
	}

	FString GetDisplayString() const override
	{
		return (bIsActive && IsOverlappingDrinkArea()) ? "Drinking" : "Wants to drink";
	}

	bool GetMoveLocation(FVector& OutLocation) const override
	{
		OutLocation = AIUtils::GetClosestActor(Controller.GetControlledPawn(), AllDrinkAreas).GetActorLocation();
		return true;
	}

	protected void Tick_Implementation(
		float DeltaSeconds,
		FDesireRequirements& DesireRequirements,
		const FPersonality& Personality) override
	{
		Weight = DesireRequirements.GetValue(Desires::Thirst);

		if (bIsActive && IsOverlappingDrinkArea())
		{
			DesireRequirements.Modify(Desires::Boredom, -0.01f * DeltaSeconds);
			DesireRequirements.Modify(Desires::Thirst, -0.1f * DeltaSeconds);

			bIsSatisfied = DesireRequirements.GetValue(Desires::Thirst) < 0.1f;
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
