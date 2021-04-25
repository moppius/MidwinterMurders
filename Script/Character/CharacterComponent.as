import AI.DesireFactory;
import AI.Desires;
import Character.CharacterData;
import Character.RelationshipComponent;
import Components.HealthComponent;
import Components.AreaInfoComponent;


class UCharacterComponent : UActorComponent
{
	default ComponentTickEnabled = true;

	UPROPERTY(EditDefaultsOnly, Category=Character)
	const UCharacterNameDataAsset CharacterNameDataAsset;

	UPROPERTY(EditDefaultsOnly, Category=Character)
	ETextGender Gender = ETextGender::Neuter;

	UPROPERTY(EditDefaultsOnly, Category=Character)
	FCharacterName CharacterName;

	UPROPERTY(EditDefaultsOnly, Category=Character)
	float Age = 0.f;

	private FPersonality Personality;
	private FDesireRequirements DesireRequirements;

	private TArray<UDesireBase> Desires;
	private UDesireBase HighestDesire;

	private TArray<UAreaInfoComponent> OwnedAreas;
	private AAIController AIController;
	private bool bIsDead = false;

	private TMap<FName, float> SenseTagMemory;


	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		AIController = Cast<AAIController>(GetOwner());
		if (AIController == nullptr)
		{
			SetComponentTickEnabled(false);
			return;
		}

		Age = FMath::RandRange(18.f, 90.f);
		SetGender();
		CharacterNameDataAsset.GenerateCharacterName(Gender, CharacterName);

		Personality = FPersonality(Age);
		DesireRequirements = FDesireRequirements(Age);

		for (int i = 0; i < int(EDesire::MAX); i++)
		{
			auto NewDesire = Desire::Create(EDesire(i));
			if (NewDesire != nullptr)
			{
				NewDesire.BeginPlay(AIController, DesireRequirements);
				Desires.Add(NewDesire);
			}
		}
	}

	const TArray<UDesireBase>& GetDesires() const
	{
		return Desires;
	}

	const FDesireRequirements& GetDesireRequirements() const
	{
		return DesireRequirements;
	}

	void AddOwnedArea(UAreaInfoComponent InAreaInfo)
	{
		OwnedAreas.Add(InAreaInfo);
	}

	void HearStimulus(AActor Actor, FAIStimulus Stimulus)
	{
		SenseTagMemory.Add(Stimulus.Tag, 60.f);
		if (Stimulus.Tag == Tags::PainScream)
		{
			DesireRequirements.Modify(Desires::Fear, 0.25f);
		}
		else if (Stimulus.Tag == Tags::DeathScream)
		{
			DesireRequirements.Modify(Desires::Fear, 0.5f);
		}
	}

	void SeeStimulus(AActor Actor, FAIStimulus Stimulus)
	{
		SenseTagMemory.Add(Stimulus.Tag, 60.f);
		auto HealthComponent = UHealthComponent::Get(Actor);
		if (HealthComponent != nullptr && HealthComponent.IsDead())
		{
			DesireRequirements.Modify(Desires::Fear, 0.5f);
		}
	}

	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaSeconds)
	{
		if (AIController.GetControlledPawn() == nullptr || bIsDead)
		{
			return;
		}

		float HighestDesireWeight = -MAX_flt;
		UDesireBase HighestNewDesire = nullptr;
		for (int i = Desires.Num(); i > 0; i--)
		{
			const int Index = i - 1;
			UDesireBase& Desire = Desires[Index];
			Desire.Tick(DeltaSeconds, DesireRequirements, Personality);
			if (Desire.GetWeight() > HighestDesireWeight)
			{
				HighestDesireWeight = Desire.GetWeight();
				HighestNewDesire = Desire;
			}
			if (Desire.IsActive())
			{
				HighestDesireWeight = MAX_flt;
				HighestNewDesire = nullptr;
			}
		}
		if (HighestNewDesire != nullptr)
		{
			HighestNewDesire.Activate();
			HighestDesire = HighestNewDesire;
		}

		DesireRequirements.Tick(DeltaSeconds);

		TArray<FName> RemoveTags;
		for (auto& It : SenseTagMemory)
		{
			It.SetValue(It.GetValue() - DeltaSeconds);
			if (It.GetValue() <= 0.f)
			{
				RemoveTags.Add(It.GetKey());
			}
		}
		for (auto Tag : RemoveTags)
		{
			SenseTagMemory.Remove(Tag);
		}
	}

	bool GetMoveLocation(FVector& OutLocation) const
	{
		if (HighestDesire != nullptr)
		{
			return HighestDesire.GetMoveLocation(OutLocation);
		}
		return false;
	}

	float GetMaxWalkSpeedModifier() const
	{
		return FMath::GetMappedRangeValueClamped(FVector2D(18.f, 90.f), FVector2D(1.f, 0.2f), Age);
	}

	private void SetGender()
	{
		const int GenderIndex = FMath::RandRange(0, 12);
		Gender = ETextGender::Neuter;
		if (GenderIndex < 5)
		{
			Gender = ETextGender::Feminine;
		}
		else if (GenderIndex < 10)
		{
			Gender = ETextGender::Masculine;
		}
	}

	void Died()
	{
		bIsDead = true;
		SetComponentTickEnabled(false);
	}
};
