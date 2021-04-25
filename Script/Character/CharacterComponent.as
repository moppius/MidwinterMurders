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

	void SeePawn(APawn Pawn)
	{
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
