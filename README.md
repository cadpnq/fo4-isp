# Intelligent Snap Points

Intelligent Snap Points (ISP) is a pure Papyrus library which adds two new events to settlement items: OnSnapped and OnUnsnapped.

example code for an object that brings up a message box whenever it is (un)snapped to/from something:
```papyrus
Scriptname ISP_BlockScript extends ObjectReference

ISP_Script ISPSelf

Event OnWorkshopObjectPlaced(ObjectReference akReference)
	ISPSelf = (Self as ObjectReference) as ISP_Script
	ISPSelf.Register(Self)
EndEvent

Event OnWorkshopObjectDestroyed(ObjectReference akReference)
	ISPSelf.Unregister(Self)
EndEvent


Event ISP_Script.OnSnapped(ISP_Script akSender, Var[] akArgs)
	Debug.MessageBox("Snapped: " + Self)
EndEvent

Event ISP_Script.OnUnsnapped(ISP_Script akSender, Var[] akArgs)
	Debug.MessageBox("Unsnapped: " + Self)
EndEvent
```