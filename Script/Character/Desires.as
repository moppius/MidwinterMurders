enum EDesire
{
	Eat,
	Drink,
	Talk,
	Sleep,
	Run,
	Fight,
};


struct FDesire
{
	FGameplayTag Tag;

	UPROPERTY()
	TMap<FGameplayTag, float> DesireRelationships;

	float DesireStrength = 0.f;
};
