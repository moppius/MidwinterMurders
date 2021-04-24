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
		while (CharacterAIs.Num() < MaxAICharacters)
		{
			auto NewAI = Cast<AMMAIController>(SpawnActor(DefaultAIControllerClass.Get()));
			CharacterAIs.Add(NewAI);
			AddRelatedAIs(NewAI);
		}

		for (auto CharacterAI : CharacterAIs)
		{
			auto Pawn = Cast<APawn>(SpawnActor(DefaultPawnClass, FindSpawnLocation()));
			CharacterAI.Possess(Pawn);
		}
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

	void AddRelatedAIs(AMMAIController InAI)
	{
		// Partner
		if (FMath::FRand() > 0.4f)
		{
			AMMAIController NewAI = Cast<AMMAIController>(SpawnActor(DefaultAIControllerClass.Get()));
			NewAI.Character.Age = FMath::Clamp(InAI.Character.Age + FMath::RandRange(-15, 15), 18.f, 90.f);
			NewAI.Character.CharacterName.FamilyName = InAI.Character.CharacterName.FamilyName;
			Relationship::MakeRelation(InAI, NewAI, ERelationshipStatus::Partner);
		}
	}
};
