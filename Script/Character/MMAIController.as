import Character.RelationshipComponent;
import Character.CharacterComponent;


UCLASS(Abstract)
class AMMAIController : AAIController
{
	UPROPERTY(DefaultComponent)
	UCharacterComponent Character;

	UPROPERTY(DefaultComponent)
	URelationshipComponent Relationship;

	UPROPERTY(EditDefaultsOnly, Category=MidwinterMurdersAIController)
	UBehaviorTree BehaviorTree;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		RunBehaviorTree(BehaviorTree);
	}
};
