package  
{
	import flash.utils.Dictionary;
	import org.flemit.bytecode.QualifiedName;
	import org.flemit.reflection.Type;
	/**
	 * ...
	 * @author ifrost
	 */
	public class ProxyObjectData 
	{
		
		public var name:QualifiedName;
		public var base:Type;
		public var mixins:Dictionary;
		public var proxyObject:Object;
		
		public function ProxyObjectData(name:QualifiedName, base:Type, mixins:Dictionary, pl) 
		{
			// :P
		}
		
	}

}