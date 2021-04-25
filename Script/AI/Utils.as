import Components.ActorSlotComponent;
import Components.HealthComponent;


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

	APawn GetLivingPawn(AActor Self)
	{
		TArray<APawn> AllPawns;
		GetAllActorsOfClass(AllPawns);
		TArray<APawn> LivingPawns;
		for (auto Pawn : AllPawns)
		{
			auto HealthComponent = UHealthComponent::Get(Pawn);
			if (!HealthComponent.IsDead() && Pawn != Self)
			{
				LivingPawns.Add(Pawn);
			}
		}
		if (LivingPawns.Num() > 0)
		{
			return LivingPawns[FMath::RandRange(0, LivingPawns.Num() - 1)];
		}
		return nullptr;
	}
}
