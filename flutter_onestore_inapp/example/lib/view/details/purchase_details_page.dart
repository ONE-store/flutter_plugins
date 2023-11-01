import 'package:flutter/material.dart';
import 'package:flutter_onestore_inapp/onestore_in_app_wrappers.dart';
import 'package:provider/provider.dart';

import '../../purchase_view_model.dart';
import '../../res/colors.dart';
import '../../res/theme.dart';

class PurchaseDetailsPage extends StatefulWidget {

  const PurchaseDetailsPage({super.key});

  @override
  State<StatefulWidget> createState() => _PurchaseDetailsState();
}

class _PurchaseDetailsState extends State<PurchaseDetailsPage> {
  late final PurchaseViewModel _viewModel =
      Provider.of<PurchaseViewModel>(context, listen: false);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 15, left: 15, right: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Not consumed for purchases',
            style: AppThemes.titleTextTheme,
          ),
          Container(height: 10),
          Consumer<PurchaseViewModel>(builder: (context, model, child) {
            return _buildListView(model.consumables);
          })
        ],
      ),
    );
  }

  _buildListView(List<PurchaseData> purchasesList) {
    if (purchasesList.isEmpty) {
      return const Expanded(
        child: Center(
          child: Text(
            'No items',
            style: TextStyle(color: AppColors.secondaryText),
          ),
        ),
      );
    }

    final consumableProducts = _viewModel.consumableProducts;
    List<ListItem> items = purchasesList.map((e) {
      String title = consumableProducts
          .singleWhere((element) => element.productId == e.productId)
          .title;
      return ListItem(title: title, purchase: e);
    }).toList();

    return ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: items.length,
        itemBuilder: (BuildContext context, int index) {
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.0),
            ),
            child: ListTile(
              dense: true,
              visualDensity: const VisualDensity(vertical: 4),
              leading: const Icon(
                Icons.monetization_on,
                size: 30,
                color: AppColors.primaryColor,
              ),
              title: Text(items[index].title,
                  style: AppThemes.bodyPrimaryTextTheme),
              trailing: const Text(
                'Consume',
                style: AppThemes.bodySecondaryTextTheme,
              ),
              onTap: () {
                _viewModel.consumePurchase(items[index].purchase);
              },
            ),
          );
        });
  }
}

class ListItem {
  ListItem({required this.title, required this.purchase});

  final String title;
  final PurchaseData purchase;
}
