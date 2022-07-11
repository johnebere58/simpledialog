import 'dart:async';
import 'dart:ui';
import 'package:dialogpack/src/assets/color_assets.dart';
import 'package:flutter/material.dart';
import 'package:dialogpack/src/assets/string_assets.dart';
import 'package:dialogpack/src/blocs/message_dialog_controller.dart';
import 'package:dialogpack/src/models/message_dialog_model.dart';
import 'package:dialogpack/src/utils/widget_utils.dart';


class MessageDialog extends StatefulWidget {
  final MessageDialogModel messageDialogModel;
  final String dialogId; ///Specify dialogId if you wish to terminate this dialog manually

  const MessageDialog(
  {required this.messageDialogModel,this.dialogId=DEFAULT_MESSAGE_DIALOG_ID, Key? key}):super(key:key);

  @override
  MessageDialogState createState() => MessageDialogState();
}

class MessageDialogState extends State<MessageDialog> {

  final List<StreamSubscription> _streamSubscriptions = [];
  late MessageDialogModel messageDialogModel;
  bool showBack=false;
  bool hideUI=true;

  @override
  void initState() {
    messageDialogModel = widget.messageDialogModel;
    super.initState();

    Future.delayed(const Duration(milliseconds: 200),(){
      hideUI=false;
      setState(() {});
    });
    Future.delayed(const Duration(milliseconds: 500),(){
      showBack=true;
      setState(() {

      });
    });

    _streamSubscriptions.add(
      MessageDialogController.instance.stream.listen((String? id) {
        if(id == widget.dialogId){
          closePage(() async {
            Navigator.pop(context);
          });
        }
      })
    );
  }

  @override
  void dispose() {
    for(StreamSubscription stream in _streamSubscriptions) {
      stream.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    bool cancellable = messageDialogModel.cancellableOnTapOutside;

    return WillPopScope(
      onWillPop: () {

        if (cancellable)closePage((){ Navigator.pop(context);});

        return Future.value(false);
      },
      child: Stack(fit: StackFit.expand, children: <Widget>[
        GestureDetector(
          onTap: () {
            if (cancellable) closePage((){ Navigator.pop(context);});
          },
          child: AnimatedOpacity(
            opacity: showBack?1:0,duration: const Duration(milliseconds: 300),
            child: ClipRect(
                child:BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
                    child: Container(
                      color: blackColor.withOpacity(.7),
                    ))
            ),
          ),
        ),
        page()
      ]),
    );
  }

  Widget page() {

    IconData? icon = messageDialogModel.icon;
    // String? image = messageDialogModel.assetImage;
    String? title = messageDialogModel.title;
    String message = messageDialogModel.message;
    Color iconColor = messageDialogModel.iconColor;
    double iconSize = messageDialogModel.iconSize;
    String positiveText = messageDialogModel.positiveClickText;
    String? negativeText = messageDialogModel.negativeClickText;
    String? neutralText = messageDialogModel.neutralClickText;
    Function? positiveClick = messageDialogModel.onPositiveClicked;
    Function? negativeClick = messageDialogModel.onNegativeClicked;
    Function? neutralClick = messageDialogModel.onNeutralClicked;
    Color positiveTextColor = messageDialogModel.positiveTextColor;
    Color negativeTextColor = messageDialogModel.negativeTextColor;
    Color neutralTextColor = messageDialogModel.neutralTextColor;
    Color? messageTextColor = messageDialogModel.messageTextColor;
    Color? titleTextColor = messageDialogModel.titleTextColor;
    bool autoDismiss = messageDialogModel.autoDismissAfterClick;

    return Center(
      child: Container(
        margin: const EdgeInsets.fromLTRB(40, 0, 40, 0),
        // constraints: BoxConstraints(
        //   maxWidth: getScreenWidth(context)>500?500
        //       :double.infinity,
        //   minWidth: getScreenWidth(context)/2
        // ),
        child: Card(
          clipBehavior: Clip.antiAlias,
          color: Colors.white,elevation: 5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[

              Padding(
                padding: const EdgeInsets.fromLTRB(20,20,20,15),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // if(image!=null || icon!=null)Container(
                    //     padding: EdgeInsets.all(
                    //         iconPadding),
                    //     decoration: const BoxDecoration(
                    //       shape: BoxShape.circle,
                    //     ),
                    //     child: (icon == null && image !=null)
                    //         ? (Image.asset(
                    //           image,
                    //           color: iconColor,
                    //           width: 45,
                    //           height: 45,
                    //     ))
                    //         : Icon(
                    //       icon,
                    //       color: iconColor,
                    //       size: 75,
                    //     )),
                    if(icon!=null)Icon(
                      icon,
                      color: iconColor,
                      size: iconSize,
                    ),
                    addSpace(20),
                    if(title!=null)Container(
                      margin: const EdgeInsets.only(bottom: 5),
                      child: Text(
                        title,
                        style: textStyle(true, 20, titleTextColor??blackColor),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Flexible(
                      child: SingleChildScrollView(
                        child: Text(
                          message,
                          style: textStyle(false,
                              title==null?20:
                              16,
                              title==null?blackColor:( messageTextColor ?? blackColor2)),
                          textAlign: TextAlign.center,
//                                    maxLines: 1,
                        ),
                      ),
                    ),
                    if(message.isNotEmpty)addSpace(10),
                  ],
                ),
              ),

              addLine(1, blackColor.withOpacity(bestOpacity), 0, 0, 0, 0),

              Padding(
                padding: const EdgeInsets.fromLTRB(10,10,10,20),
                child: Wrap(
                  // mainAxisSize: MainAxisSize.min,
                  alignment: WrapAlignment.center,
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                      child: TextButton(
                          style: TextButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25)),
                            padding: const EdgeInsets.fromLTRB(15, 0, 15, 0)
                          ),
                          onPressed: () {
                            if(autoDismiss){
                              closePage(() async {
                                Navigator.pop(context);
                                await Future.delayed(const Duration(milliseconds: 200));
                                if(positiveClick!=null)positiveClick();
                              });
                            }else{
                              if(positiveClick!=null)positiveClick();
                            }
                          },
                          child: Text(
                            positiveText,
                            maxLines: 1,
                            style: textStyle(true, 18, positiveTextColor),
                          )),
                    ),
                    // if(noText!=null)addSpaceWidth(10),
                    if(negativeText!=null)Container(
                        margin: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                      child: TextButton(
                          style: TextButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                              // side: BorderSide(color: red0,width: 2)
                            ),
                            padding: const EdgeInsets.fromLTRB(15, 0, 15, 0)
                          ),
//                                    color: blue3,
                          onPressed: () {
                            if(autoDismiss){
                              closePage(()async{
                                Navigator.pop(context);
                                await Future.delayed(const Duration(milliseconds: 200));
                                if(negativeClick!=null)negativeClick();
                              });
                            }else{
                              if(negativeClick!=null)negativeClick();
                            }
                          },
                          child: Text(
                            negativeText,maxLines: 1,
                            style: textStyle(true, 18, negativeTextColor),
                          )),
                    ),
                    if(neutralText!=null)Container(
                        margin: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                      child: TextButton(
                          style: TextButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                              // side: BorderSide(color: red0,width: 2)
                            ),
                            padding: const EdgeInsets.fromLTRB(15, 0, 15, 0)
                          ),
//                                    color: blue3,
                          onPressed: () {
                            if(autoDismiss) {
                              closePage(() async {
                                Navigator.pop(context);
                                await Future.delayed(
                                    const Duration(milliseconds: 200));
                                if (neutralClick != null) neutralClick();
                              });
                            }else{
                              if (neutralClick != null) neutralClick();
                            }
                          },
                          child: Text(
                            neutralText,maxLines: 1,
                            style: textStyle(true, 18, neutralTextColor),
                          )),
                    ),

                  ],
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

  closePage(onClosed){
    showBack=false;
    if(mounted)setState(() {});
    Future.delayed(const Duration(milliseconds: 300),(){
      Future.delayed(const Duration(milliseconds: 100),(){
        hideUI=true;
        if(mounted )setState(() {});
      });
      onClosed();
    });
  }
}

