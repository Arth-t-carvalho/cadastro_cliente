import 'package:flutter/material.dart';
import 'package:gerenciador_clientes/modelos/cliente.dart';

// instanciando nosso banquin
final GerenciadorClientes gerenciadorClientes = GerenciadorClientes();

void main() {
  gerenciadorClientes.cadastrar(
    Cliente(nome: 'Admin', email: 'admin@gmail.com', senha: 'admin123'),
  );
  runApp(const AplicativoClientes());
}

class AplicativoClientes extends StatelessWidget {
  const AplicativoClientes({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'sistema de clientes',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.indigo, useMaterial3: true),

      home:TelaLogin(),
    );
  }
}

class TelaPrincipal extends StatelessWidget {
  final Cliente cliente;

  const TelaPrincipal({super.key, required this.cliente});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Área do Cliente'),
        automaticallyImplyLeading: false, // Remove a seta de voltar.
        actions: [
          // Botão de Sair (Logout).
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Navegação: Limpa a pilha e volta para a Tela de Login.
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const TelaLogin()),
                (Route<dynamic> route) =>
                    false, // Condição que remove todas as rotas.
              );
            },
            tooltip: 'Sair do Sistema',
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle_outline,
                size: 80,
                color: Colors.indigo,
              ),
              const SizedBox(height: 20),
              Text(
                'Login de ${cliente.nome} realizado!',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'E-mail: ${cliente.email}',
                style: const TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 40),
              // Título da lista de clientes
              const Text(
                'Clientes cadastrados (BD Simulado):',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              // Lista de Clientes Cadastrados
              Expanded(
                // Usa o getter 'clientes' do nosso gerenciador.
                child: ListView.builder(
                  itemCount: gerenciadorClientes.clientes.length,
                  itemBuilder: (context, index) {
                    final c = gerenciadorClientes.clientes[index];
                    return ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(c.nome),
                      subtitle: Text(c.email),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TelaCadastro extends StatefulWidget {
  const TelaCadastro({super.key});

  @override
  State<TelaCadastro> createState() => _EstadoTelaCadastro();
}

class _EstadoTelaCadastro extends State<TelaCadastro> {
  final _chaveForm = GlobalKey<FormState>(); // Chave para validar o formulário.
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  String _mensagemErro = '';

  void _fazerCadastro() {
    if (_chaveForm.currentState!.validate()) {
      // Se a validação dos campos for OK...
      final novoCliente = Cliente(
        nome: _nomeController.text.trim(),
        email: _emailController.text.trim(),
        senha: _senhaController.text,
      );

      // Tenta cadastrar no BD simulado.
      final sucesso = gerenciadorClientes.cadastrar(novoCliente);

      if (sucesso) {
        // Se sucesso: exibe uma notificação e volta para a tela de Login.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Cadastro realizado com sucesso!')),
        );
        Navigator.pop(context); // Volta para a TelaLogin.
      } else {
        // Se falhar (e-mail duplicado).
        setState(() {
          _mensagemErro = 'E-mail já cadastrado. Tente outro!';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Novo Cadastro de Cliente')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _chaveForm,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Crie sua conta',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              // Campo Nome
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome Completo',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (valor) => (valor == null || valor.isEmpty)
                    ? 'Campo obrigatório.'
                    : null,
              ),
              const SizedBox(height: 16),
              // Campo E-mail
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (valor) => (valor == null || !valor.contains('@'))
                    ? 'E-mail inválido.'
                    : null,
              ),
              const SizedBox(height: 16),
              // Campo Senha
              TextFormField(
                controller: _senhaController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Senha',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                validator: (valor) => (valor == null || valor.length < 6)
                    ? 'A senha deve ter 6+ caracteres.'
                    : null,
              ),
              const SizedBox(height: 20),
              // Mensagem de Erro
              if (_mensagemErro.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    _mensagemErro,
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              // Botão de Cadastro
              ElevatedButton.icon(
                onPressed: _fazerCadastro,
                icon: const Icon(Icons.app_registration),
                label: const Text('Cadastrar'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // BOA PRÁTICA: Liberar os controladores quando o widget for removido
  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }
}

class TelaLogin extends StatefulWidget {
  const TelaLogin({super.key});

  @override
  State<TelaLogin> createState() => _EstadoTelaLogin();
}

class _EstadoTelaLogin extends State<TelaLogin> {
  final _chaveForm = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  String _mensagemErro = '';

  void _fazerLogin() {
    // 1. Validação dos campos
    if (_chaveForm.currentState!.validate()) {
      setState(() => _mensagemErro = ''); // Limpa erro.

      final email = _emailController.text.trim();
      final senha = _senhaController.text;

      // 2. Chama o método 'login' do nosso BD simulado.
      final clienteLogado = gerenciadorClientes.login(email, senha);

      if (clienteLogado != null) {
        // 3. Login de sucesso: Navega para a tela principal (substituindo o Login).
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TelaPrincipal(cliente: clienteLogado),
          ),
        );
      } else {
        // 4. Login falhou.
        setState(() {
          _mensagemErro = 'E-mail ou senha incorretos.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Acesso ao Sistema')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _chaveForm,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Bem-vindo!',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              // Campo E-mail
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (valor) => (valor == null || !valor.contains('@'))
                    ? 'E-mail inválido.'
                    : null,
              ),
              const SizedBox(height: 16),
              // Campo Senha
              TextFormField(
                controller: _senhaController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Senha',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                validator: (valor) => (valor == null || valor.length < 6)
                    ? 'A senha deve ter 6+ caracteres.'
                    : null,
              ),
              const SizedBox(height: 20),
              // Mensagem de Erro
              if (_mensagemErro.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    _mensagemErro,
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              // Botão de Login
              ElevatedButton.icon(
                onPressed: _fazerLogin,
                icon: const Icon(Icons.login),
                label: const Text('Entrar'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
              const SizedBox(height: 10),
              // Botão para Cadastrar
              TextButton(
                onPressed: () {
                  // Navega para a tela de cadastro.
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TelaCadastro(),
                    ),
                  );
                },
                child: const Text('Não tem conta? Cadastre-se aqui.'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // BOA PRÁTICA: Liberar os controladores
  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }
}
