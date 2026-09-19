import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class AnimatedCentralButton extends StatefulWidget {
  final bool isRecipeTab;
  final VoidCallback onAddPressed;
  final VoidCallback onRecipePressed;

  const AnimatedCentralButton({
    super.key,
    required this.isRecipeTab,
    required this.onAddPressed,
    required this.onRecipePressed,
  });

  @override
  State<AnimatedCentralButton> createState() => _AnimatedCentralButtonState();
}

class _AnimatedCentralButtonState extends State<AnimatedCentralButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _rotated = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      lowerBound: 0.0,
      upperBound: 0.1,
    );
  }

  @override
  void didUpdateWidget(covariant AnimatedCentralButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.isRecipeTab && oldWidget.isRecipeTab) {
      // reset rotation when switching back
      setState(() {
        _rotated = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleAddTap() async {
    setState(() {
      _rotated = !_rotated;
    });
    await _controller.forward();
    await _controller.reverse();
    widget.onAddPressed();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedAlign(
      duration: const Duration(milliseconds: 400),
      alignment: Alignment.bottomCenter,
      curve: Curves.easeInOut,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: widget.isRecipeTab ? 100 : 20,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: GestureDetector(
            onTap:
                widget.isRecipeTab ? widget.onRecipePressed : _handleAddTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              width: widget.isRecipeTab ? 200 : 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.darkOrange, AppColors.primaryOrange],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(
                    widget.isRecipeTab ? 20 : 30),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryOrange.withValues(alpha: 0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Center(
                child: widget.isRecipeTab
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.add, color: Colors.white, size: 28),
                          SizedBox(width: 8),
                          Text(
                            "Ajouter une recette",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      )
                    : ScaleTransition(
                        scale: Tween(begin: 1.0, end: 1.1).animate(
                          CurvedAnimation(
                              parent: _controller,
                              curve: Curves.easeOutBack),
                        ),
                        child: AnimatedRotation(
                          turns: _rotated ? 0.25 : 0.0,
                          duration: const Duration(milliseconds: 300),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}