import Character.Desires;


class UCharacterComponent : UActorComponent
{
	ETextGender Gender = ETextGender::Neuter;

	FString FirstName;
	FString MiddleName;
	FString LastName;

	TMap<EDesire, float> Desires;
};
