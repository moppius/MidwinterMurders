import AI.DesireAreaBase;
import AI.Utils;
import Tags;


class UDesireEat : UDesireAreaBase
{
	default Type = EDesire::Eat;
	default AreaTag = Tags::Food;


	FString GetDisplayString() const override
	{
		return (bIsActive && IsOverlappingArea()) ? "Eating" : "Wants to eat";
	}

	protected void Tick_Implementation(
		float DeltaSeconds,
		FDesireRequirements& DesireRequirements,
		const FPersonality& Personality) override
	{
		Weight = DesireRequirements.GetValue(Desires::Hunger);

		if (bIsActive && IsOverlappingArea())
		{
			DesireRequirements.Modify(Desires::Boredom, -0.01f * DeltaSeconds);
			DesireRequirements.Modify(Desires::Hunger, -0.1f * DeltaSeconds);
			DesireRequirements.Modify(Desires::Thirst, 0.01f * DeltaSeconds);

			bIsSatisfied = DesireRequirements.GetValue(Desires::Hunger) < 0.1f;
		}

		Super::Tick_Implementation(DeltaSeconds, DesireRequirements, Personality);
	}
};
