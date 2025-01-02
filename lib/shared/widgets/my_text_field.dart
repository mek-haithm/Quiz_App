import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';

class MyTextField extends StatefulWidget {
  final String hintText;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final IconData? icon;
  final Color? color;
  final bool readOnly;
  final bool isPassword;
  final bool isEmail;
  final BuildContext? context;
  final String? Function(String?)? validator;
  final void Function(String)? onSubmitted;

  const MyTextField({
    super.key,
    required this.hintText,
    required this.controller,
    this.icon,
    this.color,
    this.readOnly = false,
    this.context,
    this.isPassword = false,
    this.isEmail = false,
    this.focusNode,
    this.validator,
    this.onSubmitted,
  });

  @override
  State<MyTextField> createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  TextDirection _textDirection = TextDirection.ltr;
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleTextChange);
    _handleTextChange();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleTextChange);
    super.dispose();
  }

  void _handleTextChange() {
    setState(() {
      _textDirection = _detectTextDirection(widget.controller.text);
    });
  }

  TextDirection _detectTextDirection(String text) {
    if (text.isEmpty) {
      return TextDirection.ltr;
    }
    final firstChar = text.codeUnitAt(0);
    if (firstChar >= 0x600 && firstChar <= 0x6FF) {
      return TextDirection.rtl;
    } else {
      return TextDirection.ltr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: widget.isPassword ? _obscureText : false,
      keyboardType: widget.isEmail ? TextInputType.emailAddress : null,
      readOnly: widget.readOnly,
      cursorColor: kMainColor,
      controller: widget.controller,
      focusNode: widget.focusNode,
      style: kSmallTextStyle(widget.context ?? context),
      textDirection: _textDirection,
      validator: widget.validator,
      onFieldSubmitted: widget.onSubmitted,
      decoration: InputDecoration(
        filled: true,
        fillColor: widget.color ?? kCardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        hintText: widget.hintText,
        hintStyle: const TextStyle(
          color: Colors.grey,
          fontFamily: "ibmFont",
        ),
        suffixIcon: widget.isPassword
            ? IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility_off : Icons.visibility,
            color: kMainColor,
          ),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        )
            : (widget.icon != null
            ? Icon(
          widget.icon,
          color: kMainColor,
        )
            : null),
      ),
    );
  }
}
