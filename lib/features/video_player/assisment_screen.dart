import 'package:flutter/material.dart';

class Question {
  final String text;
  final List<String> options;

  Question(this.text, this.options);
}

class AssessmentScreen extends StatefulWidget {
  @override
  _AssessmentScreenState createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen> {
  int currentQuestionIndex = 0;
  int? selectedAnswerIndex;
  final List<Question> questions = [
    Question(
      "What do you do if you are traveling down the road and you get a line of automobiles behind you and you are impeding traffic?",
      [
        "Put on your turn signal, pull over in a safe spot and wave them by",
        "Keep going get the fastest speed that you are able to travel.",
        "Turn around and go to the opposite direction",
        "Keep traveling until you reach your destination",
      ],
    ),
    Question(
      "When approaching a traffic light that turns yellow, you should:",
      [
        "Speed up to beat the red light",
        "Come to a complete stop",
        "Slow down and prepare to stop",
        "Honk horn and proceed",
      ],
    ),
    // Add more dummy questions here
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: const Text(
          "Driving Assessment",
          style: TextStyle(
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 20),
            child: Center(
              child: Text(
                "${currentQuestionIndex + 1}/${questions.length}",
                style: TextStyle(color: Colors.red, fontSize: 18),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              questions[currentQuestionIndex].text,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 30),
            Expanded(
              child: ListView.separated(
                itemCount: questions[currentQuestionIndex].options.length,
                separatorBuilder: (context, index) => SizedBox(height: 15),
                itemBuilder: (context, index) {
                  return OptionCard(
                    optionText: questions[currentQuestionIndex].options[index],
                    isSelected: selectedAnswerIndex == index,
                    onTap: () => setState(() => selectedAnswerIndex = index),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: currentQuestionIndex > 0
                      ? () => setState(() {
                            currentQuestionIndex--;
                            selectedAnswerIndex = null;
                          })
                      : null,
                  child: Text("Previous"),
                ),
                ElevatedButton(
                  onPressed: currentQuestionIndex < questions.length - 1
                      ? () => setState(() {
                            currentQuestionIndex++;
                            selectedAnswerIndex = null;
                          })
                      : null,
                  child: const Text("Next"),
                ),
              ],
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                /* Handle result */
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red[800]),
              child: Text(
                "See Result ✓",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OptionCard extends StatelessWidget {
  final String optionText;
  final bool isSelected;
  final VoidCallback onTap;

  const OptionCard({
    required this.optionText,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? Colors.red : Colors.transparent,
            width: 2,
          ),
        ),
        child: Text(
          optionText,
          style: TextStyle(
            color: isSelected ? Colors.red : Colors.white,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
