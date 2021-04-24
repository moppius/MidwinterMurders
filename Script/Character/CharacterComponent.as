import AI.DesireFactory;
import AI.Desires;
import Character.CharacterData;


event void FOnDesireChangedSignature(UCharacterComponent CharacterComponent, UDesireBase NewDesire);


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

	FOnDesireChangedSignature OnDesireChanged;

	FPersonality Personality;
	FDesireRequirements DesireRequirements;

	private TArray<UDesireBase> Desires;

	private AAIController AIController;


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
	}

	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaSeconds)
	{
		if (AIController.GetControlledPawn() == nullptr)
		{
			return;
		}

		for (int i = Desires.Num(); i > 0; i--)
		{
			const int Index = i - 1;
			UDesireBase& Desire = Desires[Index];
			Desire.Tick(DeltaSeconds, DesireRequirements, Personality);
			if (Desire.IsFinished())
			{
				Desires.RemoveAt(Index);
			}
		}
		if (Desires.Num() == 0)
		{
			AddNewDesire();
		}

		DesireRequirements.Tick(DeltaSeconds);
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

	private void AddNewDesire()
	{
		const auto Desire = UpdateDesire();
		auto DesireObject = Desire::Create(Desire);
		DesireObject.BeginPlay(AIController, DesireRequirements);
		Desires.Add(DesireObject);
		OnDesireChanged.Broadcast(this, DesireObject);
	}

	private EDesire UpdateDesire()
	{
		if (DesireRequirements.Fatigue >= 1.f)
		{
			return EDesire::Sleep;
		}
		else if (DesireRequirements.Fatigue >= Personality.Laziness)
		{
			return EDesire::Sit;
		}
		if (DesireRequirements.Boredom >= 0.5f)
		{
			DesireRequirements.Boredom = 0.f;
			DesireRequirements.FocusActor = GetNewFocusActor();
		}
		return EDesire::Walk;
	}

	private AActor GetNewFocusActor() const
	{
		TArray<APawn> AllPawns;
		GetAllActorsOfClass(AllPawns);
		if (AllPawns.Num() > 0)
		{
			if (DesireRequirements.FocusActor != nullptr && DesireRequirements.FocusActor.IsA(APawn::StaticClass()))
			{
				AllPawns.Remove(Cast<APawn>(DesireRequirements.FocusActor));
			}
			return AllPawns[FMath::RandRange(0, AllPawns.Num() - 1)];
		}
		return nullptr;
	}
};
