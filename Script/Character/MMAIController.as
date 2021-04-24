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

	UFUNCTION(BlueprintOverride)
	void ReceivePossess(APawn PossessedPawn)
	{
		auto Movement = UCharacterMovementComponent::Get(PossessedPawn);
		Movement.MaxWalkSpeed *= FMath::GetMappedRangeValueClamped(
			FVector2D(18.f, 90.f),
			FVector2D(1.f, 0.2f),
			Character.Age
		);
	}
};
