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
	String Type
EndStruct

Event OnWorkshopObjectPlaced(ObjectReference akReference)
	PlaceMarkers()
	Update()
EndEvent

Event OnWorkshopObjectMoved(ObjectReference akReference)
	Update()
EndEvent

Event OnWorkshopObjectDestroyed(ObjectReference akReference)
	SnapPoint SP
	
	int i
	While(i < SnapPoints.Length)
		SP = SnapPoints[i]
		
		SP.Marker.Delete()
		SP.Marker = None
		If(SP.Object != None)
			Unsnap(SP)
		EndIf

		i += 1
	EndWhile
EndEvent

Function PlaceMarkers()
	SnapPoint SP
	
	int i
	While(i < SnapPoints.Length)
		SP = SnapPoints[i]
		
		SP.Marker = PlaceAtNode(SP.Name, DummyMarker as Form, 1, False, False, False, True)
		SP.Marker.SetLinkedRef(Self, None)
		SP.Marker.SetPropertyValue("Name", SP.Name)
		SP.Marker.SetPropertyValue("Type", SP.Type)
		
		If(SP.Target == "")
			SP.Target = SP.Name
		EndIf
		
		i += 1
	EndWhile
EndFunction

Function Update()
	ObjectReference[] FoundMarkers
	ISP_MarkerScript Marker
	SnapPoint SP
	
	int i
	While(i < SnapPoints.Length)
		SP = SnapPoints[i]
		FoundMarkers = SP.Marker.FindAllReferencesOfType(DummyMarker as Form, 1)
		
		If(FoundMarkers.Length > 1)
			int j
			While(j < FoundMarkers.Length)
				Marker = FoundMarkers[j] as ISP_MarkerScript
			
				If(IsValidMarker(SP, Marker))
					; We unsnap from one thing and then snap back to another
					If(SP.Object != None)
						Unsnap(SP)
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
				Unsnap(SP)
			EndIf
			
			SP.Object = None
		EndIf
		
		i += 1
	EndWhile
EndFunction

bool Function IsValidMarker(SnapPoint SP, ISP_MarkerScript Marker)
	If(Marker.GetLinkedRef(None) == Self)
		Return False
	ElseIf(Marker.GetLinkedRef(None).IsEnabled() == False)
		Return False
	ElseIf(SP.Type != "" && SP.Type == Marker.Type)
		Return True
	ElseIF(Marker.Name == SP.Target)
		Return True
	Else
		Return False
	EndIf
EndFunction

Function Unsnap(SnapPoint SP)
	SendOnUnsnappedEvent(Self, SP.Object, SP.Name)
	(SP.Object as ISP_Script).HandleUnsnap(SP.Object, Self, SP.Target)
	SP.Object = None
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