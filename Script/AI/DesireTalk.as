import AI.DesireBase;


class UDesireTalk : UDesireBase
{
	default Type = EDesire::Talk;

	private const float TalkingDistance = 250.f;


	FString GetDisplayString() const override
	{
		FString String = bIsActive ? "Talking to " : "Wants to talk to ";
		return String + (System::IsValid(FocusActor) ? "" + FocusActor.GetName() : "nobody");
	}

	protected void Tick_Implementation(
		float DeltaSeconds,
		FDesireRequirements& DesireRequirements,
		const FPersonality& Personality) override
	{
		if (bIsActive)
		{
			DesireRequirements.Modify(Desires::Boredom, 0.01f * DeltaSeconds);
		}
	}
};
