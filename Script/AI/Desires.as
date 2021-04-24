enum EDesire
{
	None,
	Drink,
	Eat,
	Fight,
	Run,
	Sit,
	Sleep,
	Talk,
	Walk,
};


struct FPersonality
{
	FGameplayTagContainer Likes;
	FGameplayTagContainer Dislikes;

	float Intelligence = 0.5f;
	float Laziness = 0.5f;
	float Stamina = 0.5f;
	float Politeness = 0.5f;


	FPersonality(float Age)
	{
		Intelligence = FMath::RandRange(0.1f, 0.9f);
		Laziness = FMath::RandRange(0.1f, 0.9f);

		float MinStamina = 0.1f;
		float MaxStamina = 0.9f;
		Stamina = FMath::RandRange(MinStamina, MaxStamina);

		Politeness = FMath::RandRange(0.1f, 0.9f);
	}
};


struct FDesireRequirements
{
	float Boredom = 0.f;
	float Fatigue = 0.f;
	float Hunger = 0.f;
	float Thirst = 0.f;
	AActor FocusActor;


	FDesireRequirements(float Age)
	{
		Boredom = FMath::RandRange(0.f, 1.f);
		Fatigue = FMath::RandRange(0.f, 1.f);
		Hunger = FMath::RandRange(0.f, 1.f);
		Thirst = FMath::RandRange(0.f, 1.f);
	}

	void Tick(float DeltaSeconds)
	{
		Boredom = FMath::Clamp(Boredom + 0.01f * DeltaSeconds, 0.f, 1.f);
		Fatigue = FMath::Clamp(Fatigue + 0.01f * DeltaSeconds, 0.f, 1.f);
		Hunger  = FMath::Clamp(Hunger  + 0.02f * DeltaSeconds, 0.f, 1.f);
		Thirst  = FMath::Clamp(Thirst  + 0.04f * DeltaSeconds, 0.f, 1.f);
	}
};


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


namespace Desire
{
	const FConsoleVariable Debug("Desire.Debug", 0);
}
