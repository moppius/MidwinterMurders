import AI.DesireSlotBase;
import AI.Utils;
import Tags;


class UDesireSit : UDesireSlotBase
{
	default Type = EDesire::Sit;
	default Tag = Tags::Seat;


	FString GetDisplayString() const override
	{
		return (bIsActive && WithinRangeOfSlotActor()) ? "Sitting" : "Wants to sit";
	}

	protected void Tick_Implementation(
		float DeltaSeconds,
		FDesireRequirements& DesireRequirements,
		const FPersonality& Personality) override
	{
		Weight = DesireRequirements.GetValue(Desires::Fatigue);

		Super::Tick_Implementation(DeltaSeconds, DesireRequirements, Personality);

		if (bIsActive && IsOccupyingSlot())
		{
			DesireRequirements.Modify(Desires::Fatigue, -0.05f * (1.f + Personality.Stamina) * DeltaSeconds);
			DesireRequirements.Modify(Desires::Boredom, 0.1f * DeltaSeconds);

			bIsSatisfied = DesireRequirements.GetValue(Desires::Fatigue) < 0.2f;
		}
	}
};
