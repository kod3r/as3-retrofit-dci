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
		/**
		 * Hook for injecting instruction just before construcing ALL proxied objects
		 * @param	all current instructions 
		 */
		function beforeProxyInitialization(instructions:Array):void;
		
		/**
		 * Hook for injecting instruction after construcing ALL proxied objects
		 * @return	instructions to add
		 */
		function afterProxyInitialization(instructions:Array):void;
		
		/**
		 * Hook for injecting instructions just before constructing proxied object
		 * @param	data
		 * @param	all current instructions 
		 */
		function beforeProxiedObjectInitialization(data:ProxiedObjectData, instructions:Array):void;
		
		/**
		 * Hook for injecting instructions after constructing proxied object
		 * @param	data
		 * @param	all current instructions 
		 */
		function afterProxiedObjectInitialization(data:ProxiedObjectData, instructions:Array):void;
		
		/**
		 * Hook for injecting instructions just before proxied object's method invocation
		 * @param	data
		 * @param	all current instructions 
		 */		
		function beforeProxiedMethodInvocation(data:ProxiedObjectMethodData, instructions:Array):void;
		
		/**
		 * Hook for injecting instructions after proxied object's method invocation
		 * @param	data
		 * @param	all current instructions 
		 */
		function afterProxiedMethodInvocation(data:ProxiedObjectMethodData, instructions:Array):void;
	}
	
}