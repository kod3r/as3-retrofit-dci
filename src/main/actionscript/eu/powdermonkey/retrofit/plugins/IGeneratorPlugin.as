package eu.powdermonkey.retrofit.plugins
{
	
	/**
	 * Mixin generator method is a class filled with "template methods" for creating additional
	 * instructions while generating new mixin by MixinGenerator
	 * 
	 * @author ifrost
	 */
	public interface IGeneratorPlugin 
	{
		function onProxiedObjectInitialization(data:ProxiedObjectData):Array;
	}
	
}