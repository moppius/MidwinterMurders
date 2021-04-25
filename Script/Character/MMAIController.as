import AI.DesireFactory;
import Character.CharacterComponent;
import Character.RelationshipComponent;
import Components.HealthComponent;
import HUD.MMHUD;


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
		AMMHUD HUD = Cast<AMMHUD>(Gameplay::GetPlayerController(0).GetHUD());
		HUD.AddNotification(Character.CharacterName.GetFullName() + " was murdered!", 3.f);
	}
};
