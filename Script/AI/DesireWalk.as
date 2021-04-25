import AI.DesireBase;


class UDesireWalk : UDesireBase
{
	default Type = EDesire::Walk;


	private bool bHasTarget = false;
	private FVector Target;


	FString GetDisplayString() const override
	{
		return "Walking";
	}

	FVector GetMoveLocation() const override
	{
		return Target;
	}

	protected void Tick_Implementation(
		float DeltaSeconds,
		FDesireRequirements& DesireRequirements,
		const FPersonality& Personality) override
	{
		DesireRequirements.Fatigue += 0.01f * (2.f - Personality.Stamina) * DeltaSeconds;
		DesireRequirements.Hunger += 0.01f * DeltaSeconds;
		DesireRequirements.Thirst += 0.01f * DeltaSeconds;

		if (!bHasTarget)
		{
			bHasTarget = UNavigationSystemV1::GetRandomLocationInNavigableRadius(
				Controller.GetControlledPawn().GetActorLocation(),
				Target,
				FMath::RandRange(500.f, 1500.f)
			);
		}
	}
};
