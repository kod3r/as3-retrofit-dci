package dci.context 
{
	import dci.interaction.IRoomTravellerRole;
	import dci.interaction.RoomTravellerRole;
	import eu.powdermonkey.Person;
	import eu.powdermonkey.Room;
	/**
	 * ...
	 * @author ifrost
	 */
	public class RoomTravelContext 
	{
		protected var _traveller:IRoomTravellerRole;
		protected var _rooms:Array;
		
		public function RoomTravelContext(person:Person, ...rooms) 
		{
			_traveller = person.play(RoomTravellerRole);
			_rooms = rooms;
		}
		
		public function visitEmptyRooms():void 
		{
			for each (var room:Room in _rooms) {
				if (room.isEmpty()) {
					_traveller.visitRoom(room);
				}
			}
		}
		
		public function visitAllRooms():void {
			for each (var room:Room in _rooms) {
				_traveller.visitRoom(room);
			}			
		}
		
	}

}