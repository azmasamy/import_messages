import 'package:flutter/material.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

enum ContactsSceenState { init, loading, loaded }

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ContactsSceenState state = ContactsSceenState.init;
  List<SmsMessage> messages = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: buildBody(),
    );
  }

  buildBody() {
    switch (state) {
      case ContactsSceenState.init:
        return Center(
          child: ElevatedButton(
              onPressed: () async {
                // Request contact permission
                setState(() {
                  state = ContactsSceenState.loading;
                });
                await Permission.sms.request();
                var permission = await Permission.sms.status;
                if (permission.isGranted) {
                  messages = await SmsQuery().getAllSms;
                  setState(() {
                    state = ContactsSceenState.loaded;
                  });
                } else {
                  setState(() {
                    state = ContactsSceenState.init;
                  });
                }
              },
              child: const Text("Import Messages")),
        );
      case ContactsSceenState.loading:
        return const Center(child: CircularProgressIndicator());
      case ContactsSceenState.loaded:
        return SafeArea(
            child: ListView.builder(
          itemCount: messages.length,
          itemBuilder: (context, index) => ListTile(
            leading: Text(messages[index].id.toString()),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(messages[index].date.toString()),
                Text(messages[index].sender ?? 'Draft'),
              ],
            ),
            subtitle: Text(messages[index].body ?? 'Draft'),
          ),
        ));
    }
  }
}
