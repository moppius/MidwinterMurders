import AI.Utils;
import AI.Desires;
import Tags;


class UDesireSit : UDesireBase
{
	default Type = EDesire::Sit;

	private TArray<AActor> AllSeatActors;
	private AActor ClosestAvailableSeat = nullptr;
	private UActorSlotComponent OccupiedSlot = nullptr;
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
		if (ClosestAvailableSeat == nullptr)
		{
			return Controller.GetControlledPawn().GetActorLocation();
		}
		return ClosestAvailableSeat.GetActorLocation();
	}

	private void Tick_Implementation(
		float DeltaSeconds,
		FDesireRequirements& DesireRequirements,
		const FPersonality& Personality) override
	{
		Weight = DesireRequirements.Fatigue;
		if (OccupiedSlot == nullptr)
		{
			ClosestAvailableSeat = AIUtils::GetClosestActorWithAvailableSlot(Controller.GetControlledPawn(), AllSeatActors);
		}

		if (WithinRangeOfSeat())
		{
			if (OccupiedSlot == nullptr)
			{
				OccupiedSlot = UActorSlotComponent::Get(ClosestAvailableSeat);
				if (OccupiedSlot == nullptr)
				{
					bIsFinished = true;
				}
			}

			OccupiedSlot.OccupySlot(Controller.GetControlledPawn());

			DesireRequirements.Fatigue -= 0.05f * (1.f + Personality.Stamina) * DeltaSeconds;
			DesireRequirements.Boredom += 0.1f * DeltaSeconds;

			if (DesireRequirements.Fatigue <= 0.1f || DesireRequirements.Boredom >= 0.5f)
			{
				OccupiedSlot.VacateSlot(Controller.GetControlledPawn());
				bIsFinished = true;
			}
		}
		else if (OccupiedSlot != nullptr)
		{
			OccupiedSlot.VacateSlot(Controller.GetControlledPawn());
			OccupiedSlot = nullptr;
		}
	}

	private bool WithinRangeOfSeat() const
	{
		if (ClosestAvailableSeat == nullptr)
		{
			return false;
		}
		return Controller.GetControlledPawn().GetDistanceTo(ClosestAvailableSeat) < DistanceToSit;
	}
};
