import AI.Desires;


UCLASS(Abstract)
class UDesireBase
{
	protected EDesire Type = EDesire::MAX;
	protected float Weight = 0.f;
	protected float TimeActive = 0.f;
	protected AAIController Controller;
	protected AActor FocusActor;
	protected bool bIsActive = false;
	protected bool bIsSatisfied = false;


	void BeginPlay(AAIController InController, FDesireRequirements& DesireRequirements) final
	{
		Controller = InController;
		BeginPlay_Implementation(DesireRequirements);
		ensure(Type != EDesire::MAX, "You must specify a desire type for " + Class.GetName() + "!");
	}

	void Tick(
		float DeltaSeconds,
		FDesireRequirements& DesireRequirements,
		const FPersonality& Personality)
	{
		TimeActive += DeltaSeconds;
		Tick_Implementation(DeltaSeconds, DesireRequirements, Personality);
		if (bIsActive && bIsSatisfied)
		{
			Deactivate();
		}
	}

	void Activate() final
	{
		if (Desire::Debug.GetInt() > 0)
		{
			Log("Activating " + Type);
		}
		bIsActive = true;
		bIsSatisfied = false;
	}

	private void Deactivate() final
	{
		if (Desire::Debug.GetInt() > 0)
		{
			Log("Deactivating " + Type);
		}
		bIsActive = false;
	}

	bool IsActive() final
	{
		return bIsActive;
	}

	bool IsSatisfied() final
	{
		return bIsSatisfied;
	}

	FString GetDisplayString() const
	{
		return "GetDisplayString() not implemented for " + Class.GetName();
	}

	FVector GetMoveLocation() const
	{
		ensure(false, "GetMoveLocation() not implemented for " + Class.GetName());
		return FVector::ZeroVector;
	}

	float GetDesireModifier(EDesire OtherDesire) const
	{
		return 0.f;
	}

	EDesire GetType() const final
	{
		return Type;
	}

	float GetWeight() const final
	{
		return Weight;
	}

	AActor GetFocusActor() const
	{
		return FocusActor;
	}

	private void BeginPlay_Implementation(FDesireRequirements& DesireRequirements)
	{
	}

	protected void Tick_Implementation(
		float DeltaSeconds,
		FDesireRequirements& DesireRequirements,
		const FPersonality& Personality)
	{
		ensure(false, "You must implement Tick for a Desire!");
	}
};
