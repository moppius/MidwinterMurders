import AI.DesireFactory;
import AI.Desires;
import Character.CharacterData;
import Character.RelationshipComponent;
import Components.HealthComponent;


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

	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaSeconds)
	{
		if (AIController.GetControlledPawn() == nullptr || bIsDead)
		{
			return;
		}

		for (int i = Desires.Num(); i > 0; i--)
		{
			const int Index = i - 1;
			UDesireBase& Desire = Desires[Index];
			Desire.Tick(DeltaSeconds, DesireRequirements, Personality);
		}

		DesireRequirements.Tick(DeltaSeconds);
	}

	bool CanMove() const
	{
		for (auto Desire : Desires)
		{
			if (Desire.InhibitsMove())
			{
				return false;
			}
		}
		return Desires.Num() > 0;
	}

	FVector GetBestMoveLocation() const
	{
		UDesireBase HighestDesire;
		float HighestWeight = -MAX_flt;
		for (auto Desire : Desires)
		{
			const float Weight = Desire.GetWeight();
			if (Weight > HighestWeight)
			{
				HighestDesire = Desire;
				HighestWeight = Weight;
			}
		}
		return HighestDesire.GetMoveLocation();
	}

	float GetMaxWalkSpeedModifier() const
	{
		return FMath::GetMappedRangeValueClamped(FVector2D(18.f, 90.f), FVector2D(1.f, 0.2f), Age);
	}

	void SeePawn(APawn Pawn)
	{
		DesireRequirements.FocusActor = Pawn;
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
			for (auto Pawn : AllPawns)
			{
				if (Pawn.GetController().IsA(AAIController::StaticClass()))
				{
					auto HealthComponent = UHealthComponent::Get(Pawn);
					if (!HealthComponent.IsDead())
					{
						return Pawn;
					}
				}
			}
			return AllPawns[FMath::RandRange(0, AllPawns.Num() - 1)];
		}
		return nullptr;
	}

	void Died()
	{
		bIsDead = true;
		SetComponentTickEnabled(false);
	}
};
