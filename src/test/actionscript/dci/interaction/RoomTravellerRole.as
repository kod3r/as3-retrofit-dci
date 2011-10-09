package dci.interaction 
{
	import eu.powdermonkey.Room;
	import eu.powdermonkey.RoomObject;
	import eu.powdermonkey.RoomObjectCls;
	import eu.powdermonkey.retrofit.dci.Role;
	/**
	 * ...
	 * @author ifrost
	 */
	public class RoomTravellerRole extends Role implements IRoomTravellerRole 
	{
		
		public function RoomTravellerRole(self:Object) 
		{
			super(self);
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