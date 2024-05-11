
class InvoiceDetailsState {
  bool updateLoading;
  bool updateTable;
  bool updateComment;

  InvoiceDetailsState({
    this.updateLoading = false,
    this.updateTable = false,
    this.updateComment = false
  });

  InvoiceDetailsState.setTrue({
    this.updateLoading = true,
    this.updateTable = true,
    this.updateComment = true
  });
}

