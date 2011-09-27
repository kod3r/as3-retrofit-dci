package eu.powdermonkey
{
	public class RoomObjectCls implements RoomObject
	{
		public function RoomObjectCls()
		{
		}
		
		private var _room:Room
		public function get room():Room {
			trace('getting room:') 
			return _room 
		}
		public function set room(value:Room):void { 
			trace('setting room:', value) 
			_room = value 
		}
		
		private var _roomTwo:Room
		
		public function joinRoom(room:Room):void
		{
			_room = room
			_room.addResident(this);
		}
		
		public function enteredTwoRooms(roomA:Room, roomB:Room):void
		{
			_room = roomA
			_roomTwo = roomB
		}
		
		public function getRoomName(room:Room):String
		{
			return room.name
		}
		
		private var _name:String;
		
		public function set name(value:String):void {
			_name = value;
		}
		
		public function get name():String {
			return _name;
		}
	}
}