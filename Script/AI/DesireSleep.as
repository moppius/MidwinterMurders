import AI.Desires;
import AI.Utils;
import Components.ActorSlotComponent;
import Tags;


class UDesireSleep : UDesireBase
{
	default Type = EDesire::Sleep;

	TArray<AActor> AllBedActors;
	private AActor ClosestAvailableBed;
	private bool bIsSleeping = false;
	private const float DistanceToBed = 200.f;


	void BeginPlay_Implementation(FDesireRequirements& DesireRequirements) override
	{
		Gameplay::GetAllActorsOfClassWithTag(AActor::StaticClass(), Tags::Bed, AllBedActors);
		if (AllBedActors.Num() == 0)
		{
			bIsFinished = true;
		}
	}

	FString GetDisplayString() const override
	{
		return WithinRangeOfBed() ? "Sleeping" : "Wants to sleep";
	}

	bool InhibitsMove() const override
	{
		return bIsSleeping || WithinRangeOfBed();
	}

	FVector GetMoveLocation() const override
	{
		return ClosestAvailableBed.GetActorLocation();
	}

	private void Tick_Implementation(
		float DeltaSeconds,
		FDesireRequirements& DesireRequirements,
		const FPersonality& Personality) override
	{
		Weight = DesireRequirements.Fatigue;
		if (!bIsSleeping)
		{
			ClosestAvailableBed = AIUtils::GetClosestActorWithAvailableSlot(Controller.GetControlledPawn(), AllBedActors);
		}

		if (WithinRangeOfBed())
		{
			auto SlotComponent = UActorSlotComponent::Get(ClosestAvailableBed);
			if (!bIsSleeping)
			{
				SlotComponent.OccupySlot(Controller.GetControlledPawn());
				bIsSleeping = true;
			}

			DesireRequirements.Fatigue -= 0.1f * DeltaSeconds;
			if (DesireRequirements.Fatigue <= 0.1f)
			{
				SlotComponent.VacateSlot(Controller.GetControlledPawn());
				bIsFinished = true;
			}
		}
		else
		{
			auto SlotComponent = UActorSlotComponent::Get(ClosestAvailableBed);
			SlotComponent.VacateSlot(Controller.GetControlledPawn());
			bIsSleeping = false;
		}
	}

	private bool WithinRangeOfBed() const
	{
		return Controller.GetControlledPawn().GetDistanceTo(ClosestAvailableBed) < DistanceToBed;
	}
};
