package eu.powdermonkey.retrofit.plugins
{
	import dci.interaction.RoomTravellerRole;
	import eu.powdermonkey.retrofit.plugins.ProxiedObjectData;
	import flash.utils.describeType;
	import org.flemit.bytecode.Instructions;
	import org.flemit.bytecode.QualifiedName;
	
	/**
	 * This plugin will inject proxy into proxied object into attribute tagged with [Self]
	 * @author ifrost
	 */
	public class SelfInjection implements IGeneratorPlugin 
	{
		
		public function SelfInjection() 
		{
			
		}
		
		/* INTERFACE eu.powdermonkey.retrofit.plugins.IMixinGeneratorPlugin */
		
		public function onProxiedObjectInitialization(data:ProxiedObjectData):Array 
		{
			var instructions:Array = [];
			var proxyPropertyName:QualifiedName = DefaultInstructions.buildProxyPropName(data.namespaze, data.interfaceType);
			
			with (Instructions) {	
				for each (var variable:XML in describeType(data.proxiedObject).factory.variable.(metadata.(@name == "Self"))) {
					var varName:QualifiedName = new QualifiedName(data.namespaze, variable.@name);
					instructions.push([GetLex, proxyPropertyName]); // get proxied object
					instructions.push([GetLocal, 0]); // put "this" on stack
					instructions.push([SetProperty, varName]); // assign "this" to self variable
				}
			}
			
			return instructions;
		}
		
	}

}