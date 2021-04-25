import AI.DesireBase;
import AI.Utils;


class UDesireTalk : UDesireBase
{
	default Type = EDesire::Talk;

	private const float AcceptanceRadius = 200.f;


	FString GetDisplayString() const override
	{
		FString String = bIsActive ? "Talking to " : "Wants to talk to ";
		return String + (System::IsValid(FocusActor) ? "" + FocusActor.GetName() : "nobody");
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

	protected void Tick_Implementation(
		float DeltaSeconds,
		FDesireRequirements& DesireRequirements,
		const FPersonality& Personality) override
	{
		Weight = DesireRequirements.GetValue(Desires::Boredom);

		if (bIsActive)
		{
			if (FocusActor != nullptr)
			{
				FocusActor = AIUtils::GetLivingPawn(Controller.GetControlledPawn());
			}

			DesireRequirements.Modify(Desires::Boredom, -0.01f * DeltaSeconds);
			bIsSatisfied = TimeActive > 5.f;
		}
	}
};
