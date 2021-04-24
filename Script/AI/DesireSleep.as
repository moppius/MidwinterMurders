import AI.Desires;
import AI.Utils;
import Tags;


class UDesireSleep : UDesireBase
{
	default Type = EDesire::Sleep;

	private AActor ClosestBed;
	private const float DistanceToBed = 200.f;


	void BeginPlay_Implementation(FDesireRequirements& DesireRequirements) override
	{
		TArray<AActor> AllBedActors;
		Gameplay::GetAllActorsOfClassWithTag(AActor::StaticClass(), Tags::Bed, AllBedActors);
		if (AllBedActors.Num() == 0)
		{
			bIsFinished = true;
		}
		ClosestBed = AIUtils::GetClosestActor(Controller.GetControlledPawn(), AllBedActors);
	}

	FString GetDisplayString() const override
	{
		return WithinRangeOfBed() ? "Sleeping" : "Wants to sleep";
	}

	bool InhibitsMove() const override
	{
		return WithinRangeOfBed();
	}

	FVector GetMoveLocation() const override
	{
		return ClosestBed.GetActorLocation();
	}

	private void Tick_Implementation(
		float DeltaSeconds,
		FDesireRequirements& DesireRequirements,
		const FPersonality& Personality) override
	{
		DesireRequirements.Fatigue -= 0.1f * DeltaSeconds;
		bIsFinished = DesireRequirements.Fatigue <= 0.1f;
	}

	private bool WithinRangeOfBed() const
	{
		return Controller.GetControlledPawn().GetDistanceTo(ClosestBed) < DistanceToBed;
	}
};
