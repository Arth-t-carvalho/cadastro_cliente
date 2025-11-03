// lib/modelos/cliente.dart

import 'package:cloud_firestore/cloud_firestore.dart'; // Importa o pacote do Firestore
// O GerenciadorClientes será descartado.

/// CLASSE MODELO: Representa um Cliente (agora com métodos para Firebase).
class Cliente {
  // O ID do documento no Firestore. Não existia antes.
  final String? id;
  final String nome;
  final String email;
  final String senha; // Em um app real, a senha NÃO é guardada assim! Usaríamos o Firebase Auth.

  Cliente({
    this.id, // O ID é opcional (será gerado pelo Firestore).
    required this.nome,
    required this.email,
    required this.senha,
  });

  // ---------------------------------------------------------------------
  // MÉTODOS PARA O FIREBASE
  // ---------------------------------------------------------------------

  // 1. Converte um Cliente para um MAPA (JSON) para salvar no Firestore.
  Map<String, dynamic> toFirestore() {
    return {
      "nome": nome,
      "email": email,
      "senha": senha,
    };
  }

  // 2. Cria um objeto Cliente a partir de um DocumentSnapshot do Firestore.
  factory Cliente.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final dados = snapshot.data()!;
    return Cliente(
      id: snapshot.id, // O ID do Firestore é o ID do nosso Cliente.
      nome: dados['nome'] as String,
      email: dados['email'] as String,
      senha: dados['senha'] as String,
    );
  }
}

// ---------------------------------------------------------------------
// CLASSE DE SERVIÇO: Substitui o GerenciadorClientes (Acessa o Firestore)
// ---------------------------------------------------------------------

class ServicoClientes {
  // Referência à coleção (tabela) 'clientes' no Firestore.
  final CollectionReference _colecao = FirebaseFirestore.instance.collection('clientes');

  /// Tenta cadastrar um novo cliente no Firestore.
  Future<bool> cadastrar(Cliente cliente) async {
    // 1. Verifica duplicidade (Firestore Query).
    final query = await _colecao.where('email', isEqualTo: cliente.email).get();
    if (query.docs.isNotEmpty) {
      return false; // E-mail já existe.
    }

    // 2. Adiciona o cliente ao Firestore.
    await _colecao.add(cliente.toFirestore());
    return true;
  }

  /// Tenta fazer o login buscando no Firestore.
  Future<Cliente?> login(String email, String senha) async {
    // Busca um documento onde email E senha coincidam.
    final query = await _colecao
        .where('email', isEqualTo: email)
        .where('senha', isEqualTo: senha)
        .get();

    if (query.docs.isEmpty) {
      return null; // Credenciais incorretas.
    }

    // Converte o DocumentSnapshot para um objeto Cliente.
    return Cliente.fromFirestore(query.docs.first as DocumentSnapshot<Map<String, dynamic>>);
  }

  /// Retorna um Stream dos clientes (para atualizar a UI em tempo real).
  Stream<List<Cliente>> get clientesStream {
    // O 'snapshots()' envia novos dados sempre que a coleção muda.
    return _colecao.snapshots().map((snapshot) {
      // Mapeia cada documento para um objeto Cliente.
      return snapshot.docs
          .map((doc) => Cliente.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>))
          .toList();
    });
  }
}