import Character.RelationshipComponent;
import Character.CharacterComponent;


class AMMAIController : AAIController
{
	UPROPERTY(DefaultComponent)
	UCharacterComponent Character;

	UPROPERTY(DefaultComponent)
	URelationshipComponent Relationship;
};
