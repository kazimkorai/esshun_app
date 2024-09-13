import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import 'package:taxi_driver/clients/service/ChatMessagesService.dart';
import 'package:taxi_driver/clients/service/UserServices.dart';
import '../../model/FileModel.dart';
import '../model/LoginResponse.dart';
import '../utils/Extensions/StringExtensions.dart';

import '../../main.dart';

import '../../utils/Colors.dart';
import '../../utils/Common.dart';
import '../../utils/Constants.dart';
import '../../utils/Extensions/app_common.dart';
import '../model/ChatMessageModel.dart';
import '../model/FileModel.dart';
import 'ChatItemWidget.dart';

class ChatScreenClient extends StatefulWidget {
  final UserModel? userData;

  ChatScreenClient({this.userData});

  @override
  _ChatScreenClientState createState() => _ChatScreenClientState();
}

class _ChatScreenClientState extends State<ChatScreenClient> {
  String id = '';
  var messageCont = TextEditingController();
  var messageFocus = FocusNode();
  bool isMe = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  UserModel sender = UserModel(
    username: sharedPref.getString(USER_NAME),
    profileImage: sharedPref.getString(USER_PROFILE_PHOTO),
    uid: sharedPref.getString(UID),
    playerId: sharedPref.getString(PLAYER_ID),
  );

  init() async {
    id = sharedPref.getString(UID)!;

    chatMessageService = ChatMessageServiceClient();
    chatMessageService.setUnReadStatusToTrue(senderId: sender.uid!, receiverId: widget.userData!.uid.validate());
    setState(() {});
  }

  sendMessage({FilePickerResult? result}) async {
    if (result == null) {
      if (messageCont.text.trim().isEmpty) {
        messageFocus.requestFocus();
        return;
      }
    }
    ChatMessageModelClient data = ChatMessageModelClient();
    data.receiverId = widget.userData!.uid;
    data.senderId = sender.uid;
    data.message = messageCont.text;
    data.isMessageRead = false;
    data.createdAt = DateTime.now().millisecondsSinceEpoch;

    if (widget.userData!.uid == sharedPref.getString(UID)) {
      //
    }
    if (result != null) {
      if (result.files.single.path!.isNotEmpty) {
        data.messageType = MessageType.IMAGE.name;
      } else {
        data.messageType = MessageType.TEXT.name;
      }
    } else {
      data.messageType = MessageType.TEXT.name;
    }

    notificationService.sendPushNotifications(sharedPref.getString(USER_NAME)!, messageCont.text, receiverPlayerId: widget.userData!.playerId).catchError(log);
    messageCont.clear();
    setState(() {});
    return await chatMessageService.addMessage(data).then((value) async {
      if (result != null) {
        FileModel fileModel = FileModel();
        fileModel.id = value.id;
        fileModel.file = File(result.files.single.path!);
        fileList.add(fileModel);

        setState(() {});
      }

      await chatMessageService.addMessageToDb(value, data, sender, widget.userData, image: result != null ? File(result.files.single.path!) : null).then((value) {
        //
      });

      userService.fireStore
          .collection(USER_COLLECTION)
          .doc(sharedPref.getInt(USER_ID).toString())
          .collection(CONTACT_COLLECTION)
          .doc(widget.userData!.uid)
          .update({'lastMessageTime': DateTime.now().millisecondsSinceEpoch}).catchError((e) {
        log(e);
      });
      userService.fireStore
          .collection(USER_COLLECTION)
          .doc(widget.userData!.uid)
          .collection(CONTACT_COLLECTION)
          .doc(sharedPref.getInt(USER_ID).toString())
          .update({'lastMessageTime': DateTime.now().millisecondsSinceEpoch}).catchError((e) {
        log(e);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration:  BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: <Color>[
                  Color.fromRGBO(0, 52, 111, 1), // rgba(0, 52, 111, 1)
                  Color.fromRGBO(0, 112, 90, 1), // rgba(0, 112, 90, 1)
                ]),
          ),
        ),
        automaticallyImplyLeading: false,
        title: StreamBuilder<UserModel>(
          stream: UserServiceClient().singleUser(widget.userData!.uid),
          builder: (context, snap) {
            if (snap.hasData) {
              return Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),
                  SizedBox(width: 10),
                  CircleAvatar(backgroundImage: NetworkImage(widget.userData!.profileImage.validate()), minRadius: 20),
                  SizedBox(width: 10),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text(widget.userData!.firstName.validate(), style: TextStyle(color: Colors.white)),
                  ),
                ],
              );
            }
            return snapWidgetHelper(snap, loadingWidget: Offstage());
          },
        ),
        backgroundColor: primaryColorD,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: [
            Container(
              padding: EdgeInsets.only(bottom: 76),
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: PaginateFirestore(
                reverse: true,
                isLive: true,
                padding: EdgeInsets.only(left: 8, top: 8, right: 8, bottom: 0),
                physics: BouncingScrollPhysics(),
                query: chatMessageService.chatMessagesWithPagination(currentUserId: sharedPref.getString(UID), receiverUserId: widget.userData!.uid.validate()),
                itemsPerPage: PER_PAGE_CHAT_COUNT,
                shrinkWrap: true,
                onEmpty: Offstage(),
                itemBuilderType: PaginateBuilderType.listView,
                itemBuilder: (context, snap, index) {
                  ChatMessageModelClient data = ChatMessageModelClient.fromJson(snap[index].data() as Map<String, dynamic>);
                  data.isMe = data.senderId == sender.uid;
                  return ChatItemWidget(data: data);
                },
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: radius(),
                  color: Theme.of(context).cardColor,
                  boxShadow: [
                    BoxShadow(
                      spreadRadius: 0.5,
                      blurRadius: 0.5,
                    ),
                  ],
                ),
                padding: EdgeInsets.only(left: 8, right: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: messageCont,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: language.writeMessage,
                          hintStyle: secondaryTextStyle(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 8),
                        ),
                        cursorColor: appStoreClient.isDarkMode ? Colors.white : Colors.black,
                        focusNode: messageFocus,
                        textCapitalization: TextCapitalization.sentences,
                        keyboardType: TextInputType.multiline,
                        minLines: 1,
                        style: primaryTextStyle(),
                        textInputAction: mIsEnterKey ? TextInputAction.send : TextInputAction.newline,
                        onSubmitted: (s) {
                          sendMessage();
                        },
                        cursorHeight: 20,
                        maxLines: 5,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send, color: primaryColorD),
                      onPressed: () {
                        sendMessage();
                      },
                    )
                  ],
                ),
                width: MediaQuery.of(context).size.width,
              ),
            )
          ],
        ),
      ),
    );
  }
}
