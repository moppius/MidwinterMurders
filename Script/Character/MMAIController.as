import AI.DesireFactory;
import Character.CharacterComponent;
import Character.RelationshipComponent;
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
	UPawnSensingComponent PawnSensing;
	default PawnSensing.PeripheralVisionAngle = 45.f;
	default PawnSensing.HearingThreshold = 6000.f;
	default PawnSensing.bOnlySensePlayers = false;


	UFUNCTION(BlueprintOverride)
	void ReceivePossess(APawn PossessedPawn)
	{
		auto HealthComponent = UHealthComponent::Get(PossessedPawn);
		HealthComponent.OnDied.AddUFunction(this, n"Died");

		auto Movement = UCharacterMovementComponent::Get(PossessedPawn);
		Movement.MaxWalkSpeed *= Character.GetMaxWalkSpeedModifier();

		PawnSensing.OnHearNoise.AddUFunction(this, n"HearNoise");
		PawnSensing.OnSeePawn.AddUFunction(this, n"SeePawn");
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
		PawnSensing.Deactivate();
		PawnSensing.OnHearNoise.Clear();
		PawnSensing.OnSeePawn.Clear();
		Character.Died();
		AMMHUD HUD = Cast<AMMHUD>(Gameplay::GetPlayerController(0).GetHUD());
		HUD.AddNotification(Character.CharacterName.GetFullName() + " was murdered!", 3.f);
	}

	UFUNCTION(NotBlueprintCallable)
	private void HearNoise(APawn InInstigator, FVector& Location, float Volume)
	{
		Log("" + GetName() + " heard noise!");
		//Character.InvestigateNoise(InInstigator, Location, Volume);
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
};
