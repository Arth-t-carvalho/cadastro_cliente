//import necessario do material app
import 'package:flutter/material.dart';

class Cliente{
  final String nome;
  final String email;
  final String senha;

//construtor do cliente
Cliente({
  required this.nome,
  required this.email,
  required this.senha,
});
  @override
  String toString(){
    return 'Cliente: $nome, Email: $email';
  }
}

class GerenciadorClientes{
  //variavel estatica que guarda a unica copia desta classe
  static final GerenciadorClientes _instancia = GerenciadorClientes._interno();
   GerenciadorClientes._interno();
   //sempre retorna a instancia existente 
   factory GerenciadorClientes() => _instancia;
   //lista <ul> que amarzena todos os clientes cadastrados
   final List<Cliente> _clientes =  [];
   //para acessar a lista de clientes (retornaa uma copia imutavel)
   List<Cliente> get clientes => List.unmodifiable(_clientes);
   //tentar cadastrar um clien novo.
   bool cadastrar(Cliente cliente){
    //vamos checar se ja existe um email cadastrado
    if(_clientes.any((c) => c.email.toLowerCase() == cliente.email.toLowerCase())){
      print('ERRO: email ${cliente.email}');
      return false;//cadastro deu erro
      }
      _clientes.add(cliente);//adicionar o cliente
      print('novo cliente cadastrado:${cliente.nome}');
      return true; //cadastrou deu certo    
   }
   Cliente ? login(String email, String senha){
    return _clientes.firstWhere(
      //e uma function anonima
      (c) => c.email.toLowerCase() == email.toLowerCase() && c.senha == senha,
      orElse: () => Null as Cliente,
    );
   }
}