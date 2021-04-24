import AI.Desires;
import AI.Utils;
import Tags;


class UDesireEat : UDesireBase
{
	default Type = EDesire::Eat;

	private TArray<AActor> AllFoodAreas;


	void BeginPlay_Implementation(FDesireRequirements& DesireRequirements) override
	{
		Gameplay::GetAllActorsOfClassWithTag(ATriggerVolume::StaticClass(), Tags::Food, AllFoodAreas);
		if (!ensure(AllFoodAreas.Num() > 0, "No areas tagged as Food!"))
		{
			bIsFinished = true;
		}
	}

	FString GetDisplayString() const override
	{
		return CanBePerformed() ? "Eating" : "Wants to eat";
	}

	private void Tick_Implementation(
		float DeltaSeconds,
		FDesireRequirements& DesireRequirements,
		const FPersonality& Personality) override
	{
		if (IsOverlappingFoodArea())
		{
			DesireRequirements.Boredom -= 0.01f * DeltaSeconds;
			DesireRequirements.Hunger -= 0.1f * DeltaSeconds;
			if (DesireRequirements.Hunger <= 0.1f)
			{
				bIsFinished = true;
			}
		}
	}

	FVector GetMoveLocation() const override
	{
		return AIUtils::GetClosestActor(Controller.GetControlledPawn(), AllFoodAreas).GetActorLocation();
	}

	private bool IsOverlappingFoodArea() const
	{
		TArray<AActor> OverlappingActors;
		Controller.GetControlledPawn().GetOverlappingActors(OverlappingActors, ATriggerVolume::StaticClass());
		for (AActor Actor : OverlappingActors)
		{
			if (Actor.Tags.Contains(Tags::Food))
			{
				return true;
			}
		}
		return false;
	}
};
