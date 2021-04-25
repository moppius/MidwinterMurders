namespace Slots
{
	const FConsoleVariable Debug("Slots.Debug", 0);
	const FString SlotPrefix = "Slot";
}


struct FActorSlot
{
	private FName SocketName;
	private FTransform Transform;
	private FTransform OccupierArrivalTransform;
	private AActor Occupier;


	FActorSlot(FName InSocketName, FTransform InTransform)
	{
		SocketName = InSocketName;
		Transform = InTransform;
		OccupierArrivalTransform = FTransform::Identity;
		Occupier = nullptr;
	}

	void Occupy(AActor NewOccupier)
	{
		Occupier = NewOccupier;
		OccupierArrivalTransform = Occupier.GetActorTransform();
		auto Movement = UMovementComponent::Get(NewOccupier);
		Movement.Deactivate();
		Occupier.SetActorTransform(Transform);
	}

	bool TryVacate(AActor MaybeOccupier)
	{
		if (Occupier == MaybeOccupier)
		{
			auto Movement = UMovementComponent::Get(Occupier);
			Movement.Activate();
			Occupier.SetActorTransform(OccupierArrivalTransform);
			Occupier = nullptr;
			return true;
		}
		return false;
	}

	bool IsOccupied() const
	{
		return Occupier != nullptr;
	}
};


class UActorSlotComponent : UActorComponent
{
	private TArray<FActorSlot> Slots;
	private UStaticMeshComponent StaticMeshComponent;


	void PopulateSlots(UStaticMeshComponent InStaticMeshComponent)
	{
		StaticMeshComponent = InStaticMeshComponent;
		TArray<FName> SocketNames = StaticMeshComponent.GetAllSocketNames();
		for (FName SocketName : SocketNames)
		{
			if (SocketName.ToString().StartsWith(Slots::SlotPrefix))
			{
				Slots.Add(FActorSlot(SocketName, StaticMeshComponent.GetSocketTransform(SocketName)));
			}
		}
	}

	int NumAvailableSlots() const
	{
		int Num = 0;
		for (auto& Slot : Slots)
		{
			if (!Slot.IsOccupied())
			{
				Num++;
			}
		}
		return Num;
	}

	void OccupySlot(AActor InActor)
	{
		for (auto& Slot : Slots)
		{
			if (!Slot.IsOccupied())
			{
				Slot.Occupy(InActor);
				if (Slots::Debug.GetInt() > 0)
				{
					Log("" + Owner.GetName() + " was occupied by " + InActor.GetName());
				}
				break;
			}
		}
	}

	void VacateSlot(AActor InActor)
	{
		for (auto& Slot : Slots)
		{
			if (Slot.TryVacate(InActor))
			{
				if (Slots::Debug.GetInt() > 0)
				{
					Log("" + Owner.GetName() + " was vacated by " + InActor.GetName());
				}
				break;
			}
		}
	}
};
