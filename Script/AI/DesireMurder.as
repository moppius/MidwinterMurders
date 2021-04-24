import AI.DesireBase;


class UDesireMurder : UDesireBase
{
	default Type = EDesire::Murder;


	private AActor TargetActor;
	private const float AcceptanceRadius = 100.f;


	FString GetDisplayString() const override
	{
		FString String = CanBePerformed() ? "Murdering " : "Wants to murder ";
		return String + (System::IsValid(TargetActor) ? "" + TargetActor.GetName() : "nobody");
	}

	private void BeginPlay_Implementation(FDesireRequirements& DesireRequirements) override
	{
		TargetActor = DesireRequirements.FocusActor;
		DesireRequirements.Boredom = 0.f;
	}

	protected void Tick_Implementation(
		float DeltaSeconds,
		FDesireRequirements& DesireRequirements,
		const FPersonality& Personality) override
	{
		if (Controller.GetControlledPawn().GetDistanceTo(TargetActor) <= AcceptanceRadius)
		{
			Gameplay::ApplyDamage(TargetActor, 50.f, Controller, Controller.GetControlledPawn(), UDamageType::StaticClass());
			bIsFinished = true;
		}
	}

	FVector GetMoveLocation() const override
	{
		return (TargetActor != nullptr ? TargetActor : Controller.GetControlledPawn()).GetActorLocation();
	}
};
