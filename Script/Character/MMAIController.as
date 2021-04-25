import AI.DesireFactory;
import Character.CharacterComponent;
import Character.RelationshipComponent;
import Components.AreaInfoComponent;
import Components.HealthComponent;
import HUD.MMHUD;


namespace Sense
{
	const FConsoleVariable Debug("Sense.Debug", 0);
}


UCLASS(Abstract)
class AMMAIController : AAIController
{
	default ActorTickEnabled = true;

	UPROPERTY(DefaultComponent)
	UCharacterComponent Character;

	UPROPERTY(DefaultComponent)
	URelationshipComponent Relationship;

	UPROPERTY(DefaultComponent)
	UAIPerceptionComponent Perception;


	UFUNCTION(BlueprintOverride)
	void ReceivePossess(APawn PossessedPawn)
	{
		auto HealthComponent = UHealthComponent::Get(PossessedPawn);
		HealthComponent.OnDied.AddUFunction(this, n"Died");

		auto Movement = UCharacterMovementComponent::Get(PossessedPawn);
		Movement.MaxWalkSpeed *= Character.GetMaxWalkSpeedModifier();

		Perception.OnTargetPerceptionUpdated.AddUFunction(this, n"TargetPerceptionUpdated");
	}

	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaSeconds)
	{
		if (GetControlledPawn() == nullptr)
		{
			return;
		}

		if (GetMoveStatus() == EPathFollowingStatus::Idle)
		{
			FVector NewLocation;
			if (Character.GetMoveLocation(NewLocation))
			{
				MoveToLocation(NewLocation);
			}
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
		Perception.Deactivate();
		Perception.OnTargetPerceptionUpdated.Clear();

		Character.Died();
		AMMHUD HUD = Cast<AMMHUD>(Gameplay::GetPlayerController(0).GetHUD());
		HUD.AddNotification(Character.CharacterName.GetFullName() + " was murdered!", 3.f);
	}

	UFUNCTION(NotBlueprintCallable)
	private void TargetPerceptionUpdated(AActor Actor, FAIStimulus Stimulus)
	{
		if (Stimulus.Tag == Tags::PainScream)
		{
		}
		else if (Stimulus.Tag == Tags::DeathScream)
		{
		}
	}

	UFUNCTION(NotBlueprintCallable)
	private void SeePawn(APawn Pawn)
	{
		Character.SeePawn(Pawn);
		if (Sense::Debug.GetInt() > 0)
		{
			const FVector Start = GetControlledPawn().GetActorLocation();
			System::DrawDebugArrow(Start, Pawn.GetActorLocation(), 20.f, FLinearColor::Purple, 1.f);
		}
	}

	void AddOwnedArea(UAreaInfoComponent InAreaInfo)
	{
		Character.AddOwnedArea(InAreaInfo);
	}
};
