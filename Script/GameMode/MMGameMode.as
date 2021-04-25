import Character.MMAIController;
import Components.TimeOfDayManager;
import GameMode.SpawnPoint;


class AMMGameMode : AGameModeBase
{
	UPROPERTY(DefaultComponent)
	UTimeOfDayManagerComponent TimeOfDayManager;

	UPROPERTY(EditDefaultsOnly, Category=Classes)
	private const TSubclassOf<AMMAIController> DefaultAIControllerClass;

	UPROPERTY(EditDefaultsOnly, Category=GameMode)
	private const int MaxAICharacters = 12;


	private TArray<AMMAIController> CharacterAIs;


	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		while (ShouldAddMoreCharacters())
		{
			AddNewCharacter();
		}

		for (auto CharacterAI : CharacterAIs)
		{
			auto Pawn = Cast<APawn>(SpawnActor(DefaultPawnClass, FindSpawnLocation()));
			CharacterAI.Possess(Pawn);
		}
	}

	private bool ShouldAddMoreCharacters() const
	{
		return CharacterAIs.Num() < MaxAICharacters;
	}

	private FVector FindSpawnLocation()
	{
		auto SpawnPoints = SpawnPoint::GetBySpawnTag(NAME_None);
		if (SpawnPoints.Num() > 0)
		{
			const int SpawnIndex = FMath::RandRange(0, SpawnPoints.Num() - 1);
			return SpawnPoints[SpawnIndex].GetActorLocation();
		}
		return FVector::ZeroVector;
	}

	private void AddRelatedAIs(AMMAIController InAI)
	{
		// Give this AI a partner
		if (FMath::FRand() > 0.4f)
		{
			auto NewAI = AddNewCharacter();
			NewAI.Character.Age = FMath::Clamp(InAI.Character.Age + FMath::RandRange(-15, 15), 18.f, 90.f);
			if (FMath::FRand() > 0.4f)
			{
				NewAI.Character.CharacterName.FamilyName = InAI.Character.CharacterName.FamilyName;
			}
			Relationship::MakeRelation(InAI, NewAI, ERelationshipStatus::Partner);
		}
		// Give this AI a child
		if (InAI.Character.Age > 36.f)
		{
			float RandomChance = FMath::FRand();
			while (RandomChance > 0.6f && ShouldAddMoreCharacters())
			{
				auto NewAI = AddNewCharacter();
				NewAI.Character.Age = FMath::Clamp(InAI.Character.Age - FMath::RandRange(18, 90), 18.f, 90.f);
				NewAI.Character.CharacterName.FamilyName = InAI.Character.CharacterName.FamilyName;
				Relationship::MakeRelation(InAI, NewAI, ERelationshipStatus::Parent);
				RandomChance = FMath::FRand();
			}
		}
	}

	private AMMAIController AddNewCharacter()
	{
		auto NewAI = Cast<AMMAIController>(SpawnActor(DefaultAIControllerClass.Get()));
		CharacterAIs.Add(NewAI);
		PossessUnownedArea(NewAI);
		if (ShouldAddMoreCharacters())
		{
			AddRelatedAIs(NewAI);
		}
		return NewAI;
	}

	private void PossessUnownedArea(AMMAIController AIController)
	{
		TArray<ATriggerVolume> AllAreas;
		GetAllActorsOfClass(AllAreas);
		for (auto Area : AllAreas)
		{
			auto AreaInfo = UAreaInfoComponent::Get(Area);
			if (AreaInfo.OwnerController == nullptr)
			{
				AreaInfo.OwnerController = AIController;
				AIController.AddOwnedArea(AreaInfo);
				break;
			}
		}
	}
};
