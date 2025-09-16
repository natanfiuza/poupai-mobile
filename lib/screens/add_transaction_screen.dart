import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../config/app_colors.dart';
import '../models/transaction_model.dart';
import '../services/database_helper.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();

  String _transactionType = 'expense'; // 'expense' ou 'receipt'
  DateTime _selectedDate = DateTime.now();
  String? _selectedCategory;
  bool _isLoading = false;

  // Lista de categorias de exemplo
  final List<String> _categories = [
    'Alimentação',
    'Transporte',
    'Moradia',
    'Lazer',
    'Saúde',
    'Salário',
    'Outros',
  ];

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final newTransaction = TransactionModel(
        uuid: const Uuid().v4(), // Gera um UUID único
        description: _descriptionController.text,
        amount: double.parse(_amountController.text.replaceAll(',', '.')),
        category: _selectedCategory!,
        date: _selectedDate,
        type: _transactionType,
        syncStatus: 'new', // Marca como 'novo' para sincronização futura
        lastModified: DateTime.now(),
      );

      await DatabaseHelper.instance.createTransaction(newTransaction);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transação guardada com sucesso!'),
            backgroundColor: AppColors.successColor,
          ),
        );
        Navigator.of(context).pop(); // Fecha a tela após guardar
      }
    } catch (e) {
      print('Erro ao guardar a transação: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao guardar a transação.'),
          backgroundColor: AppColors.errorColor,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Adicionar Transação')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Seletor de Tipo (Despesa / Receita)
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'expense',
                  label: Text('Despesa'),
                  icon: Icon(Icons.remove),
                ),
                ButtonSegment(
                  value: 'receipt',
                  label: Text('Receita'),
                  icon: Icon(Icons.add),
                ),
              ],
              selected: {_transactionType},
              onSelectionChanged: (newSelection) {
                setState(() {
                  _transactionType = newSelection.first;
                });
              },
            ),
            const SizedBox(height: 24),
            // Campo de Valor
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Valor (R\$)',
                prefixText: 'R\$ ',
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira um valor';
                }
                if (double.tryParse(value.replaceAll(',', '.')) == null) {
                  return 'Valor inválido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // Seletor de Categoria
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(labelText: 'Categoria'),
              items: _categories.map((category) {
                return DropdownMenuItem(value: category, child: Text(category));
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedCategory = newValue;
                });
              },
              validator: (value) =>
                  value == null ? 'Selecione uma categoria' : null,
            ),
            const SizedBox(height: 16),
            // Seletor de Data
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today),
              title: const Text('Data da Transação'),
              subtitle: Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
              onTap: _pickDate,
            ),
            const SizedBox(height: 16),
            // Campo de Descrição
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Descrição'),
              validator: (value) =>
                  value!.isEmpty ? 'Insira uma descrição' : null,
            ),
            const SizedBox(height: 32),
            // Botão de Guardar
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _submitForm,
                    child: const Text('GUARDAR'),
                  ),
          ],
        ),
      ),
    );
  }
}
