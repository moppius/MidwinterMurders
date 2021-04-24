import AI.Desires;


class UDesireSleep : UDesireBase
{
	default Type = EDesire::Sleep;


	private void Tick_Implementation(
		float DeltaSeconds,
		FDesireRequirements& DesireRequirements,
		const FPersonality& Personality) override
	{
		DesireRequirements.Fatigue -= 0.1f * DeltaSeconds;
		bIsFinished = DesireRequirements.Fatigue <= 0.1f;
	}
};
