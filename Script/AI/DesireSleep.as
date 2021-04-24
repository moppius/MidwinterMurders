import AI.DesireSlotBase;
import AI.Utils;
import Tags;


class UDesireSleep : UDesireSlotBase
{
	default Type = EDesire::Sleep;
	default Tag = Tags::Bed;


	FString GetDisplayString() const override
	{
		return WithinRangeOfSlotActor() ? "Sleeping" : "Wants to sleep";
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
			DesireRequirements.Fatigue -= 0.1f * DeltaSeconds;
			if (DesireRequirements.Fatigue <= 0.1f)
			{
				Finish();
			}
		}
	}
};
