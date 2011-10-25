package eu.powdermonkey.retrofit.plugins.selfinjection
{
	import eu.powdermonkey.retrofit.plugins.ProxiedObjectData;
	import flash.utils.describeType;
	import org.flemit.bytecode.DynamicClass;
	import org.flemit.bytecode.Instructions;
	import org.flemit.bytecode.QualifiedName;
	import eu.powdermonkey.retrofit.plugins.IGeneratorPlugin;
	import eu.powdermonkey.retrofit.plugins.ProxiedObjectMethodData;
	
	/**
	 * This plugin will inject proxy into proxied object into attribute tagged with [Self]
	 * @author ifrost
	 */
	public class SelfInjection implements IGeneratorPlugin 
	{
		
		public function SelfInjection() 
		{
			
		}
		
		public function afterDynamicClassDefinition(dynamicClass:DynamicClass):void {
		
		}
		
		public function beforeProxyInitialization(instructions:Array):void 
		{
			
		}
		
		public function afterProxyInitialization(instructions:Array):void 
		{
			
		}
		
		public function beforeProxiedObjectInitialization(data:ProxiedObjectData, instructions:Array):void 
		{
			
		}
		
		public function afterProxiedObjectInitialization(data:ProxiedObjectData, instructions:Array):void 
		{
			with (Instructions) {	
				for each (var variable:XML in describeType(data.proxiedObject).factory.variable.(metadata.(@name == "Self"))) {
					var varName:QualifiedName = new QualifiedName(data.namespaze, variable.@name);
					instructions.push([GetLex, data.proxiedObjectPropertyQualifiedName]); // get proxied object
					instructions.push([GetLocal, 0]); // put "this" on stack
					instructions.push([SetProperty, varName]); // assign "this" to self variable
				}
			}			
		}
		
		public function beforeProxiedMethodInvocation(data:ProxiedObjectMethodData, instructions:Array):void 
		{
			
		}
		
		public function afterProxiedMethodInvocation(data:ProxiedObjectMethodData, instructions:Array):void 
		{
			
		}
		
	}

}