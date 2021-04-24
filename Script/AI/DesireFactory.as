import AI.Desires;
import AI.DesireSit;
import AI.DesireSleep;
import AI.DesireTalk;
import AI.DesireWalk;


namespace Desire
{
	UDesireBase Create(EDesire Type)
	{
		UClass DesireClass;
		switch (Type)
		{
			case EDesire::Walk:
				DesireClass = UDesireWalk::StaticClass();
				break;
			case EDesire::Sit:
				DesireClass = UDesireSit::StaticClass();
				break;
			case EDesire::Sleep:
				DesireClass = UDesireSleep::StaticClass();
				break;
			case EDesire::Talk:
				DesireClass = UDesireTalk::StaticClass();
				break;
			default:
				break;
		}
		if (ensure(System::IsValidClass(DesireClass), "Failed to find Desire class for " + Type + "!"))
		{
			return Cast<UDesireBase>(NewObject(CurrentWorld, DesireClass, bTransient = true));
		}
		return nullptr;
	}
}