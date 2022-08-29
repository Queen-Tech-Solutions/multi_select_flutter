import 'package:flutter/material.dart';
import '../util/multi_select_item.dart';
import '../util/multi_select_actions.dart';
import '../util/multi_select_list_type.dart';
import 'package:flutter_svg/svg.dart';

/// A bottom sheet widget containing either a classic checkbox style list, or a chip style list.
class MultiSelectBottomSheet<V> extends StatefulWidget
    with MultiSelectActions<V> {
  /// List of items to select from.
  final List<MultiSelectItem<V>> items;

  /// The list of selected values before interaction.
  final List<V>? initialValue;

  /// The text at the top of the BottomSheet.
  final Widget? title;

  /// Fires when the an item is selected / unselected.
  final void Function(List<V>)? onSelectionChanged;

  /// Fires when confirm is tapped.
  final void Function(List<V>)? onConfirm;

  /// Toggles search functionality.
  final bool? searchable;

  /// Text on the confirm button.
  final Text? confirmText;

  /// Text on the cancel button.
  final Text? cancelText;

  /// An enum that determines which type of list to render.
  final MultiSelectListType? listType;

  /// Sets the color of the checkbox or chip when it's selected.
  final Color? selectedColor;

  /// Set the initial height of the BottomSheet.
  final double? initialChildSize;

  /// Set the minimum height threshold of the BottomSheet before it closes.
  final double? minChildSize;

  /// Set the maximum height of the BottomSheet.
  final double? maxChildSize;

  /// Set the placeholder text of the search field.
  final String? searchHint;
  final String? confirmHint;

  /// A function that sets the color of selected items based on their value.
  /// It will either set the chip color, or the checkbox color depending on the list type.
  final Color? Function(V)? colorator;

  /// Color of the chip body or checkbox border while not selected.
  final Color? unselectedColor;

  /// Icon button that shows the search field.
  final Icon? searchIcon;

  /// Icon button that hides the search field
  final Icon? closeSearchIcon;

  /// Style the text on the chips or list tiles.
  final TextStyle? itemsTextStyle;

  /// Style the text on the selected chips or list tiles.
  final TextStyle? selectedItemsTextStyle;

  /// Style the search text.
  final TextStyle? searchTextStyle;

  /// Style the search hint.
  final TextStyle? searchHintStyle;

  /// Set the color of the check in the checkbox
  final Color? checkColor;

  MultiSelectBottomSheet({
    required this.items,
    required this.initialValue,
    this.title,
    this.onSelectionChanged,
    this.onConfirm,
    this.listType,
    this.cancelText,
    this.confirmText,
    this.confirmHint = "need to add text",
    this.searchable,
    this.selectedColor,
    this.initialChildSize,
    this.minChildSize,
    this.maxChildSize,
    this.colorator,
    this.unselectedColor,
    this.searchIcon,
    this.closeSearchIcon,
    this.itemsTextStyle,
    this.searchTextStyle,
    this.searchHint,
    this.searchHintStyle,
    this.selectedItemsTextStyle,
    this.checkColor,
  });

  @override
  _MultiSelectBottomSheetState<V> createState() =>
      _MultiSelectBottomSheetState<V>(items);
}

class _MultiSelectBottomSheetState<V> extends State<MultiSelectBottomSheet<V>> {
  List<V> _selectedValues = [];
  bool _showSearch = false;
  List<MultiSelectItem<V>> _items;

  _MultiSelectBottomSheetState(this._items);

  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      _selectedValues.addAll(widget.initialValue!);
    }
  }

  /// Returns a CheckboxListTile

  Widget _buildListItem(MultiSelectItem<V> item) {
    return Theme(
      data: ThemeData(
        unselectedWidgetColor: widget.unselectedColor ?? Colors.black54,
        accentColor: widget.selectedColor ?? Theme.of(context).primaryColor,
      ),
      child: CheckboxListTile(
        checkColor: widget.checkColor,
        value: _selectedValues.contains(item.value),
        activeColor: widget.colorator != null
            ? widget.colorator!(item.value) ?? widget.selectedColor
            : widget.selectedColor,
        title: Row(
          children: [
            Text(item.image),
            SizedBox(
              width: 5,
            ),
            Text(
              item.label,
              style: _selectedValues.contains(item.value)
                  ? widget.selectedItemsTextStyle
                  : widget.itemsTextStyle,
            ),
          ],
        ),
        controlAffinity: ListTileControlAffinity.leading,
        onChanged: (checked) {
          setState(() {
            _selectedValues = widget.onItemCheckedChange(
                _selectedValues, item.value, checked!);
          });
          if (widget.onSelectionChanged != null) {
            widget.onSelectionChanged!(_selectedValues);
          }
        },
      ),
    );
  }

  /// Returns a ChoiceChip
  Widget _buildChipItem(MultiSelectItem<V> item) {
    return Container(
      padding: const EdgeInsets.all(2.0),
      child: ChoiceChip(
        backgroundColor: widget.unselectedColor,
        selectedColor:
            widget.colorator != null && widget.colorator!(item.value) != null
                ? widget.colorator!(item.value)
                : widget.selectedColor != null
                    ? widget.selectedColor
                    : Theme.of(context).primaryColor.withOpacity(0.35),
        label: Text(
          item.label,
          style: _selectedValues.contains(item.value)
              ? TextStyle(
                  color: widget.colorator != null &&
                          widget.colorator!(item.value) != null
                      ? widget.selectedItemsTextStyle != null
                          ? widget.selectedItemsTextStyle!.color ??
                              widget.colorator!(item.value)!.withOpacity(1)
                          : widget.colorator!(item.value)!.withOpacity(1)
                      : widget.selectedItemsTextStyle != null
                          ? widget.selectedItemsTextStyle!.color ??
                              (widget.selectedColor != null
                                  ? widget.selectedColor!.withOpacity(1)
                                  : Theme.of(context).primaryColor)
                          : widget.selectedColor != null
                              ? widget.selectedColor!.withOpacity(1)
                              : null,
                  fontSize: widget.selectedItemsTextStyle != null
                      ? widget.selectedItemsTextStyle!.fontSize
                      : null,
                )
              : widget.itemsTextStyle,
        ),
        selected: _selectedValues.contains(item.value),
        onSelected: (checked) {
          setState(() {
            _selectedValues = widget.onItemCheckedChange(
                _selectedValues, item.value, checked);
          });
          if (widget.onSelectionChanged != null) {
            widget.onSelectionChanged!(_selectedValues);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(29.0)),
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: ListView(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: [
          SingleChildScrollView(
            child: Container(
              height: getWidgetHeight(height: 550, context: context),
              width: getWidgetWidth(width: 400, context: context),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(29),
                  color: Color(0xffFFFFFF)),
              child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15.0),
                                    border: Border.all(
                                        color: Color(0XFF707070)
                                            .withOpacity(0.3))),
                                child: TextField(
                                  autofocus: false,
                                  decoration: InputDecoration(
                                    focusedBorder: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                    disabledBorder: InputBorder.none,
                                    isDense: true,
                                    contentPadding:
                                        EdgeInsets.symmetric(vertical: 3),
                                    prefixIcon: Container(
                                        margin: EdgeInsets.symmetric(
                                            horizontal: 10),
                                        child: SvgPicture.asset(
                                          "assets/images/search-svgrepo-com.svg",
                                          color: Color(0XFF707070)
                                              .withOpacity(0.9),
                                        )),
                                    prefixIconConstraints: BoxConstraints(
                                        maxWidth: 30, maxHeight: 15),
                                    hintStyle: TextStyle(
                                      fontSize: 11,
                                      color: Color(0XFF626262),
                                    ),
                                    hintText: widget.searchHint ?? "Search",
                                  ),
                                  onChanged: (val) {
                                    setState(() {
                                      _items = widget.updateSearchQuery(
                                          val, widget.items);
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                          child: ListView.builder(
                        itemCount: _items.length,
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              _buildListItem(_items[index]),
                              Divider(
                                color: Colors.grey.withOpacity(0.6),
                                thickness: 0.5,
                              ),
                            ],
                          );
                        },
                      )),
                    ],
                  )),
            ),
          ),
          SizedBox(
            height: getWidgetHeight(height: 10, context: context),
          ),
          Container(
            width: getWidgetWidth(width: 343, context: context),
            height: 40,
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(23.0)),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Color(0XFF1551B7),
                    Color(0XFF2F77F2),
                    Color(0XFF2F77F2),
                  ],
                )),
            child: ElevatedButton(
              style: ButtonStyle(
                elevation: MaterialStateProperty.all<double>(0.0),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(23.0),
                  ),
                ),
                backgroundColor: MaterialStateProperty.all(Colors.transparent),
              ),
              onPressed: () {
                widget.onConfirmTap(context, _selectedValues, widget.onConfirm);
              },
              child: Text(
                widget.confirmHint!,
                textAlign: TextAlign.center,
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
    // return Container(
    //   padding:
    //       EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
    //   child: DraggableScrollableSheet(
    //     initialChildSize: widget.initialChildSize ?? 0.3,
    //     minChildSize: widget.minChildSize ?? 0.3,
    //     maxChildSize: widget.maxChildSize ?? 0.6,
    //     expand: false,
    //     builder: (BuildContext context, ScrollController scrollController) {
    //       return Column(
    //         children: [
    //           Padding(
    //             padding: const EdgeInsets.all(10),
    //             child: Row(
    //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //               children: [
    //                 _showSearch
    //                     ? Expanded(
    //                         child: Container(
    //                           padding: EdgeInsets.only(left: 10),
    //                           child: TextField(
    //                             autofocus: true,
    //                             style: widget.searchTextStyle,
    //                             decoration: InputDecoration(
    //                               hintStyle: widget.searchHintStyle,
    //                               hintText: widget.searchHint ?? "Search",
    //                               focusedBorder: UnderlineInputBorder(
    //                                 borderSide: BorderSide(
    //                                     color: widget.selectedColor ??
    //                                         Theme.of(context).primaryColor),
    //                               ),
    //                             ),
    //                             onChanged: (val) {
    //                               setState(() {
    //                                 _items = widget.updateSearchQuery(
    //                                     val, widget.items);
    //                               });
    //                             },
    //                           ),
    //                         ),
    //                       )
    //                     : widget.title ??
    //                         Text(
    //                           "Select",
    //                           style: TextStyle(fontSize: 18),
    //                         ),
    //                 widget.searchable != null && widget.searchable!
    //                     ? IconButton(
    //                         icon: _showSearch
    //                             ? widget.closeSearchIcon ?? Icon(Icons.close)
    //                             : widget.searchIcon ?? Icon(Icons.search),
    //                         onPressed: () {
    //                           setState(() {
    //                             _showSearch = !_showSearch;
    //                             if (!_showSearch) _items = widget.items;
    //                           });
    //                         },
    //                       )
    //                     : Padding(
    //                         padding: EdgeInsets.all(15),
    //                       ),
    //               ],
    //             ),
    //           ),
    //           Expanded(
    //             child: widget.listType == null ||
    //                     widget.listType == MultiSelectListType.LIST
    //                 ? ListView.builder(
    //                     controller: scrollController,
    //                     itemCount: _items.length,
    //                     itemBuilder: (context, index) {
    //                       return _buildListItem(_items[index]);
    //                     },
    //                   )
    //                 : SingleChildScrollView(
    //                     controller: scrollController,
    //                     child: Container(
    //                       padding: EdgeInsets.all(10),
    //                       child: Wrap(
    //                         children: _items.map(_buildChipItem).toList(),
    //                       ),
    //                     ),
    //                   ),
    //           ),
    //           Container(
    //             padding: EdgeInsets.all(2),
    //             child: Row(
    //               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    //               children: [
    //                 Expanded(
    //                   child: TextButton(
    //                     onPressed: () {
    //                       widget.onCancelTap(context, widget.initialValue!);
    //                     },
    //                     child: widget.cancelText ??
    //                         Text(
    //                           "CANCEL",
    //                           style: TextStyle(
    //                             color: (widget.selectedColor != null &&
    //                                     widget.selectedColor !=
    //                                         Colors.transparent)
    //                                 ? widget.selectedColor!.withOpacity(1)
    //                                 : Theme.of(context).primaryColor,
    //                           ),
    //                         ),
    //                   ),
    //                 ),
    //                 SizedBox(width: 10),
    //                 Expanded(
    //                   child: TextButton(
    //                     onPressed: () {
    //                       widget.onConfirmTap(
    //                           context, _selectedValues, widget.onConfirm);
    //                     },
    //                     child: widget.confirmText ??
    //                         Text(
    //                           "OK",
    //                           style: TextStyle(
    //                             color: (widget.selectedColor != null &&
    //                                     widget.selectedColor !=
    //                                         Colors.transparent)
    //                                 ? widget.selectedColor!.withOpacity(1)
    //                                 : Theme.of(context).primaryColor,
    //                           ),
    //                         ),
    //                   ),
    //                 ),
    //               ],
    //             ),
    //           ),
    //         ],
    //       );
    //     },
    //   ),
    // );
  }
}

/// Get Widget Height
double getWidgetHeight(
    {required double height, required BuildContext context}) {
  double currentHeight = MediaQuery.of(context).size.height * (height / 812);
  return currentHeight;
}

/// Get Widget Width
double getWidgetWidth({required double width, required BuildContext context}) {
  double currentWidth = MediaQuery.of(context).size.width * (width / 375);
  return currentWidth;
}
