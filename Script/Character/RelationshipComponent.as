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
	private float Friendship = 0.f;

	FRelationship(AAIController InRelation, ERelationshipStatus InStatus)
	{
		Relation = InRelation;
		Status = InStatus;
		Friendship = FMath::RandRange(-1.f, 1.f);
	}

	float GetFriendship() const
	{
		return Friendship;
	}

	FString GetDebugString() const
	{
		return "" + Relation.GetName() + " is " + Status + ", with friendship " + Friendship;
	}
};


class URelationshipComponent : UActorComponent
{
	default PrimaryComponentTick.bStartWithTickEnabled = false;

	private TArray<FRelationship> Relationships;


	void SetRelationshipStatus(AAIController OtherAI, ERelationshipStatus Status)
	{
		Relationships.Add(FRelationship(OtherAI, Status));
	}

	bool GetRelationshipStatus(AAIController OtherAI, ERelationshipStatus& OutStatus) const
	{
		for (const auto& Relationship : Relationships)
		{
			if (Relationship.Relation == OtherAI)
			{
				OutStatus = Relationship.Status;
				return true;
			}
		}
		return false;
	}

#if TEST
	void Print() const
	{
		FString String;
		for (const auto& Relationship : Relationships)
		{
			String += Relationship.GetDebugString() + "\n";
		}
		Log(String);
	}
#endif
};


namespace Relationship
{
	void MakeRelation(AAIController FirstAI, AAIController SecondAI, ERelationshipStatus RelationshipStatus)
	{
		auto SecondRelation = URelationshipComponent::Get(SecondAI);
		ERelationshipStatus ExistingStatus;
		if (!SecondRelation.GetRelationshipStatus(FirstAI, ExistingStatus))
		{
			SecondRelation.SetRelationshipStatus(FirstAI, RelationshipStatus);
		}

		auto FirstRelation = URelationshipComponent::Get(FirstAI);
		if (FirstRelation.GetRelationshipStatus(SecondAI, ExistingStatus))
		{
			ERelationshipStatus InverseRelationshipStatus = RelationshipStatus;
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

	void MakeRandomRelation(AAIController FirstAI, AAIController SecondAI)
	{
		auto SecondRelation = URelationshipComponent::Get(SecondAI);
		ERelationshipStatus ExistingStatus;
		if (!SecondRelation.GetRelationshipStatus(FirstAI, ExistingStatus))
		{
			MakeRelation(FirstAI, SecondAI, ERelationshipStatus::Unrelated);
		}
	}
}
