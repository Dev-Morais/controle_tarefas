class UserData {
  static final UserData instance = UserData._internal();
  UserData._internal();

  String id = ""; // Adicione esta linha
  String nome = "";
  String email = "";

  // Atualize o método para receber o ID também
  void setDados(String novoId, String novoNome, String novoEmail) {
    id = novoId;
    nome = novoNome;
    email = novoEmail;
  }
}