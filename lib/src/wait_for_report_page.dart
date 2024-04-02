part of db_agora_call;

class WaitForReportScreen extends StatefulWidget {
  final String roomId;
  final dynamic defaultBackPage;
  const WaitForReportScreen({super.key, this.defaultBackPage, required this.roomId});

  @override
  State<WaitForReportScreen> createState() => _WaitForReportScreenState();
}

class _WaitForReportScreenState extends State<WaitForReportScreen> {
  Map<String, dynamic>  prescription = {};
  bool? hasReport;
  late Timer timer;
  getPrescriptionData(){
      timer = Timer.periodic(const Duration(seconds: 10), (timer) async {
        
        get("https://micro-purno-api.purnohealth.com/api/v1/doctor-call/get-prescription/${widget.roomId}",).then((value) {
          print("valuevalue valuevaluevalue${value.toString()}");
          if(value['data'].isNotEmpty && value['data'].length > 0){
            //  print("report done ${value.toString()}");
            setState(() {
               prescription.addAll(value['data'].first);
              hasReport = true;
            });
            timer.cancel();
          }
        });
      });
  }

  @override
  void initState() {
    getPrescriptionData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print("prescriptionprescription ${prescription}");
    return  WillPopScope(
      onWillPop: () async {
        if(hasReport == true){
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => widget.defaultBackPage));
          // Get.offAll(const BottomNavigationBarView());
          return false;
        }
        else{
          return ( await onBackPressed(context: context,
            title: 'Exit Process?',
            subTitle: 'Are you sure you want to quit this process?',
            yes: "Yes",
            no: "No",
            onYesPressed: () {
              if( timer.isActive){
                timer.cancel();
              }
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => widget.defaultBackPage));
              // Get.offAll(const BottomNavigationBarView());
            },) )?? false;
        }
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: const Color(0xff246C54).withOpacity(0.8),
          body: SizedBox(
            height: MediaQuery.of(context).size.height,
            width:MediaQuery.of(context).size.width,
             child: Center(
                child: hasReport == true? SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                  
            const Text("Your Prescription", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold,),),
                     const SizedBox(height: 20,),
                     LayoutBuilder(builder: (context, constraints) {
                   final dynamicPresData = jsonDecode(prescription['body']);
                     return  Container(
                         constraints: BoxConstraints(
                           maxHeight: constraints.maxHeight,
                           minHeight: 200
                         ),
                         width: constraints.maxWidth - 20,
                         child: Table(
                             defaultVerticalAlignment : TableCellVerticalAlignment.middle,
                            border: TableBorder.all(color: Colors.grey, borderRadius: BorderRadius.circular(15)),
                           columnWidths: const {
                             0: FlexColumnWidth(.5), // Adjust the column widths as needed
                             1: FlexColumnWidth(.30),
                             2: FlexColumnWidth(.2),
                           },
                           children: [
                               const TableRow(
                                children: [
                                 TableCell(
                                   child: Padding(
                                     padding: EdgeInsets.all(8.0),
                                     child: Text(
                                       "Medicine",
                                       textAlign: TextAlign.center,
                                       style: TextStyle(
                                         color: Colors.white,
                                         fontSize: 17,
                                         fontWeight: FontWeight.bold,
                                       ),
                                       maxLines: 2,
                                       overflow: TextOverflow.ellipsis,
                                     ),
                                   ),
                                 ),
                                 TableCell(
                                   child: Padding(
                                     padding: EdgeInsets.all(8.0),
                                     child: Text(
                                       "Timing",
                                       textAlign: TextAlign.center,
                                       style: TextStyle(
                                         color: Colors.white,
                                         fontSize: 17,
                                         fontWeight: FontWeight.bold,
                                       ),
                                       maxLines: 2,
                                       overflow: TextOverflow.ellipsis,
                                     ),
                                   ),
                                 ),
                                 TableCell(
                                   child: Padding(
                                     padding: EdgeInsets.all(8.0),
                                     child: Text(
                                       "Days",
                                       textAlign: TextAlign.center,
                                       style: TextStyle(
                                         color: Colors.white,
                                         fontSize: 17,
                                         fontWeight: FontWeight.bold,
                                       ),
                                      ),
                                   ),
                                 ),
                               ],
                             ),
                             for (var data in dynamicPresData)
                               TableRow(
                                 children: [
                                   TableCell(
                                     child: Padding(
                                       padding: const EdgeInsets.all(8.0),
                                       child: Text(
                                         data["medicineName"] ?? "",
                                         textAlign: TextAlign.center,
                                         style: const TextStyle(
                                           color: Colors.white,
                                           fontSize: 16,
                                         ),
                                        ),
                                     ),
                                   ),
                                   TableCell(
                                     child: Padding(
                                       padding: const EdgeInsets.all(3.0),
                                       child: RichText(
                                         textAlign: TextAlign.center,
                                         text: TextSpan(
                                           style: const TextStyle(
                                             color: Colors.white,
                                             fontSize: 16,
                                           ),
                                           children: [
                                             TextSpan(
                                               text: "${data["timing"] ?? ""}",
                                             ),
                                             TextSpan(
                                               text: " (${data["mealTime"] ?? ""})",
                                               style: const TextStyle(
                                                 fontSize: 13
                                                ),
                                             ),
                                           ],
                                         ),
                                       ),
                                     ),
                                   ),
                                   TableCell(
                                     child: Padding(
                                       padding: const EdgeInsets.all(8.0),
                                       child: Text(
                                         data["frequency"].toString() ?? "",
                                         textAlign: TextAlign.center,
                                         style: const TextStyle(
                                           color: Colors.white,
                                           fontSize: 16,
                                         ),
                                         maxLines: 2,
                                         overflow: TextOverflow.ellipsis,
                                       ),
                                     ),
                                   ),
                                 ],
                               ),
                           ],
                         ),
                       );
                       }  ,),
                     const Text(
                       'Doctor advice',
                       style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,

                      ),
                    ),
                      Text("${prescription['advice']?? 'N/A'}", style: const TextStyle(color: Colors.white),),
                      const Gap(10),
                      if(prescription['follow_up'] != null)
                      const Text(
                       'Next Follow Up Date',
                       style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,

                      ),
                    ),
                      if(prescription['follow_up'] != null)
                      Text(
                        formatDate(timeStamp: "${prescription['follow_up']}",),
                        style: const TextStyle(
                            color: Colors.white
                        ),
                      ),
                      if(prescription['follow_up'] != null)
                      const Gap(10),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            minimumSize: Size(MediaQuery.sizeOf(context).width/2, 40)
                          ),
                          onPressed: () {
                            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => widget.defaultBackPage));
                            // Get.offAll(const BottomNavigationBarView());
                          }, child: const Text("Go Home", style: TextStyle( fontWeight: FontWeight.bold, color:  Colors.black,)))
                      // Text("${prescriptionList[0]['prescriptionBody']}", style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
                 : SingleChildScrollView(
                   child: Padding(
                     padding: const EdgeInsets.symmetric(horizontal: 10.0),
                     child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 200,
                          width: 300,
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child:  Lottie.asset('assets/lottimage/watingappp.json'),
                          ),
                        ),
                        const Text("Please wait", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),),
                        const Text("This may take up to 5 minutes", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 16),),
                        const Text("Or", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 16),),
                        const Text("You can go home. Your prescription will be added to your consultation history", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 16),),
                         const Gap(20),
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                            ),
                            onPressed: () {
                              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => widget.defaultBackPage));

                          // Get.offAll(const BottomNavigationBarView());
                        }, child: const Text("Go Home", style: TextStyle(color: Color(0xff246C54)),))
                        ],
                                     ),
                   ),
                 )),
          ),
        ),
      ),
    );
  }

}
