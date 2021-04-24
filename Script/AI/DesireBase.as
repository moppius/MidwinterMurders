import AI.Desires;


UCLASS(Abstract)
class UDesireBase
{
	protected EDesire Type = EDesire::None;
	protected float Weight = 0.f;
	protected float TimeActive = 0.f;
	protected AAIController Controller;
	protected bool bIsFinished = false;


	void BeginPlay(AAIController InController, FDesireRequirements& DesireRequirements) final
	{
		Controller = InController;
		BeginPlay_Implementation(DesireRequirements);
		ensure(Type != EDesire::None, "You must specify a desire type for " + Class.GetName() + "!");
	}

	void Tick(
		float DeltaSeconds,
		FDesireRequirements& DesireRequirements,
		const FPersonality& Personality)
	{
		if (CanBePerformed() && !bIsFinished)
		{
			TimeActive += DeltaSeconds;
			Tick_Implementation(DeltaSeconds, DesireRequirements, Personality);
		}
	}

	bool CanBePerformed() const
	{
		return true;
	}

	bool InhibitsMove() const
	{
		return false;
	}

	FString GetDisplayString() const
	{
		return "GetDisplayString() not implemented for " + Class.GetName();
	}

	FVector GetMoveLocation() const
	{
		ensure(false, "GetMoveTarget() not implemented for " + Class.GetName());
		return FVector::ZeroVector;
	}

	float GetDesireModifier(EDesire OtherDesire) const
	{
		return 0.f;
	}

	bool IsFinished() const final
	{
		return bIsFinished;
	}

	EDesire GetType() const final
	{
		return Type;
	}

	float GetWeight() const final
	{
		return Weight;
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
