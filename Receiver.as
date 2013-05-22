package  {
	
	import flash.display.MovieClip;
	import flash.events.*;
	import flash.media.Sound;
	import flash.net.Socket;
	import flash.system.Security;
	import flash.utils.ByteArray;
	
	public class Receiver extends MovieClip{
		
		public var socket:Socket;
		
		private var bytes:ByteArray = new ByteArray();
		private var output:Boolean = false;
		var buffer:Vector.<Number> = new Vector.<Number>();
		const BUFFER_SIZE:int = 2048; // output buffer size 
		const MIN_SAFETY_BUFFER:int = 1024; // minimum collected input before output starts 
		
		public function Receiver(){
			socket = new Socket();
			
			Security.allowDomain("*");
			
			socket.addEventListener(Event.CONNECT, onConnect);
			socket.addEventListener(ProgressEvent.SOCKET_DATA, socketData);
			socket.addEventListener(IOErrorEvent.IO_ERROR, onError);
			
			socket.connect("localhost", 8080);
			
			var sound:Sound = new Sound(); 
			sound.addEventListener(SampleDataEvent.SAMPLE_DATA, soundSampleDataHandler); 
			sound.play(); 
		}
		
		public function socketData(event:ProgressEvent):void{
			while(socket.bytesAvailable){ 
				buffer.push(socket.readFloat()); 
			} 
			trace(buffer.length);
			if (!output && buffer.length >= MIN_SAFETY_BUFFER) 
			{ 
				output = true; 
			}
		}
		
		public function soundSampleDataHandler(event:SampleDataEvent):void { 
			
			var outputBuffer:Vector.<Number>; 
			
			if (output){ 
				if(buffer.length > BUFFER_SIZE){
					outputBuffer = buffer.splice(0, BUFFER_SIZE);
				}else{
					outputBuffer = new Vector.<Number>(BUFFER_SIZE);
				}
			}else{
				outputBuffer = new Vector.<Number>(BUFFER_SIZE);
			}
			
			var currentPhase:Number = 0; 
			var deltaPhase:Number = 440/44100;
			
			for (var i:int=0; i<BUFFER_SIZE; i++){ 
				if(outputBuffer[i] == 0){
					currentPhase += deltaPhase; 
					var currentSample:Number = Math.sin(currentPhase*Math.PI*2); 
				}else{
					var currentSample:Number = outputBuffer[i];
				}
				
				event.data.writeFloat(currentSample); // left channel 
				event.data.writeFloat(currentSample); // right channel 
			} 
		}
		
		function onConnect(e:Event):void {
			trace("Connected");
		}
		
		function onError(e:IOErrorEvent):void {
			trace("IO Error: "+e);
		}
		
	}
	
}
