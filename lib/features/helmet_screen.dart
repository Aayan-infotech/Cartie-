import 'package:flutter/material.dart';

class HelmetScreen extends StatelessWidget {
  const HelmetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'Try a helmet',
          style: TextStyle(
              fontSize: 23, fontWeight: FontWeight.w600, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Why Helmet section
            Center(
              child: Column(
                children: [
                  Image.asset("assets/images/helmet.png"),
                  Text(
                    'Why Helmet',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),

            // Lorem Ipsum subsection
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Lorem Ipsum',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600, color: Colors.red),
              ),
            ),

            // About subsubsection
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
              child: Text(
                'About',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),

            // Content paragraph
            Text(
              'This article provides principles and steps for creating a realistic and achievable plan, '
              'including clarifying goals, breaking down big goals, creating a specific plan, '
              'establishing time management skills, setting up feedback mechanisms, '
              'and maintaining perseverance and discipline.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                  ),
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
    );
  }
}
