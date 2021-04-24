import AI.Desires;


class UDesireWalk : UDesireBase
{
	FVector Target;

	private void BeginPlay_Implementation() override
	{
		const float Distance = FMath::RandRange(1000.f, 2000.f);
		const FVector HeadingOffset = FRotator(FMath::RandRange(-180.f, 180.f), 0.f, 0.f).GetForwardVector();
		const FVector NewTarget = Controller.GetControlledPawn().GetActorLocation() + (HeadingOffset * Distance);
		if (!UNavigationSystemV1::ProjectPointToNavigation(NewTarget, Target, nullptr, nullptr))
		{
			bIsFinished = true;
			return;
		}
		Controller.MoveToLocation(Target);
	}

	private void Tick_Implementation(float DeltaSeconds) override
	{
		System::DrawDebugSphere(Target, 50.f, 12, FLinearColor::Blue);
		System::DrawDebugArrow(Controller.GetControlledPawn().GetActorLocation(), Target, 10.f, FLinearColor::Blue);
		if (Controller.GetMoveStatus() == EPathFollowingStatus::Idle)
		{
			bIsFinished = true;
		}
	}
};
