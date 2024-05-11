
class AddClientState {
  bool updateImage;
  bool updateClientType;
  bool updateGovernorate;
  bool updatePhoneList;
  bool updateCity;
  bool updateCategory;
  bool updateLoading;

  AddClientState({
    this.updateImage = false,
    this.updateClientType = false,
    this.updateGovernorate = false,
    this.updatePhoneList = false,
    this.updateCity = false,
    this.updateCategory = false,
    this.updateLoading = false
  });

  AddClientState.setTrue({
    this.updateImage = true,
    this.updateClientType = true,
    this.updateGovernorate = true,
    this.updatePhoneList = true,
    this.updateCity = true,
    this.updateCategory = true,
    this.updateLoading = true
  });
}

