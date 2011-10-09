package eu.powdermonkey.retrofit.dci
{
	import flash.utils.Dictionary;
	/**
	 * ...
	 * @author ifrost
	 */
	public class RolePlayer implements IRolePlayer 
	{
		[Self]
		public var self:Object;
		
		protected var _roles:Dictionary;
		
		public function RolePlayer() 
		{
			_roles = new Dictionary();
		}
		
		/* INTERFACE IRolePlayer */
		
		public function play(role:Class):* 
		{
			if (!(role in _roles)) {
				_roles[role] = new role(self);
			}
			return _roles[role];
		}
		
	}

}