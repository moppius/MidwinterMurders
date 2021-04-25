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
		TArray<AActor> OverlappingActors;
		GetOverlappingActors(OverlappingActors, AActor::StaticClass());
		for (auto Actor : OverlappingActors)
		{
			if (UActorSlotComponent::Get(Actor) != nullptr)
			{
				SlotActors.Add(Actor);
			}
		}
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
