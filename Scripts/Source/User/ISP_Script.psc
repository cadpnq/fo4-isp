Scriptname ISP_Script extends ObjectReference

Activator Property DummyMarker Auto Const

SnapPoint[] Property SnapPoints Auto

CustomEvent OnSnapped
CustomEvent OnUnsnapped

Struct SnapPoint
	String Name
	ObjectReference Marker Hidden
	ObjectReference Object Hidden
	String Target
EndStruct

Event OnWorkshopObjectPlaced(ObjectReference akReference)
	PlaceMarkers()
	Update()
EndEvent

Event OnWorkshopObjectMoved(ObjectReference akReference)
	Update()
EndEvent

Event OnWorkshopObjectDestroyed(ObjectReference akReference)
	int i
	While(i < SnapPoints.Length)
		SnapPoints[i].Marker.Delete()

		i += 1
	EndWhile
EndEvent

Function PlaceMarkers()
	int i
	While(i < SnapPoints.Length)
		SnapPoints[i].Marker = PlaceAtNode(SnapPoints[i].Name, DummyMarker as Form, 1, False, False, False, True)
		SnapPoints[i].Marker.SetLinkedRef(Self, None)
		SnapPoints[i].Marker.SetPropertyValue("Name", SnapPoints[i].Name)
		
		If(SnapPoints[i].Target == "")
			SnapPoints[i].Target = SnapPoints[i].Name
		EndIf
		
		i += 1
	EndWhile
EndFunction

Function Update()
	ObjectReference[] FoundMarkers
	ObjectReference Marker
	SnapPoint SP
	
	int i
	While(i < SnapPoints.Length)
		SP = SnapPoints[i]
		FoundMarkers = SP.Marker.FindAllReferencesOfType(DummyMarker as Form, 1)
		
		If(FoundMarkers.Length > 1)
			int j
			While(j < FoundMarkers.Length)
				Marker = FoundMarkers[j]
			
				If((Marker.GetPropertyValue("Name") as String == SP.Target) && (Marker.GetLinkedRef(None) != Self))
					; We unsnap from one thing and then snap back to another
					If(SP.Object != None)
						SendOnUnsnappedEvent(Self, SP.Object, SP.Name)
						(SP.Object as ISP_Script).HandleUnsnap(SP.Object, Self, SP.Target)
					EndIf
			
					SP.Object = Marker.GetLinkedRef(None)
					SendOnSnappedEvent(Self, SP.Object, SP.Name)
					(SP.Object as ISP_Script).HandleSnap(SP.Object, Self, SP.Target)
			
					j = FoundMarkers.Length
				EndIf
			
				j += 1
			EndWhile
		Else
			; something was just unsnapped
			If(SP.Object != None)
				SendOnUnsnappedEvent(Self, SP.Object, SP.Name)
				(SP.Object as ISP_Script).HandleUnsnap(SP.Object, Self, SP.Target)
			EndIf
			
			SP.Object = None
		EndIf
		
		i += 1
	EndWhile
EndFunction

Function SendOnSnappedEvent(ObjectReference objA, ObjectReference objB, String NodeName)
	Var[] kargs = new Var[3]
	kargs[0] = objA
	kargs[1] = objB
	kargs[2] = NodeName
	SendCustomEvent("OnSnapped", kargs)

	Debug.Trace(objA + " was just snapped to " + objB + " at a node named: " + NodeName)
EndFunction

Function SendOnUnsnappedEvent(ObjectReference objA, ObjectReference objB, String NodeName)
	Var[] kargs = new Var[3]
	kargs[0] = objA
	kargs[1] = objB
	kargs[2] = NodeName
	SendCustomEvent("OnUnsnapped", kargs)

	Debug.Trace(objA + " was just unsnapped from " + objB + " at a node named: " + NodeName)
EndFunction

Function HandleSnap(ObjectReference objA, ObjectReference objB, String NodeName)
	SnapPoints[SnapPoints.FindStruct("Name", NodeName)].Object = objB

	SendOnSnappedEvent(objA, objB, NodeName)
EndFunction

Function HandleUnsnap(ObjectReference objA, ObjectReference objB, String NodeName)
	SnapPoints[SnapPoints.FindStruct("Name", NodeName)].Object = None

	SendOnUnsnappedEvent(objA, objB, NodeName)
EndFunction