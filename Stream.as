package {
	
	import flash.display.MovieClip;
	import flash.errors.IOError;
	import flash.events.*;
	import flash.media.Microphone;
	import flash.net.Socket;
	import flash.system.Security;
	import flash.utils.ByteArray;
	
	public class Stream extends MovieClip{
		public var socket:Socket = new Socket(); 
		public var microphone:Microphone; 
		public var buffer:Vector.<Number> = new Vector.<Number>();
		public var bytes:ByteArray = new ByteArray();
		
		public function Stream(){
			socket.addEventListener(Event.CONNECT, onConnect);
			socket.addEventListener(IOErrorEvent.IO_ERROR, onError);
			
			socket.connect("localhost", 8080);
		}
		
		public function onConnect(e:Event):void {
			startMicrophone();
		}
		
		public function onError(e:IOErrorEvent):void {
			trace("IO Error: "+e);
		}
		
		public function startMicrophone():void {
			microphone = Microphone.getMicrophone();
			microphone.rate = 44;
			microphone.setSilenceLevel(0);
			
			microphone.setUseEchoSuppression(true);
			microphone.addEventListener(SampleDataEvent.SAMPLE_DATA, socketWrite);
		}
		
		public function socketWrite(e:SampleDataEvent):void {
			while(e.data.bytesAvailable){
				bytes.writeFloat(e.data.readFloat());
			}
			
			if(bytes.length > 4096){
				socket.writeBytes(bytes);
				socket.flush();
				bytes = new ByteArray();
			}
		}
	}
}