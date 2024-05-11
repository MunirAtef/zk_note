
class AddTransactionState {
  bool updateInvoiceType;
  bool updateInvoiceDate;
  bool updateItemUnit;
  bool updateCurrentPrice;
  bool updateItemsTable;
  bool updateLoading;
  bool updateAddItemSection;
  bool updateInvoicePrice;

  AddTransactionState({
    this.updateInvoiceType = false,
    this.updateInvoiceDate = false,
    this.updateItemUnit = false,
    this.updateCurrentPrice = false,
    this.updateItemsTable = false,
    this.updateLoading = false,
    this.updateAddItemSection = false,
    this.updateInvoicePrice = false
  });

  AddTransactionState.setTrue({
    this.updateInvoiceType = true,
    this.updateInvoiceDate = true,
    this.updateItemUnit = true,
    this.updateCurrentPrice = true,
    this.updateItemsTable = true,
    this.updateLoading = true,
    this.updateAddItemSection = true,
    this.updateInvoicePrice = true
  });
}
