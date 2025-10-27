// 모델 로그 화면 위젯
import 'package:flutter/material.dart';

class ModelLogScreen extends StatefulWidget {
  const ModelLogScreen({super.key});

  @override
  State<ModelLogScreen> createState() => _ModelLogScreenState();
}

class _ModelLogScreenState extends State<ModelLogScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Text("Model Log"));
  }
}
