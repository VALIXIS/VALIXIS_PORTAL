import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/responsive/app_breakpoints.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../domain/utils/financial_calculator.dart';
import '../providers/invoice_builder_provider.dart';

/// Dynamic line item row supporting desktop tabular layout and mobile card layout.
class InvoiceLineItemRow extends StatefulWidget {
  final int index;
  final LineItemDraft item;
  final String currency;
  final ValueChanged<String> onDescriptionChanged;
  final ValueChanged<double> onQuantityChanged;
  final ValueChanged<double> onUnitPriceChanged;
  final VoidCallback onRemove;
  final bool canRemove;

  const InvoiceLineItemRow({
    super.key,
    required this.index,
    required this.item,
    required this.currency,
    required this.onDescriptionChanged,
    required this.onQuantityChanged,
    required this.onUnitPriceChanged,
    required this.onRemove,
    this.canRemove = true,
  });

  @override
  State<InvoiceLineItemRow> createState() => _InvoiceLineItemRowState();
}

class _InvoiceLineItemRowState extends State<InvoiceLineItemRow> {
  late final TextEditingController _descController;
  late final TextEditingController _qtyController;
  late final TextEditingController _priceController;

  @override
  void initState() {
    super.initState();
    _descController = TextEditingController(text: widget.item.description);
    _qtyController = TextEditingController(
      text: widget.item.quantity == widget.item.quantity.roundToDouble()
          ? widget.item.quantity.toInt().toString()
          : widget.item.quantity.toString(),
    );
    _priceController = TextEditingController(
      text: widget.item.unitPrice == 0.0
          ? ''
          : widget.item.unitPrice.toStringAsFixed(2),
    );
  }

  @override
  void didUpdateWidget(covariant InvoiceLineItemRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.description != widget.item.description &&
        _descController.text != widget.item.description) {
      _descController.text = widget.item.description;
    }
    // Only update text controllers if values changed externally to preserve cursor position
    if (oldWidget.item.quantity != widget.item.quantity) {
      final formatted = widget.item.quantity == widget.item.quantity.roundToDouble()
          ? widget.item.quantity.toInt().toString()
          : widget.item.quantity.toString();
      if (_qtyController.text != formatted) {
        _qtyController.text = formatted;
      }
    }
  }

  @override
  void dispose() {
    _descController.dispose();
    _qtyController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = AppBreakpoints.isMobile(context);

    if (isMobile) {
      return _buildMobileCard(context);
    }
    return _buildDesktopRow(context);
  }

  Widget _buildDesktopRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Row Index / Number
          Container(
            width: 28,
            alignment: Alignment.center,
            child: Text(
              '#${widget.index + 1}',
              style: AppTypography.caption.copyWith(color: AppColors.textMuted),
            ),
          ),
          const SizedBox(width: 8),

          // Description (Expanded flex 5)
          Expanded(
            flex: 5,
            child: TextFormField(
              key: Key('line_item_desc_${widget.index}'),
              controller: _descController,
              decoration: const InputDecoration(
                hintText: 'Item description or service rendered',
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              style: AppTypography.bodySmall,
              onChanged: widget.onDescriptionChanged,
            ),
          ),
          const SizedBox(width: 10),

          // Quantity (Expanded flex 2)
          Expanded(
            flex: 2,
            child: TextFormField(
              key: Key('line_item_qty_${widget.index}'),
              controller: _qtyController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                hintText: '1.0',
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              ),
              style: AppTypography.bodySmall,
              onChanged: (val) {
                final qty = double.tryParse(val) ?? 0.0;
                widget.onQuantityChanged(qty);
              },
            ),
          ),
          const SizedBox(width: 10),

          // Unit Price (Expanded flex 2)
          Expanded(
            flex: 2,
            child: TextFormField(
              key: Key('line_item_price_${widget.index}'),
              controller: _priceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.right,
              decoration: const InputDecoration(
                hintText: '0.00',
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              ),
              style: AppTypography.bodySmall,
              onChanged: (val) {
                final price = double.tryParse(val) ?? 0.0;
                widget.onUnitPriceChanged(price);
              },
            ),
          ),
          const SizedBox(width: 14),

          // Line Total (Expanded flex 2)
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              alignment: Alignment.centerRight,
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                key: Key('line_item_total_${widget.index}'),
                FinancialCalculator.formatCurrency(widget.item.lineTotal, widget.currency),
                style: AppTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Remove Button
          IconButton(
            key: Key('line_item_remove_${widget.index}'),
            icon: const Icon(Icons.delete_outline_rounded, size: 18),
            color: widget.canRemove ? AppColors.error : AppColors.textMuted.withValues(alpha: 0.4),
            tooltip: 'Remove Item',
            onPressed: widget.canRemove ? widget.onRemove : null,
          ),
        ],
      ),
    );
  }

  Widget _buildMobileCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Item #${widget.index + 1}',
                  style: AppTypography.caption.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                if (widget.canRemove)
                  IconButton(
                    key: Key('line_item_remove_${widget.index}'),
                    icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: widget.onRemove,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              key: Key('line_item_desc_${widget.index}'),
              controller: _descController,
              decoration: const InputDecoration(
                labelText: 'Description *',
                hintText: 'Service rendered or product name',
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
              style: AppTypography.bodySmall,
              onChanged: widget.onDescriptionChanged,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    key: Key('line_item_qty_${widget.index}'),
                    controller: _qtyController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Qty',
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    ),
                    style: AppTypography.bodySmall,
                    onChanged: (val) {
                      final qty = double.tryParse(val) ?? 0.0;
                      widget.onQuantityChanged(qty);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 4,
                  child: TextFormField(
                    key: Key('line_item_price_${widget.index}'),
                    controller: _priceController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Unit Price',
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    ),
                    style: AppTypography.bodySmall,
                    onChanged: (val) {
                      final price = double.tryParse(val) ?? 0.0;
                      widget.onUnitPriceChanged(price);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Line Total', style: AppTypography.caption),
                      const SizedBox(height: 4),
                      Text(
                        key: Key('line_item_total_${widget.index}'),
                        FinancialCalculator.formatCurrency(widget.item.lineTotal, widget.currency),
                        style: AppTypography.bodySmall.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
