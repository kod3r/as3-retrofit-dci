package dci.interaction 
{
	import eu.powdermonkey.Room;
	import eu.powdermonkey.RoomObject;
	import eu.powdermonkey.RoomObjectCls;
	/**
	 * ...
	 * @author ifrost
	 */
	public class RoomTravellerRole implements IRoomTravellerRole 
	{
		[Self]
		public var self:Object;
		
		public function RoomTravellerRole() 
		{
			
		}
		
		public function get asRoomObject():RoomObject {
			return this.self as RoomObject;
		}
		
		/* INTERFACE dci.interaction.IRoomTravellerRole */
		
		public function visitRoom(room:Room):void 
		{						
			trace("Hello room: ", room.name + ". My name is", asRoomObject.name);
		}
		
	}

}