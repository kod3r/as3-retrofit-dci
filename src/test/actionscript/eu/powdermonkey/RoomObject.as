package eu.powdermonkey
{
	public interface RoomObject
	{
		function joinRoom(room:Room):void
		function enteredTwoRooms(roomA:Room, roomB:Room):void
		function getRoomName(room:Room):String
		function get room():Room
		function set room(room:Room):void
		function set name(value:String):void;
		function get name():String;
	}
}