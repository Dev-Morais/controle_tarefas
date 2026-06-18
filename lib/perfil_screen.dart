import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'user_data.dart';
import 'api_service.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final ApiService api = ApiService(); 
  bool isEditing = false;
  
  File? _fotoPerfil;
  File? _fotoFundo;
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaAtualController = TextEditingController();
  final TextEditingController _novaSenhaController = TextEditingController();

  Future<void> _escolherImagem(bool isFundo) async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (isFundo) {
          _fotoFundo = File(pickedFile.path);
        } else {
          _fotoPerfil = File(pickedFile.path);
        }
      });
    }
  }

  Future<void> _salvarPerfil() async {
    try {
      final dadosAtualizados = {
        "nome": _nomeController.text,
        "email": _emailController.text,
        if (_novaSenhaController.text.isNotEmpty) "senha": _novaSenhaController.text,
      };

      await api.putDados('usuarios', UserData.instance.id.toString(), dadosAtualizados);

      UserData.instance.nome = _nomeController.text;
      UserData.instance.email = _emailController.text;

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Perfil atualizado com sucesso!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao salvar: $e")),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _nomeController.text = UserData.instance.nome;
    _emailController.text = UserData.instance.email;
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaAtualController.dispose();
    _novaSenhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      // APPBAR REMOVIDO DAQUI PARA NÃO DUPLICAR
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                GestureDetector(
                  onTap: isEditing ? () => _escolherImagem(true) : null,
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    color: Colors.blueAccent,
                    child: _fotoFundo != null 
                        ? Image.file(_fotoFundo!, fit: BoxFit.cover)
                        : Icon(Icons.camera_alt, color: Colors.white.withOpacity(0.6), size: 40),
                  ),
                ),
                Positioned(
                  bottom: -60,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.white,
                        backgroundImage: _fotoPerfil != null ? FileImage(_fotoPerfil!) : null,
                        child: _fotoPerfil == null ? const Icon(Icons.person, size: 70, color: Colors.blue) : null,
                      ),
                      if (isEditing)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () => _escolherImagem(false),
                            child: const CircleAvatar(
                              backgroundColor: Colors.blue,
                              radius: 18,
                              child: Icon(Icons.camera_alt, size: 18, color: Colors.white),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 70),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _infoField(Icons.person, "Nome Completo", _nomeController, false),
                  _infoField(Icons.email, "Email", _emailController, false),
                  const Divider(),
                  _infoField(Icons.lock_outline, "Senha Atual", _senhaAtualController, true),
                  _infoField(Icons.lock, "Nova Senha", _novaSenhaController, true),
                  
                  // Botão de editar/salvar movido para o corpo da tela
                  ElevatedButton(
                    onPressed: () {
                      if (isEditing) _salvarPerfil();
                      setState(() => isEditing = !isEditing);
                    },
                    child: Text(isEditing ? "Salvar Perfil" : "Editar Perfil"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoField(IconData icon, String label, TextEditingController controller, bool isPassword) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: TextField(
          controller: controller,
          readOnly: !isEditing,
          obscureText: isPassword,
          decoration: InputDecoration(
            labelText: label,
            icon: Icon(icon, color: isEditing ? Colors.blue : Colors.grey),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}