import Character.CharacterComponent;
import Components.ActorSlotComponent;
import Components.HealthComponent;


class ASlotAreaVolume : ATriggerVolume
{
	private TArray<AActor> SlotActors;
	private TArray<APawn> ContainedPawns;
	private TArray<UCharacterComponent> MurderedCharacters;


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
			if (Actor.IsA(APawn::StaticClass()))
			{
				ContainedPawns.Add(Cast<APawn>(Actor));
			}
		}
	}

	UFUNCTION(BlueprintOverride)
	void ActorBeginOverlap(AActor OtherActor)
	{
		if (OtherActor.IsA(APawn::StaticClass()))
		{
			ContainedPawns.Add(Cast<APawn>(OtherActor));
			auto HealthComponent = UHealthComponent::Get(OtherActor);
			HealthComponent.OnDied.AddUFunction(this, n"CharacterDied");
		}
	}

	UFUNCTION(BlueprintOverride)
	void ActorEndOverlap(AActor OtherActor)
	{
		if (OtherActor.IsA(APawn::StaticClass()))
		{
			ContainedPawns.Remove(Cast<APawn>(OtherActor));
			auto HealthComponent = UHealthComponent::Get(OtherActor);
			HealthComponent.OnDied.UnbindObject(this);
		}
	}

	UFUNCTION(NotBlueprintCallable)
	private void CharacterDied(UHealthComponent HealthComponent)
	{
		auto Pawn = Cast<APawn>(HealthComponent.GetOwner());
		MurderedCharacters.Add(UCharacterComponent::Get(Pawn.GetController()));
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
