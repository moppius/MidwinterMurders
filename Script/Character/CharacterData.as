class UCharacterNameDataAsset : UPrimaryDataAsset
{
	UPROPERTY()
	TArray<FString> MasculineNames;

	UPROPERTY()
	TArray<FString> FeminineNames;

	UPROPERTY()
	TArray<FString> NeutralNames;

	UPROPERTY()
	TArray<FString> FamilyNames;
};
