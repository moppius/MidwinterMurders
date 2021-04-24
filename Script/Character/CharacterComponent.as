import Character.CharacterData;
import Character.Desires;


class UCharacterComponent : UActorComponent
{
	UPROPERTY(EditDefaultsOnly, Category=Character)
	const UCharacterNameDataAsset CharacterNameDataAsset;

	UPROPERTY(EditDefaultsOnly, Category=Character)
	ETextGender Gender = ETextGender::Neuter;

	UPROPERTY(EditDefaultsOnly, Category=Character)
	FCharacterName CharacterName;

	TMap<EDesire, float> Desires;


	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		SetGender();
		CharacterNameDataAsset.GenerateCharacterName(Gender, CharacterName);
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
};
