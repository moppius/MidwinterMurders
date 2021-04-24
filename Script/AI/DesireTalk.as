import AI.Desires;


class UDesireTalk : UDesireBase
{
	AActor TargetActor;

	FText GetDisplayText() const override
	{
		if (System::IsValid(TargetActor))
		{
			return FText::FromString("Talking to " + TargetActor.GetName());
		}
		return FText::FromString("Talking to themself");
	}

	private void BeginPlay_Implementation(FDesireRequirements& DesireRequirements) override
	{
		TargetActor = DesireRequirements.FocusActor;
		DesireRequirements.Boredom -= 0.5f;
	}

	private void Tick_Implementation(
		float DeltaSeconds,
		FDesireRequirements& DesireRequirements,
		const FPersonality& Personality) override
	{
		DesireRequirements.Boredom += 0.01f * DeltaSeconds;
		if (DesireRequirements.Boredom >= Personality.Politeness)
		{
			bIsFinished = true;
		}
	}
};
