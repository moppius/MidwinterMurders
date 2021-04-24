namespace Desire
{
	const FConsoleVariable Debug("Desire.Debug", 0);
}


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


struct FDesireRequirements
{
	float Anger = 0.f;
	float Boredom = 0.f;
	float Fatigue = 0.f;
	float Hunger = 0.f;
	float Thirst = 0.f;
	AActor FocusActor;


	FDesireRequirements(float Age)
	{
		Anger = FMath::RandRange(0.f, 1.f);
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

		const float AngerMod = 1.f + Hunger + Thirst - Boredom;
		Anger   = FMath::Clamp(Anger   + 0.01f * AngerMod * DeltaSeconds, 0.f, 1.f);
	}
};
