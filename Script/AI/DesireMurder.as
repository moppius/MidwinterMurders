import AI.DesireBase;
import AI.Utils;
import Components.HealthComponent;


class UDesireMurder : UDesireBase
{
	default Type = EDesire::Murder;

	private const float AcceptanceRadius = 100.f;


	FString GetDisplayString() const override
	{
		FString String = (bIsActive && InRangeOfTarget()) ? "Murdering " : "Wants to murder ";
		return String + (System::IsValid(FocusActor) ? "" + FocusActor.GetName() : "nobody");
	}

	protected void Tick_Implementation(
		float DeltaSeconds,
		FDesireRequirements& DesireRequirements,
		const FPersonality& Personality) override
	{
		Weight = DesireRequirements.GetValue(Desires::Anger);

		if (bIsActive)
		{
			if (FocusActor == nullptr)
			{
				FocusActor = AIUtils::GetLivingPawn(Controller.GetControlledPawn());
			}

			CheckTargetHealth();
			if (InRangeOfTarget())
			{
				Gameplay::ApplyDamage(FocusActor, 50.f, Controller, Controller.GetControlledPawn(), UDamageType::StaticClass());
			}

			if (bIsSatisfied)
			{
				DesireRequirements.Modify(Desires::Anger, -0.5f);
			}
		}
	}

	bool GetMoveLocation(FVector& OutLocation) const override
	{
		if (FocusActor != nullptr)
		{
			OutLocation = FocusActor.GetActorLocation();
			return true;
		}
		return false;
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
			FocusActor = nullptr;
		}
	}
};
