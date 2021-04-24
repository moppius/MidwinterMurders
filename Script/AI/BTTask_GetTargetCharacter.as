class UBTTask_GetTargetCharacter : UBTTask_BlueprintBase
{
	UPROPERTY()
	FBlackboardKeySelector BlackboardKey;
	default BlackboardKey.AllowedTypes.Add(Cast<UBlackboardKeyType>(UBlackboardKeyType_Object::StaticClass()));
	default BlackboardKey.bNoneIsAllowedValue = false;

	UFUNCTION(BlueprintOverride)
	void ExecuteAI(AAIController OwnerController, APawn ControlledPawn)
	{
		TArray<APawn> AllPawns;
		GetAllActorsOfClass(AllPawns);
		AllPawns.Remove(ControlledPawn);
		if (AllPawns.Num() == 0)
		{
			FinishExecute(false);
			return;
		}

		APawn RandomPawn = AllPawns[FMath::RandRange(0, AllPawns.Num() - 1)];
		OwnerController.Blackboard.SetValueAsObject(BlackboardKey.SelectedKeyName, RandomPawn);
		FinishExecute(true);
	}
};
