
class ClientPageState {
  bool updateMainData;
  bool updatePhonesList;
  bool updateCategoriesList;
  bool updateInvoices;
  bool updatePayments;

  ClientPageState({
    this.updateMainData = false,
    this.updatePhonesList = false,
    this.updateCategoriesList = false,
    this.updateInvoices = false,
    this.updatePayments = false
  });
}

