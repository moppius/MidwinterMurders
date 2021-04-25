import AI.DesireSlotBase;
import AI.Utils;
import Components.TimeOfDayManager;
import Tags;


class UDesireSleep : UDesireSlotBase
{
	default Type = EDesire::Sleep;
	default Tag = Tags::Bed;

	private UTimeOfDayManagerComponent TimeOfDayManager;


	protected void BeginPlay_Implementation(FDesireRequirements& DesireRequirements) override
	{
		TimeOfDayManager = UTimeOfDayManagerComponent::Get(Gameplay::GetGameMode());
		Super::BeginPlay_Implementation(DesireRequirements);
	}

	FString GetDisplayString() const override
	{
		return (bIsActive && IsOccupyingSlot()) ? "Sleeping" : "Wants to sleep";
	}

	protected void Tick_Implementation(
		float DeltaSeconds,
		FDesireRequirements& DesireRequirements,
		const FPersonality& Personality) override
	{
		const float SleepyTime = FMath::Abs(TimeOfDayManager.GetTimeOfDay() - 0.5f) * 2.f - 0.5f;
		Weight = FMath::Clamp(DesireRequirements.GetValue(Desires::Fatigue) + SleepyTime, 0.f, 1.f);

		Super::Tick_Implementation(DeltaSeconds, DesireRequirements, Personality);
		if (!bIsActive)
		{
			return;
		}

		if (IsOccupyingSlot())
		{
			DesireRequirements.Modify(Desires::Fatigue, -0.05f * DeltaSeconds);
			bIsSatisfied = DesireRequirements.GetValue(Desires::Fatigue) + SleepyTime < 0.01f;
		}
	}
};
