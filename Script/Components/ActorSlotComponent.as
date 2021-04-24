namespace Slots
{
	const FConsoleVariable Debug("Slots.Debug", 0);
}

class UActorSlotComponent : UActorComponent
{
	private TMap<FName, AActor> Slots;
	private const FString SlotPrefix = "Slot";


	void PopulateSlots(UStaticMeshComponent StaticMeshComponent)
	{
		TArray<FName> SocketNames = StaticMeshComponent.GetAllSocketNames();
		for (FName SocketName : SocketNames)
		{
			if (SocketName.ToString().StartsWith(SlotPrefix))
			{
				Slots.Add(SocketName, nullptr);
			}
		}
	}

	bool HasAvailableSlot() const
	{
		for (auto& Slot : Slots)
		{
			if (Slot.GetValue() == nullptr)
			{
				return true;
			}
		}
		return false;
	}

	void OccupySlot(AActor InActor)
	{
		for (auto& Slot : Slots)
		{
			if (Slot.GetValue() == nullptr)
			{
				Slot.SetValue(InActor);
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
			if (Slot.GetValue() == InActor)
			{
				Slot.SetValue(nullptr);
				if (Slots::Debug.GetInt() > 0)
				{
					Log("" + Owner.GetName() + " was vacated by " + InActor.GetName());
				}
				break;
			}
		}
	}
};
