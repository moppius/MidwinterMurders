struct FCharacterName
{
	UPROPERTY()
	FString FirstName;

	UPROPERTY()
	FString MiddleName;

	UPROPERTY()
	FString FamilyName;


	FString GetFullName() const
	{
		if (MiddleName.IsEmpty())
		{
			return FirstName + " " + FamilyName;
		}
		return FirstName + " " + MiddleName + " " + FamilyName;
	}
};


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


	void GenerateCharacterName(ETextGender Gender, FCharacterName& OutCharacterName) const
	{
		OutCharacterName.FamilyName = FamilyNames[FMath::RandRange(0, FamilyNames.Num() - 1)];
		switch (Gender)
		{
			case ETextGender::Feminine:
				OutCharacterName.FirstName = FeminineNames[FMath::RandRange(0, FeminineNames.Num() - 1)];
				break;
			case ETextGender::Masculine:
				OutCharacterName.FirstName = MasculineNames[FMath::RandRange(0, MasculineNames.Num() - 1)];
				break;
			case ETextGender::Neuter:
			default:
				OutCharacterName.FirstName = NeutralNames[FMath::RandRange(0, NeutralNames.Num() - 1)];
		}
	}
};
