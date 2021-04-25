import Components.HealthComponent;


class UAreaInfoComponent : UActorComponent
{
	UPROPERTY(Category=AreaInfo)
	const FString AreaName = "Default Area Name";

	UPROPERTY(EditConst, Category=AreaInfo)
	AAIController OwnerController;

	UPROPERTY(Category=AreaInfo)
	FGameplayTagContainer AreaTags;

	private TArray<APawn> ContainedPawns;
	private TArray<APawn> MurderedPawns;


	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		TArray<AActor> OverlappingActors;
		Owner.GetOverlappingActors(OverlappingActors, AActor::StaticClass());
		for (auto Actor : OverlappingActors)
		{
			if (Actor.IsA(APawn::StaticClass()))
			{
				ContainedPawns.Add(Cast<APawn>(Actor));
			}
		}

		Owner.OnActorBeginOverlap.AddUFunction(this, n"BeginOverlap");
		Owner.OnActorEndOverlap.AddUFunction(this, n"EndOverlap");
	}

	int GetNumMurdered() const
	{
		return MurderedPawns.Num();
	}

	UFUNCTION(NotBlueprintCallable)
	private void BeginOverlap(AActor OverlappedActor, AActor OtherActor)
	{
		if (OtherActor.IsA(APawn::StaticClass()))
		{
			ContainedPawns.Add(Cast<APawn>(OtherActor));
			auto HealthComponent = UHealthComponent::Get(OtherActor);
			HealthComponent.OnDied.AddUFunction(this, n"CharacterDied");
		}
	}

	UFUNCTION(NotBlueprintCallable)
	private void EndOverlap(AActor OverlappedActor, AActor OtherActor)
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
		MurderedPawns.Add(Cast<APawn>(HealthComponent.GetOwner()));
	}
};
