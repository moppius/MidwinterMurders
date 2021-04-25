import Components.ActorSlotComponent;
import Components.AreaInfoComponent;


class ASlotAreaVolume : ATriggerVolume
{
	UPROPERTY(DefaultComponent, ShowOnActor)
	UAreaInfoComponent AreaInfo;

	private TArray<AActor> SlotActors;


	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		SlotActors.Empty();
		TArray<AActor> ActorsToIgnore;
		TArray<AActor> OverlappingActors;
		TArray<EObjectTypeQuery> ObjectTypes;
		ObjectTypes.Add(EObjectTypeQuery::WorldStatic);
		System::BoxOverlapActors(
			BrushComponent.GetBoundsOrigin(), BrushComponent.GetBoundsExtent(),
			ObjectTypes, AActor::StaticClass(), ActorsToIgnore, OverlappingActors
		);
		for (auto Actor : OverlappingActors)
		{
			if (UActorSlotComponent::Get(Actor) != nullptr)
			{
				SlotActors.Add(Actor);
			}
		}
	}

	bool GetClosestAvailableSlot(AActor OtherActor, FVector& OutLocation) const
	{
		OutLocation = GetActorLocation();
		AActor ClosestAvailableActor;
		float ClosestDistanceSquared = MAX_flt;
		for (auto Actor : SlotActors)
		{
			auto SlotComponent = UActorSlotComponent::Get(Actor);
			if (SlotComponent.NumAvailableSlots() > 0)
			{
				const float DistanceSquared = Actor.GetSquaredDistanceTo(OtherActor);
				if (DistanceSquared < ClosestDistanceSquared)
				{
					ClosestDistanceSquared = DistanceSquared;
					ClosestAvailableActor = Actor;
				}
			}
		}
		if (ClosestAvailableActor != nullptr)
		{
			OutLocation = ClosestAvailableActor.GetActorLocation();
			return true;
		}
		return false;
	}

	int NumAvailableSlots() const
	{
		int Num = 0;
		for (auto Actor : SlotActors)
		{
			auto SlotComponent = UActorSlotComponent::Get(Actor);
			Num += SlotComponent.NumAvailableSlots();
		}
		return Num;
	}
};
