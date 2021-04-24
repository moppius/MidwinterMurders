import AI.Desires;


class UDesireWalk : UDesireBase
{
	default Type = EDesire::Walk;


	private FVector Target;


	FString GetDisplayString() const override
	{
		return "Walking";
	}

	private void BeginPlay_Implementation(FDesireRequirements& DesireRequirements) override
	{
		if (DesireRequirements.FocusActor != nullptr
			&& DesireRequirements.FocusActor != Controller.GetControlledPawn())
		{
			Controller.MoveToActor(DesireRequirements.FocusActor);
			return;
		}

		const bool bFoundTarget = UNavigationSystemV1::GetRandomLocationInNavigableRadius(
			Controller.GetControlledPawn().GetActorLocation(),
			Target,
			FMath::RandRange(500.f, 1500.f)
		);
		if (!bFoundTarget)
		{
			Warning("Failed to find path to walk location!");
			bIsFinished = true;
		}
	}

	FVector GetMoveLocation() const override
	{
		return Target;
	}

	private void Tick_Implementation(
		float DeltaSeconds,
		FDesireRequirements& DesireRequirements,
		const FPersonality& Personality) override
	{
		DesireRequirements.Fatigue += 0.01f * (2.f - Personality.Stamina) * DeltaSeconds;
		DesireRequirements.Hunger += 0.01f * DeltaSeconds;
		DesireRequirements.Thirst += 0.01f * DeltaSeconds;

		if (Controller.GetMoveStatus() == EPathFollowingStatus::Idle)
		{
			bIsFinished = true;
		}
	}
};
