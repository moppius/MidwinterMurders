class ASpawnPoint : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent DefaultSceneRoot;
	default DefaultSceneRoot.bVisualizeComponent = true;

	UPROPERTY(Category = SpawnPoint)
	FGameplayTagContainer SpawnTags;
};


namespace SpawnPoint
{
	TArray<ASpawnPoint> GetBySpawnTag(FName TagName)
	{
		TArray<ASpawnPoint> TaggedSpawns;
		GetAllActorsOfClass(TaggedSpawns);
		if (TagName != NAME_None)
		{
			const int NumSpawns = TaggedSpawns.Num();
			for (int i = NumSpawns; i > 0; i--)
			{
				if (!TaggedSpawns[i - 1].Tags.Contains(TagName))
				{
					TaggedSpawns.RemoveAt(i - 1);
				}
			}
		}
		return TaggedSpawns;
	}
}
