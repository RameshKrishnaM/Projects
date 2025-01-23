import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:novo/utils/colors.dart';

class MfCustomSearchField extends StatefulWidget {
  final String titleText;
  final String hintText;
  final TextEditingController searchController;
  final Function onChange;
  const MfCustomSearchField({
    super.key,
    required this.titleText,
    required this.hintText,
    required this.searchController,
    required this.onChange,
  });

  @override
  State<MfCustomSearchField> createState() => _MfCustomSearchFieldState();
}

class _MfCustomSearchFieldState extends State<MfCustomSearchField> {
  bool searchShow = false;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8, top: 5),
      child: SizedBox(
        height: 35,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  AnimatedOpacity(
                    opacity: searchShow ? 0.0 : 1.0,
                    duration: const Duration(milliseconds: 0),
                    child: Text(
                      widget.titleText,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                      final offsetAnimation = Tween<Offset>(
                        begin: const Offset(1, 0), // Slide in from the right
                        end: Offset.zero,
                      ).animate(animation);
                      return ClipRect(
                        child: SlideTransition(
                          position: offsetAnimation,
                          child: child,
                        ),
                      );
                    },
                    child: searchShow
                        ? TextFormField(
                            key: const ValueKey('textField'),
                            controller: widget.searchController,
                            onChanged: (value) => widget.onChange(value),
                            decoration: InputDecoration(
                              hintText: widget.hintText,
                              hintStyle: const TextStyle(fontSize: 14),
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 7),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: titleTextColorLight.withOpacity(0.4),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: titleTextColorLight.withOpacity(0.4),
                                ),
                              ),
                            ),
                          )
                        : Container(), // Hide the TextFormField completely when not showing
                  ),
                ],
              ),
            ),
            const SizedBox(
              width: 15,
            ),
            InkWell(
                onTap: () {
                  searchShow = !searchShow;
                  if (searchShow == false) {
                    widget.searchController.clear();
                    widget.onChange('');
                  }
                  setState(() {});
                },
                child: searchShow && widget.searchController.text.isNotEmpty
                    ? const Icon(
                        Icons.close,
                        size: 25,
                      )
                    : const Icon(
                        Icons.search,
                        size: 25,
                      ))
          ],
        ),
      ),
    );
  }
}
