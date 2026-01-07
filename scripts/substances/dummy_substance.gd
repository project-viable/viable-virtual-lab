class_name DummySubstance
extends Substance
## A substance that doesn't do anything. Should be used in cases where a substance is needed, but
## where no other substance type makes sense.


func take_volume(_v: float) -> DummySubstance:
	return DummySubstance.new()
