event void FOnDiedSignature(UHealthComponent HealthComponent);


class UHealthComponent : UActorComponent
{
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
			if (IsDead())
			{
				OnDied.Broadcast(this);
			}
		}
	}
};
