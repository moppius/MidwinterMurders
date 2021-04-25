import Actors.AreaVolumes;
import AI.DesireBase;
import AI.Utils;
import Tags;


UCLASS(Abstract)
class UDesireAreaBase : UDesireBase
{
	default Type = EDesire::Drink;

	protected FName AreaTag = NAME_None;
	private TArray<AActor> AllTaggedAreas;
	private UActorSlotComponent OccupiedSlot = nullptr;


	protected void BeginPlay_Implementation(FDesireRequirements& DesireRequirements) override
	{
		Gameplay::GetAllActorsOfClassWithTag(ATriggerVolume::StaticClass(), AreaTag, AllTaggedAreas);
		ensure(AllTaggedAreas.Num() > 0, "No areas tagged as " + AreaTag + "!");
	}

	bool GetMoveLocation(FVector& OutLocation) const override
	{
		float ClosestDistanceSquared = MAX_flt;
		ASlotAreaVolume ClosestArea = nullptr;
		for (auto Area : AllTaggedAreas)
		{
			auto SlotArea = Cast<ASlotAreaVolume>(Area);
			if (SlotArea.GetClosestAvailableSlot(Controller.GetControlledPawn(), OutLocation))
			{
				const float DistanceSquared = OutLocation.DistSquared(Controller.GetControlledPawn().GetActorLocation());
				if (DistanceSquared < ClosestDistanceSquared)
				{
					ClosestDistanceSquared = DistanceSquared;
					ClosestArea = SlotArea;
				}
			}
		}
		return ClosestArea != nullptr;
	}

	protected void Tick_Implementation(
		float DeltaSeconds,
		FDesireRequirements& DesireRequirements,
		const FPersonality& Personality) override
	{
		if (bIsActive && IsOverlappingArea())
		{
			if (!bIsSatisfied && OccupiedSlot == nullptr)
			{
				TryOccupySlot();
			}

			if (bIsSatisfied && OccupiedSlot != nullptr)
			{
				OccupiedSlot.VacateSlot(Controller.GetControlledPawn());
				OccupiedSlot = nullptr;
			}
		}
	}

	private void TryOccupySlot()
	{
		TArray<AActor> ActorsToIgnore;
		TArray<AActor> OutActors;
		TArray<EObjectTypeQuery> ObjectTypes;
		ObjectTypes.Add(EObjectTypeQuery::WorldStatic);
		System::SphereOverlapActors(
			Controller.GetControlledPawn().GetActorLocation(),
			200.f, ObjectTypes, AActor::StaticClass(), ActorsToIgnore, OutActors
		);
		for (auto Actor : OutActors)
		{
			auto Slot = UActorSlotComponent::Get(Actor);
			if (Slot != nullptr && Slot.NumAvailableSlots() > 0)
			{
				OccupiedSlot = Slot;
				Slot.OccupySlot(Controller.GetControlledPawn());
				break;
			}
		}
	}

	protected bool IsOverlappingArea() const final
	{
		TArray<AActor> OverlappingActors;
		Controller.GetControlledPawn().GetOverlappingActors(OverlappingActors, ATriggerVolume::StaticClass());
		for (AActor Actor : OverlappingActors)
		{
			if (Actor.Tags.Contains(AreaTag))
			{
				return true;
			}
		}
		return false;
	}
};
