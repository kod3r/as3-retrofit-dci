package eu.powdermonkey 
{
	import dci.interaction.IRoomTravellerRole;
	import dci.interaction.RoomTravellerRole;
	import eu.powdermonkey.Room;
	import flash.geom.Point;
	import flash.utils.describeType;
	/**
	 * ...
	 * @author ifrost
	 */
	public class PersonDitto implements Person, Moveable
	{
		public var roomObject:RoomObject;
		public var moveable:Moveable;
		public var traveller:RoomTravellerRole
		
		public function PersonDitto() 
		{
			roomObject = new RoomObjectCls();
			moveable = new MoveableCls();
			traveller = new RoomTravellerRole();

			traveller.self = this;
		}
		
		/* INTERFACE eu.powdermonkey.Person */
		
		public function joinRoom(room:Room):void 
		{
			roomObject.joinRoom(room);
		}
		
		public function enteredTwoRooms(roomA:Room, roomB:Room):void 
		{
			roomObject.enteredTwoRooms(roomA, roomB);
		}
		
		public function getRoomName(room:Room):String 
		{
			return roomObject.getRoomName(room);
		}
		
		public function get room():Room 
		{
			return roomObject.room;
		}
		
		public function set room(value:Room):void 
		{
			roomObject.room = value;
		}
		
		public function set name(value:String):void 
		{
			roomObject.name = value;
		}
		
		public function get name():String 
		{
			return roomObject.name;
		}
		
		public function move(location:Point):void {
			moveable.move(location);
		}
		
		public function get location():Point {
			return moveable.location;
		}
		
		public function visitRoom(room:Room):void {
			traveller.visitRoom(room);
		}
		
	}

}