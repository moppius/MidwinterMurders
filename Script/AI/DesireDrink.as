import Actors.AreaVolumes;
import AI.DesireAreaBase;
import AI.Utils;
import Tags;


class UDesireDrink : UDesireAreaBase
{
	default Type = EDesire::Drink;
	default AreaTag = Tags::Drink;


	FString GetDisplayString() const override
	{
		return (bIsActive && IsOverlappingArea()) ? "Drinking" : "Wants to drink";
	}

	protected void Tick_Implementation(
		float DeltaSeconds,
		FDesireRequirements& DesireRequirements,
		const FPersonality& Personality) override
	{
		Weight = DesireRequirements.GetValue(Desires::Thirst);

		if (bIsActive && IsOverlappingArea())
		{
			DesireRequirements.Modify(Desires::Boredom, -0.01f * DeltaSeconds);
			DesireRequirements.Modify(Desires::Thirst, -0.1f * DeltaSeconds);

			bIsSatisfied = DesireRequirements.GetValue(Desires::Thirst) < 0.1f;
		}

		Super::Tick_Implementation(DeltaSeconds, DesireRequirements, Personality);
	}
};
