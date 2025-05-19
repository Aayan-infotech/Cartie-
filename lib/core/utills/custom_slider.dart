// Replace the existing SliderButton widget with this CustomSliderButton


// Add this new widget class at the bottom of your file
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomSliderButton extends StatefulWidget {
  final VoidCallback onSlideComplete;

  const CustomSliderButton({super.key, required this.onSlideComplete});

  @override
  State<CustomSliderButton> createState() => _CustomSliderButtonState();
}

class _CustomSliderButtonState extends State<CustomSliderButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _dragPosition = 0.0;
  double _maxDrag = 0.0;
  final double _thumbSize = 40.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _resetPosition() {
    final animation = Tween<double>(begin: _dragPosition, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );
    
    animation.addListener(() {
      setState(() {
        _dragPosition = animation.value;
      });
    });

    _controller.forward(from: 0).then((_) => _controller.reset());
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _maxDrag = constraints.maxWidth - _thumbSize;
        
        return Container(
          height: 50,
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Stack(
            children: [
              // Slider text
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Take Assignment",
                    style: GoogleFonts.montserrat(
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              
              // Draggable thumb
              Positioned(
                left: _dragPosition,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    final newPosition = (_dragPosition + details.delta.dx)
                        .clamp(0.0, _maxDrag);
                    setState(() => _dragPosition = newPosition);
                  },
                  onHorizontalDragEnd: (details) {
                    if (_dragPosition >= _maxDrag * 0.8) {
                      widget.onSlideComplete();
                    } else {
                      _resetPosition();
                    }
                  },
                  child: Container(
                    width: _thumbSize,
                    height: _thumbSize,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}