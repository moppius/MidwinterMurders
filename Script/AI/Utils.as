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
}
