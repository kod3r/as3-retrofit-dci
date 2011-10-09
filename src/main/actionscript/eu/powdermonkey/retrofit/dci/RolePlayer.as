package eu.powdermonkey.retrofit.dci
{
	/**
	 * ...
	 * @author ifrost
	 */
	public class RolePlayer implements IRolePlayer 
	{
		[Self]
		public var self:Object;
		
		public function RolePlayer() 
		{
			
		}
		
		/* INTERFACE IRolePlayer */
		
		public function play(role:Class):* 
		{
			return new role(self);
		}
		
	}

}