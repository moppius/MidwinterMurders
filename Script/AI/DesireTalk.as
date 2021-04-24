import AI.Desires;


class UDesireTalk : UDesireBase
{
	default Type = EDesire::Talk;


	private AActor TargetActor;
	private const float TalkingDistance = 250.f;

	bool CanBePerformed() const override
	{
		return Controller.GetControlledPawn().GetDistanceTo(TargetActor) <= TalkingDistance;
	}

	FString GetDisplayString() const override
	{
		FString String = CanBePerformed() ? "Talking to " : "Wants to talk to ";
		return String + (System::IsValid(TargetActor) ? "" + TargetActor.GetName() : "nobody");
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
