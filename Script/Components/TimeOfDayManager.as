// 0.f is midnight, 0.5f is noon, etc.
class UTimeOfDayManagerComponent : UActorComponent
{
	// One day is one minute
	float Speed = 1.f / 60.f;

	private float TimeOfDay = 0.5f;
	private ADirectionalLight SunLight;

	private const float SunPitchRange = 80.f;
	private const float SunPitchOffset = 20.f;


	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		TArray<ADirectionalLight> SunLights;
		GetAllActorsOfClass(SunLights);
		ensure(SunLights.Num() == 1, "Should only have one Directional Light in the level!");
		SunLight = SunLights[0];
		TimeOfDay = FMath::FRand();

		UpdateSunLight();
	}

	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaSeconds)
	{
		TimeOfDay += DeltaSeconds * Speed;
		if (TimeOfDay > 1.f)
		{
			TimeOfDay = TimeOfDay % 1.f;
		}

		UpdateSunLight();
	}

	float GetTimeOfDay() const
	{
		return TimeOfDay;
	}

	private void UpdateSunLight()
	{
		const float Wave = FMath::Cos(TimeOfDay * PI * 2.f) * 0.5f;
		const float Pitch = (Wave * -SunPitchRange) - SunPitchOffset;
		SunLight.LightComponent.SetCastShadows(Pitch < 0.f);
		SunLight.SetActorRotation(FRotator(Pitch, TimeOfDay * 360.f, 0.f));
	}
};
