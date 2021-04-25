import AI.DesireBase;
import AI.Utils;
import Tags;


UCLASS(Abstract)
class UDesireSlotBase : UDesireBase
{
	protected FName Tag = NAME_None;
	protected float AcceptanceRadius = 80.f;

	private TArray<AActor> AllSlotActors;
	private AActor ClosestAvailableSlotActor = nullptr;
	private UActorSlotComponent OccupiedSlot = nullptr;


	protected void BeginPlay_Implementation(FDesireRequirements& DesireRequirements) override
	{
		AllSlotActors.Empty();
		TArray<AActor> AllTaggedActors;
		Gameplay::GetAllActorsOfClassWithTag(AActor::StaticClass(), Tag, AllTaggedActors);
		for (auto Actor : AllTaggedActors)
		{
			if (UActorSlotComponent::Get(Actor) != nullptr)
			{
				AllSlotActors.Add(Actor);
			}
		}
		ensure(AllSlotActors.Num() > 0, "No slot actors found for " + Type);
	}

	FVector GetMoveLocation() const override
	{
		if (ClosestAvailableSlotActor == nullptr)
		{
			return Controller.GetControlledPawn().GetActorLocation();
		}
		return ClosestAvailableSlotActor.GetActorLocation();
	}

	protected void Tick_Implementation(
		float DeltaSeconds,
		FDesireRequirements& DesireRequirements,
		const FPersonality& Personality) override
	{
		if (!bIsActive)
		{
			if (OccupiedSlot != nullptr)
			{
				OccupiedSlot.VacateSlot(Controller.GetControlledPawn());
				OccupiedSlot = nullptr;
			}
			return;
		}

		if (OccupiedSlot == nullptr)
		{
			AActor NewClosestAvailableSlotActor = AIUtils::GetClosestActorWithAvailableSlot(
				Controller.GetControlledPawn(),
				AllSlotActors
			);
			if (ClosestAvailableSlotActor != NewClosestAvailableSlotActor)
			{
				Controller.StopMovement();
				ClosestAvailableSlotActor = NewClosestAvailableSlotActor;
			}
		}

		if (WithinRangeOfSlotActor())
		{
			if (OccupiedSlot == nullptr)
			{
				OccupiedSlot = UActorSlotComponent::Get(ClosestAvailableSlotActor);
				if (OccupiedSlot == nullptr)
				{
					return;
				}
			}

			OccupiedSlot.OccupySlot(Controller.GetControlledPawn());
		}
		else if (OccupiedSlot != nullptr)
		{
			OccupiedSlot.VacateSlot(Controller.GetControlledPawn());
			OccupiedSlot = nullptr;
		}
	}

	protected bool IsOccupyingSlot() const final
	{
		return OccupiedSlot != nullptr;
	}

	protected bool WithinRangeOfSlotActor() const final
	{
		if (OccupiedSlot != nullptr)
		{
			return true;
		}
		if (ClosestAvailableSlotActor == nullptr)
		{
			return false;
		}
		const float Distance = Controller.GetControlledPawn().GetDistanceTo(ClosestAvailableSlotActor);
		FVector Origin;
		FVector BoxExtent;
		ClosestAvailableSlotActor.GetActorBounds(true, Origin, BoxExtent);
		BoxExtent.Z = FMath::Max(BoxExtent.X, BoxExtent.Y);
		return Distance - (BoxExtent.Size() * 2.f) < AcceptanceRadius;
	}
};
