import Components.ActorSlotComponent;
import Tags;


UCLASS(Abstract)
class AFurnitureActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent, ShowOnActor)
	UStaticMeshComponent StaticMeshComponent;
	default StaticMeshComponent.bCanEverAffectNavigation = true;
	default StaticMeshComponent.Mobility = EComponentMobility::Static;
	default StaticMeshComponent.SetCollisionProfileName(n"BlockAll");

	UPROPERTY(DefaultComponent)
	UActorSlotComponent SlotComponent;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		SlotComponent.PopulateSlots(StaticMeshComponent);
	}
};


class ABed : AFurnitureActor
{
	default Tags.Add(Tags::Bed);
	default StaticMeshComponent.StaticMesh = Asset("/Game/MidwinterMurders/Environments/SM_Furniture_Bed_01.SM_Furniture_Bed_01");
};


class ASeat : AFurnitureActor
{
	default Tags.Add(Tags::Seat);
	default StaticMeshComponent.StaticMesh = Asset("/Game/MidwinterMurders/Environments/SM_Furniture_Chair_01.SM_Furniture_Chair_01");
};
