import AI.DesireBase;
import Components.HealthComponent;


class UDesireMurder : UDesireBase
{
	default Type = EDesire::Murder;


	private const float AcceptanceRadius = 100.f;


	FString GetDisplayString() const override
	{
		FString String = InRangeOfTarget() ? "Murdering " : "Wants to murder ";
		return String + (System::IsValid(FocusActor) ? "" + FocusActor.GetName() : "nobody");
	}

	protected void Tick_Implementation(
		float DeltaSeconds,
		FDesireRequirements& DesireRequirements,
		const FPersonality& Personality) override
	{
		if (bIsActive)
		{
			CheckTargetHealth();
			if (InRangeOfTarget())
			{
				Gameplay::ApplyDamage(FocusActor, 50.f, Controller, Controller.GetControlledPawn(), UDamageType::StaticClass());
			}
		}
	}

	FVector GetMoveLocation() const override
	{
		return (FocusActor != nullptr ? FocusActor : Controller.GetControlledPawn()).GetActorLocation();
	}

	private bool InRangeOfTarget() const
	{
		return Controller.GetControlledPawn().GetDistanceTo(FocusActor) < AcceptanceRadius;
	}

	private void CheckTargetHealth()
	{
		if (FocusActor == nullptr)
		{
			return;
		}
		auto HealthComponent = UHealthComponent::Get(FocusActor);
		if (HealthComponent == nullptr || HealthComponent.IsDead())
		{
			bIsSatisfied = true;
		}
	}
};
