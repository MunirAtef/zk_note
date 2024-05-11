

class AddPaymentState {
  bool updateDate;
  bool updatePaymentMethod;
  bool updateFlowType;
  bool updateLoading;

  AddPaymentState({
    this.updateDate = false,
    this.updatePaymentMethod = false,
    this.updateFlowType = false,
    this.updateLoading = false
  });

  AddPaymentState.setTrue({
    this.updateDate = true,
    this.updatePaymentMethod = true,
    this.updateFlowType = true,
    this.updateLoading = true
  });
}
