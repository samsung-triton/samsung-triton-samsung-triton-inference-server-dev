// 모델 관리 위젯
import 'package:flutter/material.dart';

class ModelManageScreen extends StatefulWidget {
  const ModelManageScreen({super.key});

  @override
  State<ModelManageScreen> createState() => _ModelManageScreenState();
}

class _ModelManageScreenState extends State<ModelManageScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Text("Model Manage"));
  }
}
