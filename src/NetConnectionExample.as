/**
 * Created with IntelliJ IDEA.
 * User: dev
 * Date: 28/02/14
 * Time: 18:18
 * To change this template use File | Settings | File Templates.
 */
package {
import flash.display.Sprite;
import flash.events.AsyncErrorEvent;
import flash.events.NetStatusEvent;
import flash.events.SecurityErrorEvent;
import flash.events.TimerEvent;
import flash.media.Camera;
import flash.media.H264Level;
import flash.media.H264Profile;
import flash.media.H264VideoStreamSettings;
import flash.media.Video;
import flash.net.NetConnection;
import flash.net.NetStream;
import flash.events.Event;
import flash.net.Responder;
import flash.utils.Timer;


public class NetConnectionExample extends Sprite {
    private var videoURL:String = "rtmp://app.local/mediastream/yev";
    private var connection:NetConnection;
    private var stream:NetStream;
    private var videoMyCamera:Video = new Video();
    private var cam:Camera = Camera.getCamera();
    private var ns:NetStream;
    private var vid:Video = new Video();

    private var minuteTimer:Timer;
    protected var h264Settings:H264VideoStreamSettings = new H264VideoStreamSettings();

    public function NetConnectionExample() {
        h264Settings.setProfileLevel( H264Profile.BASELINE, H264Level.LEVEL_5_1 );

        cam.setMode(480, 270, 24, false);
        cam.setQuality(0, 99);
        var vid:Video = new Video(cam.width, cam.height);
        vid.attachCamera(cam);
        vid.x =1;
        vid.y = 1;
        addChild(vid);

        connection = new NetConnection();
        connection.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
        connection.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
        connection.connect("rtmp://app.local/mediastream/");
        trace("conneted");

    }

    function hadleServerResponse(result:String) : void {
        trace("server returned : "+result);
    }

    private function netStatusHandler(event:NetStatusEvent):void {

        switch (event.info.code) {
            case "NetConnection.Connect.Success":

                trace("connected!");
                ns = new NetStream(connection);
                ns.attachCamera(cam);
                ns.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
                ns.videoStreamSettings = h264Settings;
                trace("publishing....");
                ns.bufferTime = 1;
                ns.publish("yev2","live");
                trace("published");
                break;
            case "NetStream.Play.StreamNotFound":
                trace("Stream not found: " + videoURL);
                break;
            case "NetStream.Publish.Start":
                trace("publish success");
                //  connection.call("createDownstream",new Responder(hadleServerResponse), 'yev2', 'down');
                //connection.call("transcodeDownstream", null, 'down', '-vf movie=unsharp=13:13:-2:7:7:-5;wm.png[wm];[wm]scale=w=iw/2:h=ih/2[crop];[in][crop]overlay=0:15[out]');

                minuteTimer = new Timer(2000, 1);

                // designates listeners for the interval and completion events
                minuteTimer.addEventListener(TimerEvent.TIMER, showRtmpStream);

                // starts the timer ticking
                minuteTimer.start();

                break;
            case "NetStream.Publish.BadName":
                trace("stream bad name");
                break;

            case "NetConnection.Call.Failed":
                trace("server side error "+event.info.description);
                break;
        }
    }

    public function showRtmpStream(event:TimerEvent):void {
        trace("showRtmpStream calling ...");
        var stream:NetStream = new NetStream(connection);


        stream.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler);
        vid.attachNetStream(stream);
        vid.x = 150;
        vid.y = 150;
        addChild(vid);
        stream.play("yev2");
    }

    function asyncErrorHandler(event:AsyncErrorEvent):void
    {
        trace(event);
    }

    private function securityErrorHandler(event:SecurityErrorEvent):void {
        trace("securityErrorHandler: " + event);
    }
}
}

class CustomClient {

}