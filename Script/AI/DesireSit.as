import AI.Desires;


class UDesireSit : UDesireBase
{
	FText GetDisplayText() const override
	{
		return FText::FromString("Sitting");
	}

	private void Tick_Implementation(
		float DeltaSeconds,
		FDesireRequirements& DesireRequirements,
		const FPersonality& Personality) override
	{
		DesireRequirements.Fatigue -= 0.05f * (1.f + Personality.Stamina) * DeltaSeconds;
		DesireRequirements.Boredom += 0.1f * DeltaSeconds;

		if (DesireRequirements.Fatigue <= 0.1f || DesireRequirements.Boredom >= 0.5f)
		{
			bIsFinished = true;
		}
	}
};
