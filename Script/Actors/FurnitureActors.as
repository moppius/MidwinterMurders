import Components.ActorSlotComponent;
import Tags;


UCLASS(Abstract)
class AFurnitureActor : AActor
{
	default Tags.Add(Tags::Bed);

	UPROPERTY(DefaultComponent, RootComponent)
	UStaticMeshComponent StaticMeshComponent;
	default StaticMeshComponent.bCanEverAffectNavigation = false;

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