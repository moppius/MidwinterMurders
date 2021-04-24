enum EDesire
{
	Eat,
	Drink,
	Talk,
	Sleep,
	Run,
	Fight,
	Walk,
	Sit,
};


UCLASS(Abstract)
class UDesireBase
{
	protected EDesire Type;
	protected float Weight = 0.f;
	protected float Duration = 10.f;
	protected float TimeActive = 0.f;
	protected AAIController Controller;
	protected bool bIsFinished = false;

	void BeginPlay(AAIController InController) final
	{
		Controller = InController;
		BeginPlay_Implementation();
	}

	void Tick(float DeltaSeconds)
	{
		if (TimeActive < Duration)
		{
			TimeActive += DeltaSeconds;
			Tick_Implementation(DeltaSeconds);
		}
		else
		{
			bIsFinished = true;
		}
	}

	float GetModifier(EDesire OtherDesire) const
	{
		return 0.f;
	}

	bool IsFinished() const final
	{
		return bIsFinished;
	}

	float GetType() const final
	{
		return Type;
	}

	float GetWeight() const final
	{
		return Weight;
	}

	private void BeginPlay_Implementation()
	{
	}

	private void Tick_Implementation(float DeltaSeconds)
	{
		ensure(false, "You must implement Tick for a Desire!");
	}
};
