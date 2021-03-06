import Character.CharacterComponent;
import Character.RelationshipComponent;
import Components.HealthComponent;
import HUD.MMHUD;


UCLASS(Abstract)
class AMMPlayerController : APlayerController
{
	UPROPERTY(DefaultComponent)
	UCharacterComponent Character;

	UPROPERTY(DefaultComponent)
	URelationshipComponent Relationship;

	private AMMHUD MMHUD;


	UFUNCTION(BlueprintOverride)
	void ReceivePossess(APawn PossessedPawn)
	{
		auto HealthComponent = UHealthComponent::Get(PossessedPawn);
		HealthComponent.OnDied.AddUFunction(this, n"Died");

		MMHUD = Cast<AMMHUD>(GetHUD());
		MMHUD.ReceivePossess(PossessedPawn);
	}

	UFUNCTION(NotBlueprintCallable)
	private void Died(UHealthComponent HealthComponent)
	{
		Character.Died();
		MMHUD.AddNotification("You are dead.", 0.f);
		MMHUD.AddNotification("You were murdered!", 3.f);
	}
};
