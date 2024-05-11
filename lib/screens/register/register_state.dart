
class RegisterState {
  bool updatePassVisibility;
  bool updateConfirmVisibility;
  bool updateRegisterLoading;

  bool updateMarketplaceLogo;
  bool updateComRegisterLoading;

  RegisterState({
    this.updatePassVisibility = false,
    this.updateConfirmVisibility = false,
    this.updateRegisterLoading = false,
    this.updateMarketplaceLogo = false,
    this.updateComRegisterLoading = false
  });
}

