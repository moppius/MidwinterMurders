import Character.CharacterComponent;
import Character.RelationshipComponent;


UCLASS(Abstract)
class AMMPlayerController : APlayerController
{
	UPROPERTY(DefaultComponent)
	UCharacterComponent Character;

	UPROPERTY(DefaultComponent)
	URelationshipComponent Relationship;
};
