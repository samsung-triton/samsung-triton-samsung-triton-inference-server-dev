// 모델 로그 화면 위젯
import 'package:flutter/material.dart';
import 'package:triton/widgets/modellog/filter_block.dart';

class ModelLogScreen extends StatefulWidget {
  const ModelLogScreen({super.key});

  @override
  State<ModelLogScreen> createState() => _ModelLogScreenState();
}

class _ModelLogScreenState extends State<ModelLogScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              FilterBlock(),
              SizedBox(height: 16),
              Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text("Model Log")),
            ],
          ),
        ),
      ),
    );
  }
}
