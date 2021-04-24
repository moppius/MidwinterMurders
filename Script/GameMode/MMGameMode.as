import Character.MMAIController;
import GameMode.SpawnPoint;


class AMMGameMode : AGameModeBase
{
	UPROPERTY(EditDefaultsOnly, Category=Classes)
	const TSubclassOf<AMMAIController> DefaultAIControllerClass;


	private const int MaxAICharacters = 10;
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
			while (RandomChance > 0.4f && ShouldAddMoreCharacters())
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
		AddRelatedAIs(NewAI);
		return NewAI;
	}
};
