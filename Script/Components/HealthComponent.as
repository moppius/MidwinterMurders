import Tags;


event void FOnDiedSignature(UHealthComponent HealthComponent);


class UHealthComponent : UActorComponent
{
	default PrimaryComponentTick.bStartWithTickEnabled = false;

	private float MaxHealth = 100.f;
	private float CurrentHealth = 100.f;

	FOnDiedSignature OnDied;


	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Owner.OnTakeAnyDamage.AddUFunction(this, n"TakeAnyDamage");
	}

	bool IsDead() const
	{
		return CurrentHealth <= 0.f;
	}

	UFUNCTION(NotBlueprintCallable)
	private void TakeAnyDamage(AActor DamagedActor, float Damage, const UDamageType DamageType, AController InstigatedBy, AActor DamageCauser)
	{
		if (!IsDead())
		{
			CurrentHealth -= Damage;
			auto PawnOwner = Cast<APawn>(Owner);
			if (IsDead())
			{
				UAISense_Hearing::ReportNoiseEvent(PawnOwner.GetActorLocation(), 1.f, PawnOwner, Tag = Tags::DeathScream);
				OnDied.Broadcast(this);
			}
			else
			{
				UAISense_Hearing::ReportNoiseEvent(PawnOwner.GetActorLocation(), 0.9f, PawnOwner, Tag = Tags::PainScream);
			}
		}
	}
};
