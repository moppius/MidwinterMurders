import AI.Utils;
import AI.Desires;
import Tags;


class UDesireSit : UDesireBase
{
	default Type = EDesire::Sit;

	private TArray<AActor> AllSeatActors;


	void BeginPlay_Implementation(FDesireRequirements& DesireRequirements) override
	{
		Gameplay::GetAllActorsOfClassWithTag(AActor::StaticClass(), Tags::Seat, AllSeatActors);
		if (AllSeatActors.Num() == 0)
		{
			bIsFinished = true;
		}
	}

	FString GetDisplayString() const override
	{
		return "Sitting";
	}

	FVector GetMoveLocation() const override
	{
		return AIUtils::GetClosestActor(Controller.GetControlledPawn(), AllSeatActors).GetActorLocation();
	}

	private void Tick_Implementation(
		float DeltaSeconds,
		FDesireRequirements& DesireRequirements,
		const FPersonality& Personality) override
	{
		DesireRequirements.Fatigue -= 0.05f * (1.f + Personality.Stamina) * DeltaSeconds;
		DesireRequirements.Boredom += 0.1f * DeltaSeconds;

		if (DesireRequirements.Fatigue <= 0.1f || DesireRequirements.Boredom >= 0.5f)
		{
			bIsFinished = true;
		}
	}
};
