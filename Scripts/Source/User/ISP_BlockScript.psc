Scriptname ISP_BlockScript extends ObjectReference

Event OnWorkshopObjectPlaced(ObjectReference akReference)
	ISP_Script foo = (Self as ObjectReference) as ISP_Script
	RegisterForCustomEvent(foo, "OnSnapped")
	RegisterForCustomEvent(foo, "OnUnsnapped")
EndEvent

Event ISP_Script.OnSnapped(ISP_Script akSender, Var[] akArgs)
	Debug.Trace("Snapped: " + Self)
EndEvent

Event ISP_Script.OnUnsnapped(ISP_Script akSender, Var[] akArgs)
	Debug.Trace("Unsnapped: " + Self)
EndEvent