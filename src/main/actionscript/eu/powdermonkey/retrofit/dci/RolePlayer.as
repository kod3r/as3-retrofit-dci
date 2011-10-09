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
		
		/**
		 * Returns role which will be played by object
		 * @param	role
		 * @return
		 */
		public function play(role:Class):* 
		{
			return _roles[role] || cacheRole(role);
		}
		
		/**
		 * Cache role and return instance
		 * @param	role
		 * @return
		 */
		private function cacheRole(role:Class):* {
			return (_roles[role] = new role(self));
		}
	}

}