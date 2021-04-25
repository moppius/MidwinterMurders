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
		if (!bIsActive)
		{
			return;
		}

		Weight = DesireRequirements.GetValue(Desires::Fatigue);

		if (IsOccupyingSlot())
		{
			DesireRequirements.Modify(Desires::Fatigue, -0.1f * DeltaSeconds);
			bIsSatisfied = DesireRequirements.GetValue(Desires::Fatigue) <= 0.1f;
		}
	}
};
