package eu.powdermonkey
{
	public class Room
	{
		private var _name:String
		public function get name():String { return _name }
		
		protected var _residents:Array;
		
		public function Room(name:String)
		{
			_name = name
			_residents = [];
		}
		
		public function addResident(resident:Object):void {
			_residents.push(resident);
		}
		
		public function removeResident(resident:Object):void {
			var residentIndex:int = _residents.indexOf(resident);
			if (residentIndex != -1) {
				_residents.splice(residentIndex, 1);
			}
		}
		
		public function isEmpty():Boolean {
			return _residents.length == 0;
		}
		
		public function toString():String
		{
			return '[Room name:'+_name+']'
		}
	}
}