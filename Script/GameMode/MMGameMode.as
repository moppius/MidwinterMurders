import Character.MMAIController;
import GameMode.SpawnPoint;


class AMMGameMode : AGameModeBase
{
	UPROPERTY(EditDefaultsOnly, Category=Classes)
	const TSubclassOf<AMMAIController> DefaultAIControllerClass;


	private const int NumAICharacters = 10;
	private TArray<AMMAIController> CharacterAIs;


	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		for (int i = 0; i < NumAICharacters; i++)
		{
			CharacterAIs.Add(Cast<AMMAIController>(SpawnActor(DefaultAIControllerClass.Get())));
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
};
