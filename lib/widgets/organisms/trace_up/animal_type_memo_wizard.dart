// animal_type_memo_wizard.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:wildlife_app/widgets/organisms/trace_up/photo_data.dart';

class AnimalTypeMemoWizard extends StatefulWidget {
  final File image;

  AnimalTypeMemoWizard({required this.image});

  @override
  _AnimalTypeMemoWizardState createState() => _AnimalTypeMemoWizardState();
}

class _AnimalTypeMemoWizardState extends State<AnimalTypeMemoWizard> {
  int _currentStep = 0;
  String? _animalType;
  String? _traceType;
  String? _elapsedForTrace;
  TextEditingController _memoController = TextEditingController();

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() {
        _currentStep += 1;
      });
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep -= 1;
      });
    }
  }

  void _completeSelection(BuildContext context) {
    Navigator.of(context).pop({
      'animalType': _animalType,
      'traceType': _traceType,
      'memo': _memoController.text,
      'elapsed_for_trace': _elapsedForTrace,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '痕跡情報入力',
          style: TextStyle(
            fontSize: 16.0,
          ),
        ),
        backgroundColor: Colors.white12,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(2.0),
          child: Container(
            color: Colors.grey,
            height: 2.0,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/assets/images/bg_image.png'),
            fit: BoxFit.cover,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: _buildCurrentStep(),
            ),
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildAnimalTypeSelection();
      case 1:
        return _buildTraceTypeSelection();
      case 2:
        return _buildMemoInput();
      default:
        return Container();
    }
  }

  Widget _buildAnimalTypeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '発見した痕跡の獣種を選択してください',
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            color: Colors.green[800],
          ),
        ),
        SizedBox(height: 20.0),
        Expanded(
          child: Center(
            child: Wrap(
              alignment: WrapAlignment.spaceEvenly,
              spacing: 20.0,
              runSpacing: 20.0,
              children: [
                _buildAnimalTypeButton('lib/assets/images/Boar.png','イノシシ','Boar'),
                _buildAnimalTypeButton('lib/assets/images/Deer.png','ニホンジカ','Deer'),
                _buildAnimalTypeButton('lib/assets/images/Other.png','その他/不明','Other'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTraceTypeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '痕跡の種類を選択してください',
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            color: Colors.green[800],
          ),
        ),
        SizedBox(height: 20.0),
        Expanded(
          child: Center(
            child: Wrap(
              alignment: WrapAlignment.spaceEvenly,
              spacing: 20.0,
              runSpacing: 20.0,
              children: [
                _buildTraceTypeButton('足跡', 'trace_footprint', Icons.pets),
                _buildTraceTypeButton('糞', 'trace_dropping', Icons.delete),
                _buildTraceTypeButton('その他', 'trace_others', Icons.park),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMemoInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '何日前の痕跡？',
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            color: Colors.green[800],
          ),
        ),
        SizedBox(height: 10.0),
        _buildElapsedForTraceSelection(),
        SizedBox(height: 20.0),
        Text(
          '備考を入力してください',
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            color: Colors.green[800],
          ),
        ),
        SizedBox(height: 20.0),
        Expanded(
          child: TextField(
            controller: _memoController,
            decoration: InputDecoration(
              labelText: '備考',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              contentPadding: EdgeInsets.all(16.0),
            ),
            maxLines: null,
            style: TextStyle(fontSize: 18.0),
          ),
        ),
      ],
    );
  }

  Widget _buildAnimalTypeButton(String imagePath, String label, String type) {
    return GestureDetector(
      onTap: () => setState(() {
        _animalType = type;
      }),
      child: Container(
        width: 120.0,
        height: 140.0,
        decoration: BoxDecoration(
          border: Border.all(
            color: _animalType == type ? Colors.green[800]! : Colors.grey,
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(16.0),
          color: _animalType == type
              ? Colors.green[100]
              : Colors.transparent,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              width: 60.0,
              height: 60.0,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 8.0),
            Text(
              label,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: _animalType == type ? Colors.green[800] : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTraceTypeButton(String label, String type, IconData icon) {
    return GestureDetector(
      onTap: () => setState(() {
        _traceType = type;
      }),
      child: Container(
        width: 120.0,
        height: 120.0,
        decoration: BoxDecoration(
          border: Border.all(
            color: _traceType == type ? Colors.green[800]! : Colors.grey,
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(16.0),
          color: _traceType == type
              ? Colors.green[100]
              : Colors.transparent,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40.0,
              color: _traceType == type ? Colors.green[800] : Colors.black,
            ),
            SizedBox(height: 8.0),
            Text(
              label,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: _traceType == type ? Colors.green[800] : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildElapsedForTraceSelection() {
    return Column(
      children: [
        ListTile(
          title: Text('真新しい'),
          leading: Radio<String>(
            value: 'flesh',
            groupValue: _elapsedForTrace,
            onChanged: (String? value) {
              setState(() {
                _elapsedForTrace = value;
              });
            },
          ),
        ),
        ListTile(
          title: Text('2~3日経過'),
          leading: Radio<String>(
            value: 'middle',
            groupValue: _elapsedForTrace,
            onChanged: (String? value) {
              setState(() {
                _elapsedForTrace = value;
              });
            },
          ),
        ),
        ListTile(
          title: Text('古い'),
          leading: Radio<String>(
            value: 'old',
            groupValue: _elapsedForTrace,
            onChanged: (String? value) {
              setState(() {
                _elapsedForTrace = value;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (_currentStep > 0)
          ElevatedButton(
            onPressed: _previousStep,
            child: Text('前へ'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
              textStyle: TextStyle(
                fontSize: 30.0,
              ),
              backgroundColor: Colors.green[900], // 背景色
              foregroundColor: Colors.white,        // テキスト色
            ),
          ),
        ElevatedButton(
          onPressed: _currentStep < 2 ? _nextStep : () => _completeSelection(context),
          child: Text(_currentStep < 2 ? '次へ' : '完了'),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
            textStyle: TextStyle(
              fontSize: 30.0,
            ),
            backgroundColor: Colors.green[900], // 背景色
            foregroundColor: Colors.white,        // テキスト色
          ),
        ),
      ],
    );
  }
}
