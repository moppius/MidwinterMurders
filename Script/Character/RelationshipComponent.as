enum ERelationshipStatus
{
	Unrelated,
	Parent,
	Child,
	Partner,
};


struct FRelationship
{
	AAIController Relation;
	ERelationshipStatus Status;

	FRelationship(AAIController InRelation, ERelationshipStatus InStatus)
	{
		Relation = InRelation;
		Status = InStatus;
	}
};


class URelationshipComponent : UActorComponent
{
	private TArray<FRelationship> Relationships;


	void SetRelationshipStatus(AAIController OtherAI, ERelationshipStatus Status)
	{
		if (ensure(GetRelationshipStatus(OtherAI) == ERelationshipStatus::Unrelated))
		{
			Relationships.Add(FRelationship(OtherAI, Status));
		}
	}

	ERelationshipStatus GetRelationshipStatus(AAIController OtherAI) const
	{
		for (const auto& Relationship : Relationships)
		{
			if (Relationship.Relation == OtherAI)
			{
				return Relationship.Status;
			}
		}
		return ERelationshipStatus::Unrelated;
	}
};


namespace Relationship
{
	void MakeRelation(AAIController FirstAI, AAIController SecondAI, ERelationshipStatus RelationshipStatus)
	{
		auto SecondRelation = URelationshipComponent::Get(SecondAI);
		if (SecondRelation.GetRelationshipStatus(FirstAI) == ERelationshipStatus::Unrelated)
		{
			SecondRelation.SetRelationshipStatus(FirstAI, RelationshipStatus);
		}

		auto FirstRelation = URelationshipComponent::Get(FirstAI);
		if (FirstRelation.GetRelationshipStatus(SecondAI) == ERelationshipStatus::Unrelated)
		{
			ERelationshipStatus InverseRelationshipStatus = ERelationshipStatus::Partner;
			if (RelationshipStatus == ERelationshipStatus::Parent)
			{
				InverseRelationshipStatus = ERelationshipStatus::Child;
			}
			else if (RelationshipStatus == ERelationshipStatus::Child)
			{
				InverseRelationshipStatus = ERelationshipStatus::Parent;
			}
			FirstRelation.SetRelationshipStatus(SecondAI, InverseRelationshipStatus);
		}
	}
}
