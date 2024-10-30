// Все импорты, включая новые
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Импорт локализации
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_chat_bubble/bubble_type.dart';
import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_4.dart';
import 'package:file_picker/file_picker.dart'; // Импорт пакета для выбора файлов
import 'package:image_picker/image_picker.dart'; // Импорт пакета для выбора изображений
import 'dart:io';
import 'package:photo_view/photo_view.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:open_file/open_file.dart';
import '../../models/message_model.dart';
import 'package:lottie/lottie.dart';

class SupportView extends StatefulWidget {
  @override
  _SupportViewState createState() => _SupportViewState();
}

class _SupportViewState extends State<SupportView> {
  TextEditingController _messageController = TextEditingController();
  List<Message> messages = [];

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      resizeToAvoidBottomInset: true, // Позволяет экрану сжиматься при появлении клавиатуры
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          localizations.support,
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus(); // Скрывает клавиатуру при нажатии вне поля ввода
        },
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: messages.isEmpty
                      ? Center(
                      child: Text(
                        'Нет сообщений',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    )
                      : ListView.builder(
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[messages.length - 1 - index];
                      final previousMessage = index < messages.length - 1
                          ? messages[messages.length - 2 - index]
                          : null;

                      // Проверка, нужно ли отображать дату
                      bool showDate = previousMessage == null ||
                          message.timestamp.day != previousMessage.timestamp.day ||
                          message.timestamp.month != previousMessage.timestamp.month ||
                          message.timestamp.year != previousMessage.timestamp.year;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (showDate)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                '${message.timestamp.day} ${_getMonthName(message.timestamp.month)} ${message.timestamp.year}',
                                style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          if (message.type == 'text')
                            message.isUser
                                ? _buildUserMessage(context, message)
                                : _buildSupportMessage(context, message)
                          else if (message.type == 'file')
                            message.isUser
                                ? _buildUserFileMessage(context, message)
                                : _buildSupportFileMessage(context, message.content)
                          else if (message.type == 'image')
                              message.isUser
                                  ? _buildUserImageMessage(context, message)
                                  : _buildSupportImageMessage(context, message)
                            else
                              SizedBox.shrink(),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
            _buildInputArea(context),
          ],
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'января', 'февраля', 'марта', 'апреля', 'мая', 'июня',
      'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря'
    ];
    return months[month - 1];
  }

  Widget _buildInputArea(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Container(
      padding: EdgeInsets.only(
        left: 8.0,
        right: 8.0,
        bottom: 8.0,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          IconButton(
            icon: Icon(Icons.attach_file),
            onPressed: () {
              _showAttachmentOptions(context);
            },
          ),
          Expanded(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: 150.0,
              ),
              child: Scrollbar(
                child: SingleChildScrollView(
                  reverse: true,
                  child: TextField(
                    controller: _messageController,
                    maxLines: null,
                    minLines: 1,
                    decoration: InputDecoration(
                      hintText: localizations.typeYourMessage,
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send, color: Colors.blue),
            onPressed: () {
              if (_messageController.text.trim().isNotEmpty) {
                _sendMessage(_messageController.text);
              }
            },
          ),
        ],
      ),
    );
  }

  void _sendMessage(String text) {
    final newMessage = Message(
      type: 'text',
      content: text.trim(),
      isUser: true,
      status: 'pending',
      timestamp: DateTime.now(), // Добавляем время отправки
    );

    setState(() {
      messages.add(newMessage);
      _messageController.clear();
    });

    _updateMessageStatus(newMessage);
  }

  void _updateMessageStatus(Message message) {
    // Имитация отправки на сервер
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        message.status = 'sent';
      });

      // Имитация прочтения сообщения
      Future.delayed(Duration(seconds: 2), () {
        setState(() {
          message.status = 'read';
        });
      });
    });
  }

  void _showAttachmentOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.insert_drive_file),
              title: Text('Файл'),
              onTap: () {
                Navigator.pop(context);
                _pickFile();
              },
            ),
            ListTile(
              leading: Icon(Icons.photo),
              title: Text('Изображение'),
              onTap: () {
                Navigator.pop(context);
                _pickImage();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      PlatformFile file = result.files.first;

      final newMessage = Message(
        type: 'file',
        content: file.name,
        isUser: true,
        status: 'pending',
        timestamp: DateTime.now(), // Добавляем время отправки
      );

      setState(() {
        messages.add(newMessage);
      });

      _updateMessageStatus(newMessage);
    }
  }

  void _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final newMessage = Message(
        type: 'image',
        content: image.path,
        isUser: true,
        status: 'pending',
        timestamp: DateTime.now(), // Добавляем время отправки
      );

      setState(() {
        messages.add(newMessage);
      });

      _updateMessageStatus(newMessage);
    }
  }

  Widget _buildUserMessage(BuildContext context, Message message) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            child: ChatBubble(
              clipper: ChatBubbleClipper4(type: BubbleType.sendBubble),
              alignment: Alignment.topRight,
              margin: EdgeInsets.only(top: 8),
              backGroundColor: Colors.blue[100],
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.6,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      message.content,
                      style: TextStyle(color: Colors.black),
                    ),
                    SizedBox(height: 4), // Отступ между сообщением и временем
                    Text(
                      '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}', // Отображение времени
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: 4),
          _buildStatusIcon(message.status),
        ],
      ),
    );
  }


  Widget _buildSupportMessage(BuildContext context, Message message) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ChatBubble(
        clipper: ChatBubbleClipper4(type: BubbleType.receiverBubble),
        backGroundColor: Colors.blue,
        margin: EdgeInsets.only(top: 8),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message.content,
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 4), // Отступ между сообщением и временем
              Text(
                '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}', // Отображение времени
                style: TextStyle(color: Colors.grey[300], fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildUserFileMessage(BuildContext context, Message message) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            child: ChatBubble(
              clipper: ChatBubbleClipper4(type: BubbleType.sendBubble),
              alignment: Alignment.topRight,
              margin: EdgeInsets.only(top: 8),
              backGroundColor: Colors.blue[100],
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.6,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.attach_file, color: Colors.black),
                        SizedBox(width: 8),
                        Flexible(
                          child: InkWell(
                            onTap: () {
                              // Здесь логика для открытия файла
                              _openFile(message.content);
                            },
                            child: Text(
                              message.content,
                              style: TextStyle(
                                color: Colors.blue, // Цвет, как у ссылки
                                decoration: TextDecoration.underline,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4), // Отступ между файлом и временем
                    Text(
                      '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}', // Отображение времени
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: 4),
          _buildStatusIcon(message.status),
        ],
      ),
    );
  }

  // Метод для открытия файла
  void _openFile(String filePath) async {
    // Проверяем, является ли путь URL (обычно начинается с 'http' или 'https')
    if (filePath.startsWith('http') || filePath.startsWith('https')) {
      final Uri url = Uri.parse(filePath);
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        throw 'Не удалось открыть URL: $filePath';
      }
    } else {
      // Для локального файла используем open_file
      final result = await OpenFile.open(filePath);
      if (result.type != ResultType.done) {
        print("Не удалось открыть файл: $filePath");
      }
    }
  }



  Widget _buildSupportFileMessage(BuildContext context, String fileName) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ChatBubble(
        clipper: ChatBubbleClipper4(type: BubbleType.receiverBubble),
        backGroundColor: Colors.blue,
        margin: EdgeInsets.only(top: 8),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.attach_file, color: Colors.white),
              SizedBox(width: 8),
              Flexible(
                child: Text(
                  fileName,
                  style: TextStyle(color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserImageMessage(BuildContext context, Message message) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            child: GestureDetector(
              onTap: () {
                _showFullScreenImage(context, message.content); // Вызов функции для увеличения
              },
              child: ChatBubble(
                clipper: ChatBubbleClipper4(type: BubbleType.sendBubble),
                alignment: Alignment.topRight,
                margin: EdgeInsets.only(top: 8),
                backGroundColor: Colors.blue[100],
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.6,
                    maxHeight: 200, // Ограничение по высоте
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Image.file(
                          File(message.content),
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(height: 4), // Отступ между изображением и временем
                      Text(
                        '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}', // Отображение времени
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 4),
          _buildStatusIcon(message.status),
        ],
      ),
    );
  }


  // Функция для показа изображения на весь экран
  void _showFullScreenImage(BuildContext context, String imagePath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            iconTheme: IconThemeData(color: Colors.white),
            elevation: 0,
          ),
          body: Center(
            child: PhotoView(
              imageProvider: FileImage(File(imagePath)),
              backgroundDecoration: BoxDecoration(
                color: Colors.black,
              ),
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 2.0,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSupportImageMessage(BuildContext context, Message message) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: GestureDetector(
        onTap: () {
          _showFullScreenImage(context, message.content); // Вызов функции для увеличения
        },
        child: ChatBubble(
          clipper: ChatBubbleClipper4(type: BubbleType.receiverBubble),
          backGroundColor: Colors.blue,
          margin: EdgeInsets.only(top: 8),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
              maxHeight: 200,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Image.file(
                    File(message.content),
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: 4), // Отступ между изображением и временем
                Text(
                  '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}', // Отображение времени
                  style: TextStyle(color: Colors.grey[300], fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }



  Widget _buildStatusIcon(String status) {
    IconData iconData;
    Color iconColor = Colors.grey;

    switch (status) {
      case 'pending':
        iconData = Icons.access_time; // Иконка часов
        break;
      case 'sent':
        iconData = Icons.check; // Одна галочка
        break;
      case 'read':
        iconData = Icons.done_all; // Две галочки
        iconColor = Colors.blue; // Цвет для прочитанного сообщения
        break;
      default:
        iconData = Icons.access_time;
    }

    return Icon(
      iconData,
      size: 16,
      color: iconColor,
    );
  }
}
