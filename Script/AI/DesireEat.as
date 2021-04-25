import AI.DesireBase;
import AI.Utils;
import Tags;


class UDesireEat : UDesireBase
{
	default Type = EDesire::Eat;

	private TArray<AActor> AllFoodAreas;


	void BeginPlay_Implementation(FDesireRequirements& DesireRequirements) override
	{
		Gameplay::GetAllActorsOfClassWithTag(ATriggerVolume::StaticClass(), Tags::Food, AllFoodAreas);
		ensure(AllFoodAreas.Num() > 0, "No areas tagged as Food!");
	}

	FString GetDisplayString() const override
	{
		return (bIsActive && IsOverlappingFoodArea()) ? "Eating" : "Wants to eat";
	}

	protected void Tick_Implementation(
		float DeltaSeconds,
		FDesireRequirements& DesireRequirements,
		const FPersonality& Personality) override
	{
		Weight = DesireRequirements.GetValue(Desires::Hunger);

		if (bIsActive && IsOverlappingFoodArea())
		{
			DesireRequirements.Modify(Desires::Boredom, -0.01f * DeltaSeconds);
			DesireRequirements.Modify(Desires::Hunger, -0.1f * DeltaSeconds);
			DesireRequirements.Modify(Desires::Thirst, 0.01f * DeltaSeconds);

			bIsSatisfied = DesireRequirements.GetValue(Desires::Hunger) < 0.1f;
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
