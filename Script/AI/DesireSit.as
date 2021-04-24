import AI.DesireSlotBase;
import AI.Utils;
import Tags;


class UDesireSit : UDesireSlotBase
{
	default Type = EDesire::Sit;
	default Tag = Tags::Seat;


	FString GetDisplayString() const override
	{
		return WithinRangeOfSlotActor() ? "Sitting" : "Wants to sit";
	}

	protected void Tick_Implementation(
		float DeltaSeconds,
		FDesireRequirements& DesireRequirements,
		const FPersonality& Personality) override
	{
		Super::Tick_Implementation(DeltaSeconds, DesireRequirements, Personality);

		Weight = DesireRequirements.Fatigue;

		if (IsOccupyingSlot())
		{
			DesireRequirements.Fatigue -= 0.05f * (1.f + Personality.Stamina) * DeltaSeconds;
			DesireRequirements.Boredom += 0.1f * DeltaSeconds;

			if (DesireRequirements.Fatigue <= 0.1f || DesireRequirements.Boredom >= 0.5f)
			{
				Finish();
			}
		}
	}
};
