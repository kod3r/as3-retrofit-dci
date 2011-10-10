package eu.powdermonkey.retrofit.plugins
{
	import org.flemit.bytecode.BCNamespace;
	import org.flemit.bytecode.QualifiedName;
	import org.flemit.reflection.MethodInfo;
	import org.flemit.reflection.Type;
	/**
	 * Data that describes method that are wrapped by composit
	 * @author ifrost
	 */
	public class ProxiedObjectMethodData 
	{
		public var namespaze:BCNamespace;
		public var proxiedObjectPropertyQualifiedName:QualifiedName;		
		public var argCount:int;
		public var methodQualifiedName:QualifiedName;
		public var methodInfo:MethodInfo;
		public var methodType:uint;
				
		
		public function ProxiedObjectMethodData(proxiedObjectPropertyQualifiedName:QualifiedName, namespaze:BCNamespace, argCount:int, methodInfo:MethodInfo, methodType:uint) 
		{
			this.proxiedObjectPropertyQualifiedName = proxiedObjectPropertyQualifiedName;
			this.namespaze = namespaze;
			this.argCount = argCount;			
			this.methodInfo = methodInfo;
			this.methodType = methodType;
			
			var methodName:String = methodInfo.fullName.match(/(\w+)\/\w+$/)[1]
			methodQualifiedName = new QualifiedName(namespaze, methodName) 
		}
		
	}

}