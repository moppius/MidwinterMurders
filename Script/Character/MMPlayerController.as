import Character.CharacterComponent;
import Character.RelationshipComponent;
import Components.HealthComponent;


UCLASS(Abstract)
class AMMPlayerController : APlayerController
{
	UPROPERTY(DefaultComponent)
	UCharacterComponent Character;

	UPROPERTY(DefaultComponent)
	URelationshipComponent Relationship;


	UFUNCTION(BlueprintOverride)
	void ReceivePossess(APawn PossessedPawn)
	{
		auto HealthComponent = UHealthComponent::Get(PossessedPawn);
		HealthComponent.OnDied.AddUFunction(this, n"Died");
	}

	UFUNCTION(NotBlueprintCallable)
	private void Died(UHealthComponent HealthComponent)
	{
		Warning("YOU DIED!");
		System::QuitGame(this, EQuitPreference::Quit, true);
	}
};
