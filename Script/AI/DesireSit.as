import AI.Utils;
import AI.Desires;
import Tags;


class UDesireSit : UDesireBase
{
	default Type = EDesire::Sit;

	private TArray<AActor> AllSeatActors;
	private AActor ClosestSeat;
	private const float DistanceToSit = 200.f;


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
		return WithinRangeOfSeat() ? "Sitting" : "Wants to sit";
	}

	bool InhibitsMove() const override
	{
		return WithinRangeOfSeat();
	}

	FVector GetMoveLocation() const override
	{
		return ClosestSeat.GetActorLocation();
	}

	private void Tick_Implementation(
		float DeltaSeconds,
		FDesireRequirements& DesireRequirements,
		const FPersonality& Personality) override
	{
		Weight = DesireRequirements.Fatigue;
		ClosestSeat = AIUtils::GetClosestActor(Controller.GetControlledPawn(), AllSeatActors);

		if (WithinRangeOfSeat())
		{
			DesireRequirements.Fatigue -= 0.05f * (1.f + Personality.Stamina) * DeltaSeconds;
			DesireRequirements.Boredom += 0.1f * DeltaSeconds;

			if (DesireRequirements.Fatigue <= 0.1f || DesireRequirements.Boredom >= 0.5f)
			{
				bIsFinished = true;
			}
		}
	}

	private bool WithinRangeOfSeat() const
	{
		const float Distance = Controller.GetControlledPawn().GetDistanceTo(ClosestSeat);
		return Distance < DistanceToSit;
	}
};
