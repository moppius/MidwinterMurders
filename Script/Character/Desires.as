enum EDesire
{
	Eat,
	Drink,
	Talk,
	Sleep,
	Run,
	Fight,
};


namespace Desires
{
	float GetDesireRelationship(EDesire Desire, EDesire OtherDesire)
	{
		switch (Desire)
		{
			case EDesire::Eat:
				return Desires::Internal::GetEatRelationship(OtherDesire);
			case EDesire::Drink:
				return Desires::Internal::GetDrinkRelationship(OtherDesire);
		}
		return 0.f;
	}

	namespace Internal
	{
		float GetEatRelationship(EDesire OtherDesire)
		{
			switch (OtherDesire)
			{
				case EDesire::Drink:
					return 0.5f;
				case EDesire::Sleep:
					return -0.5f;
				case EDesire::Run:
					return -0.8f;
				case EDesire::Fight:
					return -1.f;
			}
			return 0.f;
		}

		float GetDrinkRelationship(EDesire OtherDesire)
		{
			switch (OtherDesire)
			{
				case EDesire::Eat:
					return 0.25f;
				case EDesire::Sleep:
					return -0.5f;
				case EDesire::Run:
					return -0.5f;
				case EDesire::Fight:
					return -0.8f;
			}
			return 0.f;
		}
	}
}