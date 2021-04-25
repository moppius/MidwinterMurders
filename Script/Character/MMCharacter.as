import Character.CharacterComponent;
import Components.HealthComponent;
import HUD.CharacterInfoWidget;


UCLASS(Abstract)
class AMMCharacter : ACharacter
{
	default AutoPossessAI = EAutoPossessAI::Disabled;

	UPROPERTY(DefaultComponent)
	UHealthComponent HealthComponent;

	UPROPERTY(DefaultComponent)
	UPawnNoiseEmitterComponent NoiseEmitter;

	UPROPERTY(EditDefaultsOnly, Category=MidwinterMurdersCharacter)
	const TSubclassOf<UCharacterInfoWidget> CharacterWidgetClass;

	private UCharacterInfoWidget CharacterInfoWidget;


	UFUNCTION(BlueprintOverride)
	void Possessed(AController NewController)
	{
		HealthComponent.OnDied.AddUFunction(this, n"Died");

		if (NewController.IsA(APlayerController::StaticClass()))
		{
			return;
		}

		if (ensure(CharacterWidgetClass.IsValid()))
		{
			CharacterInfoWidget = Cast<UCharacterInfoWidget>(
				WidgetBlueprint::CreateWidget(CharacterWidgetClass.Get(), Gameplay::GetPlayerController(0))
			);
			CharacterInfoWidget.Setup(NewController);
			CharacterInfoWidget.AddToPlayerScreen();
		}
	}

	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaSeconds)
	{
		if (System::IsValid(CharacterInfoWidget))
		{
			CharacterInfoWidget.UpdateWidget(this);
		}
	}

	UFUNCTION(NotBlueprintCallable)
	private void Died(UHealthComponent HealthComponent)
	{
		MovementComponent.Deactivate();
		Mesh.SetCollisionEnabled(ECollisionEnabled::QueryAndPhysics);
		Mesh.SetPhysicsBlendWeight(1.f);
	}
};
