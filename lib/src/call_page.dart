part of db_agora_call;

class CallPage extends StatefulWidget {
  final String channelName;
  final String token;
  final String bearerToken;
  final bool isMBBSCall;
  final dynamic defaultBackPage;


  const CallPage(
      {Key? key,
        this.defaultBackPage,
      required this.channelName,
      required this.token,
      required this.bearerToken,
      this.isMBBSCall = false})
      : super(key: key);

  @override
  _CallPageState createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {

  Rx<Duration> initialTime = Rx(const Duration(seconds: 1));
  Timer? timer;
  void startTimer() {
    timer = Timer.periodic(const Duration(milliseconds: 100), (Timer t) {
      setState(() {
        initialTime.value += const Duration(milliseconds: 100);
      });
    });
  }

  String appId = "4dc69b29e5ba4ef6a67567d70f8429bb";
  int uid = 2; // uid of the local user

  int? _remoteUid; // uid of the remote user
  bool _isJoined = false; // Indicates if the local user has joined the channel
  bool _isRemoteUserJoined =
      false; // Indicates if the local user has joined the channel
  late RtcEngine agoraEngine; // Agora engine instance
  RxBool muteAudio = false.obs;
  RxBool isAgoraInitialized = false.obs;
  bool isChannelEnd = false;
  RxBool muteVideo = false.obs;
  RxBool enableSpeaker = true.obs;

  @override
  void dispose() {
    forceLeave();
    muteAudio.close();
    isAgoraInitialized.close();
    muteVideo.close();
    enableSpeaker.close();
    timer?.cancel();
    initialTime.close();
    super.dispose();
  }

  forceLeave() async {
    if (!isChannelEnd) {
      await leave();
    }
  }

  @override
  void initState() {
    super.initState();
    startTimer();
    setupVideoSDKEngine();
  }

  // Build UI
  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          backgroundColor: Colors.red,
          onPressed: () async {
            if (isAgoraInitialized.value) {
              callEnd();
              await leave();
            }
          },
          child: Obx(() => isAgoraInitialized.value
              ? const Icon(
                  Icons.call_end_sharp,
                  color: Colors.white,
                )
              : const Center(
                  child: CircularProgressIndicator(
                  color: Colors.white,
                ))),
        ),
        bottomNavigationBar: BottomAppBar(
           color: const Color(0xff246C54),
          notchMargin: 10.0,
          shape: const AutomaticNotchedShape(

            RoundedRectangleBorder(),
            StadiumBorder(

              side: BorderSide(),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                // Container(
                //   height: 48,
                //   width: 48,
                //   decoration: const BoxDecoration(
                //     shape: BoxShape.circle,
                //     color: Colors.black,
                //   ),
                //   child: Obx(() => IconButton(
                //     icon:   Icon(
                //       enableSpeaker.value ? Icons.volume_down_rounded : Icons.volume_off_rounded,
                //       color: Colors.white,
                //     ),
                //     onPressed: () async {
                //        speakerOnOff();
                //     },
                //   )),
                // ),
                Container(
                  height: 48,
                  width: 48,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black,
                  ),
                  child: IconButton(
                    icon: Obx(() => Icon(
                          muteVideo.value ? Icons.videocam_off : Icons.videocam,
                          color: Colors.white,
                        )),
                    onPressed: () {
                      videoMute();
                    },
                  ),
                ),

                Container(
                  height: 48,
                  width: 48,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black,
                  ),
                  child: IconButton(
                    icon: Obx(() => Icon(
                          muteAudio.value
                              ? Icons.mic_off_sharp
                              : Icons.mic_none_sharp,
                          color: Colors.white,
                        )),
                    onPressed: () {
                      audioMute();
                    },
                  ),
                ),


                // The dum
              ],
            ),
          ),
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          color: Colors.black12,
          child: Stack(
            children: [
              //middle part ........
              Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                color: Colors.white,
                child: _remoteVideo(),
              ),
              Positioned(
                right: 15,
                bottom: 20,
                child:  Container(
                height: 48,
                width: 48,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.cameraswitch,
                    color:Color(0xff246C54),
                    size: 28,
                  ),
                  onPressed: () {
                    switchCamera();
                  },
                ),
              ),),
               Positioned(
                left: 15,
                bottom: 20,
                child: Obx(() => Text(
                  "${initialTime.value.inMinutes.remainder(60).toString().padLeft(2, '0')}:${initialTime.value.inSeconds.remainder(60).toString().padLeft(2, '0')}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black26,
                  ),
                ))                ,),
              Positioned(
                right: 26,
                top: 41,
                child: Obx(() => Container(
                      height: 152,
                      width: 102,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.blueGrey,
                      ),
                      child: muteVideo.value
                          ? const Center(child: Icon(Icons.person_off_outlined))
                          : _localPreview(),
                    )),
              ),
            ],
          ),
        ),
      ),
      onWillPop: () async {
        final result = await onBackPressed(context: context,
          title: 'Exit Process?',
          subTitle: 'Are you sure you want to quit this process?',
          yes: "Yes",
          no: "No",
          onYesPressed: () async {
            callEnd();
            await leave();
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => widget.defaultBackPage));
            // Get.offAll(const BottomNavigationBarView());
          },);
        return result ?? false;
      },
    );
  }

  void join() async {
     await agoraEngine.startPreview();
    // Set channel options including the client role and channel profile
    ChannelMediaOptions options = const ChannelMediaOptions(
      clientRoleType: ClientRoleType.clientRoleBroadcaster,
      channelProfile: ChannelProfileType.channelProfileCommunication,
    );

    print("joinChannel -- widget.token ${widget.token} widget.channelName ${widget.channelName}");
    await agoraEngine.joinChannel(
      token: widget.token,
      channelId: widget.channelName,
      options: options,
      uid: uid,
    ).onError((error, stackTrace) {
      print("Joining error ${error.toString()}${stackTrace.toString()}");
    });
  }

  Future<void> leave() async {
    isChannelEnd = true;
    _isJoined = false;
    _remoteUid = null;
    await agoraEngine.leaveChannel();
    await agoraEngine.release();
  }

  void audioMute() async {
    muteAudio.value = !muteAudio.value;
    final isAudioMute = muteAudio.value;
    await agoraEngine.muteLocalAudioStream(isAudioMute);
  }

  void videoMute() async {
    muteVideo.value = !muteVideo.value;
    final isVideoMute = muteVideo.value;
    await agoraEngine.muteLocalVideoStream(isVideoMute);
  }
  void speakerOnOff() async {
    enableSpeaker.value = !enableSpeaker.value;

    await agoraEngine.enableLocalAudio(enableSpeaker.value);
  }

  void switchCamera() async {
    await agoraEngine.switchCamera();
  }

  Future<void> setupVideoSDKEngine() async {
    await [Permission.microphone, Permission.camera].request();

    //create an instance of the Agora engine
    agoraEngine = createAgoraRtcEngine();
    await agoraEngine
        .initialize(RtcEngineContext(appId: appId))
        .then((value) => isAgoraInitialized.value = true).catchError((error, stackTrace) {

          print("agora on error ${error.toString()}");
          print("agora on error ${stackTrace.toString()}");

    });
    await agoraEngine.enableVideo();

    // Register the event handler
    agoraEngine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
           pingStartCallApi();
          setState(() {
            _isJoined = true;
          });
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          setState(() {
            _isRemoteUserJoined = true;
            _remoteUid = remoteUid;
          });
        },
        onLeaveChannel: (connection, stats) async {
          print("onLeaveChannel ${connection.channelId}");
          if (_isRemoteUserJoined && !widget.isMBBSCall) {
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => WaitForReportScreen(roomId: widget.channelName,)));
            // Get.offAll(WaitForReportScreen(roomId: widget.channelName,));
          } else {
            print(" Get.offAll(BottomNavigationBarView); ${connection.channelId}");
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => widget.defaultBackPage));
            // Get.offAll(const BottomNavigationBarView());
          }
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) async {
          await leave();
          _remoteUid = null;
        },
      ),
    );

    join();
  }


  void pingStartCallApi() async {

    if (widget.isMBBSCall) {
      var request = await post("https://micro-purno-api.purnohealth.com/api/v1/doctor-call/start-call-regular-user/${widget.channelName}", body: {});
    } else {
      var request = await post("https://micro-purno-api.purnohealth.com/api/v1/doctor-call/start-call-regular-user/${widget.channelName}", body: {});
      print("request ${request?.result.toString()}");
    }
  }

  void callEnd() async {
    if (widget.isMBBSCall) {
      var request = await post("https://micro-purno-api.purnohealth.com/api/v1/doctor-call/end-call-regular/${widget.channelName}", body: {});
    } else {
      var request = post("https://micro-purno-api.purnohealth.com/api/v1/doctor-call/end-call-ondemand/${widget.channelName}", body: {});
      // print("request ${request?.result.toString()}");
    }
  }

// Display local video preview
  Widget _localPreview() {
    if (_isJoined) {
      return AgoraVideoView(
        controller: VideoViewController(
          rtcEngine: agoraEngine,
          canvas: const VideoCanvas(uid: 0),
        ),
      );
    } else {
      return Container(
        color: Colors.blueGrey,
      );
    }
  }

// Display remote user's video
  Widget _remoteVideo() {
    if (_remoteUid != null) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: agoraEngine,
          canvas: VideoCanvas(uid: _remoteUid),
          connection: RtcConnection(channelId: widget.channelName),
        ),
      );
    } else {
      String msg = '';
      if (_isJoined) msg = 'Waiting for a remote user to join';
      return Center(
        child: Platform.isIOS
            ? const CupertinoActivityIndicator()
            : const CircularProgressIndicator(
                color: Colors.blue,
              ),
      );
    }
  }
}
