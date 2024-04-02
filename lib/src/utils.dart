part of db_agora_call;


void showErrorSnackBar(BuildContext context, {required String message, Color? background}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
          message,
        style: const TextStyle(
          color: Colors.white
        ),
      ),
      backgroundColor: Color(0xFFE52020),
      showCloseIcon: true,
    ),
  );
}

Future<bool> onBackPressed({
  required BuildContext context,
  String? no,
  String? yes,
  String? title,
  String? subTitle,
  VoidCallback? onYesPressed
}) async {
  return (await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(16.0)),
        backgroundColor:   Colors.white,
        title:   Text(title??'Exit App?',style: const TextStyle(color: Colors.black),),
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w700,
          fontSize: 36,
        ),
        content:   Text(
          subTitle?? 'Are you sure you want to exit the app?',
        ),
        contentTextStyle: const TextStyle(
          color: Color(0xFF507267),
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        actions: <Widget>[
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(false); // Cancel the exit
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(100, 40),
                    backgroundColor: const Color(0xFF246C54),

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),

                  child:   Text(
                    no?? 'Stay',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                ),

                ElevatedButton(
                  onPressed: () {
                    if(onYesPressed != null){
                      return onYesPressed();
                    }
                    // Navigator.of(context).pop(true); // Confirm the exit
                    SystemNavigator.pop();
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(100, 40),
                    backgroundColor: const Color(0xFF246C54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child:  Text(
                    yes??'Exit App',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],

            ),
          ),


        ],
      );
    },
  ) ) ?? false;
}

String formatDate({required String timeStamp, String formatPattern = 'dd MMMM yyyy'}){
final dateTime = DateTime.parse(timeStamp);
DateTime bangladeshDateTime = dateTime.add(const Duration(hours: 6));
// Format the date using Intl
final formattedDate = DateFormat(formatPattern).format(bangladeshDateTime);
return formattedDate;
}