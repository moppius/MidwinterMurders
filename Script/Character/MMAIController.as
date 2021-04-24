import AI.DesireFactory;
import Character.RelationshipComponent;
import Character.CharacterComponent;


UCLASS(Abstract)
class AMMAIController : AAIController
{
	default ActorTickEnabled = true;

	UPROPERTY(DefaultComponent)
	UCharacterComponent Character;

	UPROPERTY(DefaultComponent)
	URelationshipComponent Relationship;

	TArray<UDesireBase> Desires;


	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaSeconds)
	{
		if (GetControlledPawn() == nullptr)
		{
			return;
		}

		for (int i = Desires.Num(); i > 0; i--)
		{
			Desires[i - 1].Tick(DeltaSeconds);
			if (Desires[i - 1].IsFinished())
			{
				Desires.RemoveAt(i - 1);
			}
		}
		if (Desires.Num() == 0)
		{
			AddNewDesire(EDesire::Walk);
		}
	}

	private void AddNewDesire(EDesire InDesire)
	{
		UDesireBase Desire = Desire::Create(InDesire);
		Desire.BeginPlay(this);
		Desires.Add(Desire);
	}
};
