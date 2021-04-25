namespace Desire
{
	const FConsoleVariable Debug("Desire.Debug", 0);
}


enum EDesire
{
	Drink,
	Eat,
	Murder,
	Sit,
	Sleep,
	Talk,
	Walk,
	MAX,
};


struct FPersonality
{
	FGameplayTagContainer Likes;
	FGameplayTagContainer Dislikes;

	float Animosity    = 0.5f;
	float Intelligence = 0.5f;
	float Laziness     = 0.5f;
	float Stamina      = 0.5f;
	float Politeness   = 0.5f;


	FPersonality(float Age)
	{
		Animosity    = FMath::RandRange(0.f, 1.f);
		Intelligence = FMath::RandRange(0.f, 1.f);
		Laziness     = FMath::RandRange(0.f, 1.f);
		Stamina      = FMath::RandRange(0.f, 1.f);
		Politeness   = FMath::RandRange(0.f, 1.f);
	}
};


namespace Desires
{
	const FName Anger   = n"Anger";
	const FName Boredom = n"Boredom";
	const FName Fatigue = n"Fatigue";
	const FName Hunger  = n"Hunger";
	const FName Thirst  = n"Thirst";
}


struct FDesireRequirement
{
	FName Name = NAME_None;
	private float Value = 0.f;
	private float IncrementRate = 0.f;

	FDesireRequirement(FName InName, float InIncrementRate)
	{
		Name = InName;
		Value = FMath::RandRange(0.f, 1.f);
		IncrementRate = InIncrementRate;
	}

	void Modify(float Amount)
	{
		Value = FMath::Clamp(Value + Amount, 0.f, 1.f);
	}

	float GetValue() const
	{
		return Value;
	}

	void Tick(float DeltaSeconds)
	{
		Value += DeltaSeconds * IncrementRate;
	}
};


struct FDesireRequirements
{
	TArray<FDesireRequirement> Requirements;


	FDesireRequirements(float Age)
	{
		Requirements.Add(FDesireRequirement(Desires::Anger, 0.01f));
		Requirements.Add(FDesireRequirement(Desires::Boredom, 0.01f));
		Requirements.Add(FDesireRequirement(Desires::Fatigue, 0.01f));
		Requirements.Add(FDesireRequirement(Desires::Hunger, 0.02f));
		Requirements.Add(FDesireRequirement(Desires::Thirst, 0.03f));
	}

	void Tick(float DeltaSeconds)
	{
		for (auto& Requirement : Requirements)
		{
			Requirement.Tick(DeltaSeconds);
		}
	}

	void Modify(FName DesireName, float Amount)
	{
		for (auto& Requirement : Requirements)
		{
			if (Requirement.Name == DesireName)
			{
				Requirement.Modify(Amount);
				return;
			}
		}
	}

	float GetValue(FName DesireName) const
	{
		for (const auto& Requirement : Requirements)
		{
			if (Requirement.Name == DesireName)
			{
				return Requirement.GetValue();
			}
		}
		return 0.f;
	}

	FString GetDisplayString() const
	{
		FString Result;
		for (const auto& Requirement : Requirements)
		{
			Result += "" + Requirement.Name + ": " + FMath::RoundToInt(Requirement.GetValue() * 100.f) + "%\n";
		}
		return Result;
	}
};
