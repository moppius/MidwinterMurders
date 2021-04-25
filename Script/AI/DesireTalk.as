import AI.DesireBase;


class UDesireTalk : UDesireBase
{
	default Type = EDesire::Talk;

	private const float TalkingDistance = 250.f;


	FString GetDisplayString() const override
	{
		FString String = "Talking to ";// CanBePerformed() ? "Talking to " : "Wants to talk to ";
		return String + (System::IsValid(FocusActor) ? "" + FocusActor.GetName() : "nobody");
	}

	private void BeginPlay_Implementation(FDesireRequirements& DesireRequirements) override
	{
		DesireRequirements.Modify(Desires::Boredom, -0.5f);
	}

	protected void Tick_Implementation(
		float DeltaSeconds,
		FDesireRequirements& DesireRequirements,
		const FPersonality& Personality) override
	{
		DesireRequirements.Modify(Desires::Boredom, 0.01f * DeltaSeconds);
	}
};
