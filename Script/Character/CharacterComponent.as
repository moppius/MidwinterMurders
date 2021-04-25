import AI.DesireFactory;
import AI.Desires;
import Character.CharacterData;
import Character.RelationshipComponent;
import Components.HealthComponent;


event void FOnDesireAddedSignature(UCharacterComponent CharacterComponent, UDesireBase NewDesire);
event void FOnDesireRemovedSignature(UCharacterComponent CharacterComponent, UDesireBase RemovedDesire);


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

	FOnDesireAddedSignature OnDesireAdded;
	FOnDesireRemovedSignature OnDesireRemoved;

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
	}

	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaSeconds)
	{
		if (AIController.GetControlledPawn() == nullptr || bIsDead)
		{
			return;
		}

		TArray<EDesire> ActiveDesires;
		for (int i = Desires.Num(); i > 0; i--)
		{
			const int Index = i - 1;
			UDesireBase& Desire = Desires[Index];
			Desire.Tick(DeltaSeconds, DesireRequirements, Personality);
			if (Desire.IsFinished())
			{
				OnDesireRemoved.Broadcast(this, Desire);
				// HACK: Desires array is somehow empty here at some point. Race condition with dying?
				if (Index < Desires.Num())
				{
					Desires.RemoveAt(Index);
				}
			}
			else
			{
				ActiveDesires.AddUnique(Desire.GetType());
			}
		}

		UpdateDesires(ActiveDesires);

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

	private void UpdateDesires(TArray<EDesire>& ActiveDesires)
	{
		auto Desire = GetNewDesire(ActiveDesires);
		while (Desire != EDesire::None)
		{
			auto DesireObject = Desire::Create(Desire);
			DesireObject.BeginPlay(AIController, DesireRequirements);
			ActiveDesires.AddUnique(Desire);
			Desires.Add(DesireObject);
			OnDesireAdded.Broadcast(this, DesireObject);
			Desire = GetNewDesire(ActiveDesires);
		}
	}

	private EDesire GetNewDesire(const TArray<EDesire>& ActiveDesires)
	{
		/*
		if (DesireRequirements.Anger >= 0.8f && !ActiveDesires.Contains(EDesire::Fight))
		{
			return EDesire::Fight;
		}
		*/
		if (DesireRequirements.Anger >= 1.f && !ActiveDesires.Contains(EDesire::Murder))
		{
			return EDesire::Murder;
		}
		if (DesireRequirements.Fatigue >= 1.f && !ActiveDesires.Contains(EDesire::Sleep))
		{
			return EDesire::Sleep;
		}
		if (DesireRequirements.Thirst >= 0.9f && !ActiveDesires.Contains(EDesire::Drink))
		{
			return EDesire::Drink;
		}
		if (DesireRequirements.Hunger >= 0.9f && !ActiveDesires.Contains(EDesire::Eat))
		{
			return EDesire::Eat;
		}
		if (DesireRequirements.Fatigue >= Personality.Laziness
			&& !ActiveDesires.Contains(EDesire::Sit) && !ActiveDesires.Contains(EDesire::Walk))
		{
			return EDesire::Sit;
		}
		if (DesireRequirements.Fatigue <= 0.1f
			&& !ActiveDesires.Contains(EDesire::Walk) && !ActiveDesires.Contains(EDesire::Sit))
		{
			return EDesire::Walk;
		}

		if (DesireRequirements.Boredom >= 0.5f)
		{
			DesireRequirements.FocusActor = GetNewFocusActor();
			DesireRequirements.Boredom = 0.f;
		}

		return Desires.Num() > 0 ? EDesire::None : EDesire::Walk;
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
		for (auto& Desire : Desires)
		{
			OnDesireRemoved.Broadcast(this, Desire);
		}
		Desires.Empty();
	}
};
