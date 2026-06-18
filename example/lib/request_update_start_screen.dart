import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:idenfy_sdk_flutter/idenfy_sdk_flutter.dart';
import 'package:idenfy_sdk_flutter/models/information_update_result.dart';
import 'constants.dart' as Constants;
import 'main.dart';

class RequestUpdateStartScreen extends StatefulWidget {
  @override
  State<RequestUpdateStartScreen> createState() =>
      _RequestUpdateStartScreenState();
}

class _RequestUpdateStartScreenState extends State<RequestUpdateStartScreen> {
  InformationUpdateResult? _informationUpdateResult;
  Exception? _exception;

  TextEditingController _scanRefController = TextEditingController();
  TextEditingController _questionnaireIdController = TextEditingController();
  bool _additionalStepUploadRequired = true;

  @override
  void dispose() {
    super.dispose();
    _scanRefController.dispose();
    _questionnaireIdController.dispose();
  }

  Future<String> getRequestUpdateToken(String scanRef) async {
    Map<String, dynamic> body = {
      "additionalStepUploadRequired": _additionalStepUploadRequired,
    };
    if (_questionnaireIdController.text.isNotEmpty) {
      body["questionnaire"] = _questionnaireIdController.text;
    }

    final response = await http.post(
      Uri.https(Constants.BASE_URL,
          '/kyc/identifications/$scanRef/request-information/'),
      headers: <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization':
            'Basic ${base64Encode(utf8.encode('${Constants.apiKey}:${Constants.apiSecret}'))}',
      },
      body: jsonEncode(body),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body)["tokenString"];
    } else {
      throw Exception('Failed to fetch request update token');
    }
  }

  Future<void> callRequestUpdate(String scanRef) async {
    InformationUpdateResult? informationUpdateResult;
    Exception? localException;
    try {
      String token = await getRequestUpdateToken(scanRef);
      informationUpdateResult =
          await IdenfySdkFlutter.startRequestUpdate(token);
    } on Exception catch (e) {
      localException = e;
    }

    setState(() {
      _informationUpdateResult = informationUpdateResult;
      _exception = localException;
      _scanRefController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyApp(),
                  ),
                );
              },
              icon: Icon(Icons.arrow_back,
                  color: Color.fromRGBO(83, 109, 254, 1))),
          title: Image.asset('assets/ic_idenfy_logo_vector_v2.png',
              width: 70, fit: BoxFit.cover),
          centerTitle: true,
          backgroundColor: Colors.white,
          systemOverlayStyle:
              SystemUiOverlayStyle(statusBarBrightness: Brightness.light),
        ),
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Column(
            children: [
              topTitle(),
              Spacer(),
              centerInputs(),
              Spacer(),
              _informationUpdateResult != null
                  ? requestUpdateResult()
                  : (_exception != null ? exceptionTitle() : Container()),
              Spacer(),
              beginRequestUpdateButton()
            ],
          ),
        ),
      ),
    );
  }

  Widget centerInputs() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          SizedBox(
            width: 300,
            child: TextField(
                controller: _scanRefController,
                decoration: InputDecoration(
                  labelText: "ScanRef",
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color.fromRGBO(83, 109, 254, 1),
                    ),
                  ),
                  hintText: "ScanRef",
                  counterText: '',
                  hintStyle: const TextStyle(
                      color: Colors.grey, fontWeight: FontWeight.normal),
                  labelStyle: const TextStyle(
                      color: Colors.grey, fontWeight: FontWeight.normal),
                ),
                maxLength: 50,
                textAlign: TextAlign.start,
                onChanged: (String code) => {setState(() => {})}),
          ),
          SizedBox(height: 12),
          SizedBox(
            width: 300,
            child: TextField(
                controller: _questionnaireIdController,
                decoration: InputDecoration(
                  labelText: "Questionnaire ID (optional)",
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color.fromRGBO(83, 109, 254, 1),
                    ),
                  ),
                  hintText: "Questionnaire ID",
                  counterText: '',
                  hintStyle: const TextStyle(
                      color: Colors.grey, fontWeight: FontWeight.normal),
                  labelStyle: const TextStyle(
                      color: Colors.grey, fontWeight: FontWeight.normal),
                ),
                maxLength: 50,
                textAlign: TextAlign.start),
          ),
          SizedBox(height: 12),
          SizedBox(
            width: 300,
            child: Row(
              children: [
                Switch(
                  value: _additionalStepUploadRequired,
                  activeColor: Color.fromRGBO(83, 109, 254, 1),
                  onChanged: (bool value) {
                    setState(() {
                      _additionalStepUploadRequired = value;
                    });
                  },
                ),
                SizedBox(width: 8),
                Flexible(
                  child: Text(
                    "Additional Step Upload Required",
                    style:
                        TextStyle(fontFamily: "HKGrotesk_regular", fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget requestUpdateResult() {
    return _informationUpdateResult == null
        ? Container()
        : Container(
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.black,
                ),
                children: <TextSpan>[
                  TextSpan(
                      text: "InformationUpdateStatus:  \n",
                      style: TextStyle(
                          height: 4,
                          color: Color.fromRGBO(83, 109, 254, 1),
                          fontFamily: "HKGrotesk_bold",
                          fontSize: 18)),
                  TextSpan(
                    text:
                        "${_informationUpdateResult!.informationUpdateStatus}",
                    style: TextStyle(
                        fontFamily: "HKGrotesk_regular", fontSize: 14),
                  ),
                ],
              ),
            ),
          );
  }

  Widget exceptionTitle() {
    return Container(
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: TextStyle(
            fontSize: 14.0,
            color: Colors.black,
          ),
          children: <TextSpan>[
            TextSpan(
              text: _exception.toString(),
              style: TextStyle(
                  height: 4,
                  color: Colors.red,
                  fontFamily: "HKGrotesk_bold",
                  fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }

  Widget beginRequestUpdateButton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 40, left: 24, right: 24),
      child: Container(
        height: 42,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              if (_scanRefController.text.isEmpty) ...[
                Colors.grey.withOpacity(0.6),
                Colors.grey.withOpacity(0.6)
              ] else ...[
                Color.fromRGBO(83, 109, 254, 1),
                Color.fromRGBO(141, 108, 251, 1)
              ]
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.all(
            Radius.circular(4),
          ),
        ),
        child: InkWell(
          onTap: _scanRefController.text.isEmpty
              ? null
              : () => callRequestUpdate(_scanRefController.text),
          child: Center(
            child: Text(
              "BEGIN REQUEST UPDATE",
              style:
                  TextStyle(fontFamily: "HKGrotesk_bold", color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  Widget topTitle() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 24),
            child: Text(
              "Sample iDenfy App",
              style: TextStyle(fontFamily: "HKGrotesk_bold", fontSize: 22),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
            child: Text(
              "Enter an identification scanRef and begin the request update process!",
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: "HKGrotesk_regular", fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
