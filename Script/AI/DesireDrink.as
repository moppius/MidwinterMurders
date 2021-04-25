import Actors.AreaVolumes;
import AI.DesireBase;
import AI.Utils;
import Tags;


class UDesireDrink : UDesireBase
{
	default Type = EDesire::Drink;

	private TArray<AActor> AllDrinkAreas;
	private UActorSlotComponent OccupiedSlot = nullptr;


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
		float ClosestDistanceSquared = MAX_flt;
		ASlotAreaVolume ClosestArea = nullptr;
		for (auto Area : AllDrinkAreas)
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
		Weight = DesireRequirements.GetValue(Desires::Thirst);

		if (bIsActive && IsOverlappingDrinkArea())
		{
			if (OccupiedSlot == nullptr)
			{
				TryOccupySlot();
			}
			DesireRequirements.Modify(Desires::Boredom, -0.01f * DeltaSeconds);
			DesireRequirements.Modify(Desires::Thirst, -0.1f * DeltaSeconds);

			bIsSatisfied = DesireRequirements.GetValue(Desires::Thirst) < 0.1f;

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
