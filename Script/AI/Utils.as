import Components.ActorSlotComponent;


namespace AIUtils
{
	AActor GetClosestActor(AActor Actor, const TArray<AActor>& Actors)
	{
		float ClosestDistanceSquared = MAX_flt;
		AActor ClosestActor;
		for (auto OtherActor : Actors)
		{
			const float DistanceSquared = Actor.GetSquaredDistanceTo(OtherActor);
			if (DistanceSquared < ClosestDistanceSquared)
			{
				ClosestDistanceSquared = DistanceSquared;
				ClosestActor = OtherActor;
			}
		}
		return ClosestActor;
	}

	AActor GetClosestActorWithAvailableSlot(AActor Actor, const TArray<AActor>& Actors)
	{
		float ClosestDistanceSquared = MAX_flt;
		AActor ClosestActorWithSlot;
		for (auto OtherActor : Actors)
		{
			auto SlotComponent = UActorSlotComponent::Get(OtherActor);
			if (ensure(SlotComponent != nullptr, "No Slot Component found on " + OtherActor.GetName()))
			{
				if (SlotComponent.NumAvailableSlots() == 0)
				{
					continue;
				}

				const float DistanceSquared = Actor.GetSquaredDistanceTo(OtherActor);
				if (DistanceSquared < ClosestDistanceSquared)
				{
					ClosestDistanceSquared = DistanceSquared;
					ClosestActorWithSlot = OtherActor;
				}
			}
		}
		return ClosestActorWithSlot;
	}
}
