import AI.DesireBase;


class UDesireWalk : UDesireBase
{
	default Type = EDesire::Walk;


	private const float AcceptanceRadius = 50.f;
	private bool bHasTarget = false;
	private FVector Target;


	FString GetDisplayString() const override
	{
		return bIsActive ? "Walking" : "Wants to walk";
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
		Weight = DesireRequirements.GetValue(Desires::Boredom) - DesireRequirements.GetValue(Desires::Fatigue);

		if (!bIsActive)
		{
			return;
		}

		DesireRequirements.Modify(Desires::Fatigue, 0.01f * (2.f - Personality.Stamina) * DeltaSeconds);
		DesireRequirements.Modify(Desires::Hunger, 0.01f * DeltaSeconds);
		DesireRequirements.Modify(Desires::Thirst, 0.01f * DeltaSeconds);

		if (!bHasTarget)
		{
			bHasTarget = UNavigationSystemV1::GetRandomLocationInNavigableRadius(
				Controller.GetControlledPawn().GetActorLocation(),
				Target,
				FMath::RandRange(500.f, 1500.f)
			);

			if (!bHasTarget)
			{
				bIsSatisfied = true;
				return;
			}
		}

		bIsSatisfied = (
			Controller.GetMoveStatus() == EPathFollowingStatus::Idle
			|| Controller.GetControlledPawn().GetActorLocation().Distance(Target) < AcceptanceRadius
		);
		if (bIsSatisfied)
		{
			bHasTarget = false;
		}
	}
};
