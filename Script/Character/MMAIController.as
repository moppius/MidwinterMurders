import AI.DesireFactory;
import Character.RelationshipComponent;
import Character.CharacterComponent;
import Components.HealthComponent;


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
		auto HealthComponent = UHealthComponent::Get(PossessedPawn);
		HealthComponent.OnDied.AddUFunction(this, n"Died");

		auto Movement = UCharacterMovementComponent::Get(PossessedPawn);
		Movement.MaxWalkSpeed *= Character.GetMaxWalkSpeedModifier();
	}

	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaSeconds)
	{
		if (GetControlledPawn() == nullptr)
		{
			return;
		}

		if (Character.CanMove() && GetMoveStatus() == EPathFollowingStatus::Idle)
		{
			MoveToLocation(Character.GetBestMoveLocation());
		}

		if (Desire::Debug.GetInt() > 0 && GetMoveStatus() != EPathFollowingStatus::Idle)
		{
			System::DrawDebugSphere(GetImmediateMoveDestination(), 50.f, 12, FLinearColor::Blue);
			System::DrawDebugArrow(GetControlledPawn().GetActorLocation(), GetImmediateMoveDestination(), 10.f, FLinearColor::Blue);
		}
	}

	UFUNCTION(NotBlueprintCallable)
	private void Died(UHealthComponent HealthComponent)
	{
		Character.Died();
	}
};
