import 'package:flutter/material.dart';

import '../../basket_selected_attribute.dart';
import '../../item.dart';

class ItemDetailIntentHolder {
  const ItemDetailIntentHolder(
      {@required this.item,
      this.id,
      this.qty,
      this.selectedColorId,
      this.selectedColorValue,
      this.basketPrice,
      this.basketSelectedAttributeList,
      this.heroTagImage,
      this.heroTagTitle,
      this.heroTagOriginalPrice,
      this.heroTagUnitPrice});

  final String id;
  final String basketPrice;
  final List<BasketSelectedAttribute> basketSelectedAttributeList;
  final String selectedColorId;
  final String selectedColorValue;
  final Item item;
  final String qty;
  final String heroTagImage;
  final String heroTagTitle;
  final String heroTagOriginalPrice;
  final String heroTagUnitPrice;
}
