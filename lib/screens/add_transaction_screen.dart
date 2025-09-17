import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart';

import '../config/app_colors.dart';
import '../models/transaction_model.dart';
import '../services/database_helper.dart';
import '../providers/category_provider.dart';
class AddTransactionScreen extends StatefulWidget {
  final TransactionModel? transactionToEdit;
   const AddTransactionScreen({super.key, this.transactionToEdit});

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



  @override
  void initState() {
    super.initState();
    // Verifica se estamos no modo de edição
    if (widget.transactionToEdit != null) {
      final tx = widget.transactionToEdit!;
      _descriptionController.text = tx.description;
      _amountController.text = tx.amount
          .toStringAsFixed(2)
          .replaceAll('.', ',');
      _transactionType = tx.type;
      _selectedDate = tx.date;
      _selectedCategory = tx.category;
    }
  }

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
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final isEditing = widget.transactionToEdit != null;

    try {
      if (isEditing) {
        // LÓGICA DE ATUALIZAÇÃO
        final updatedTransaction = TransactionModel(
          id: widget.transactionToEdit!.id, // Mantém o ID local
          uuid: widget.transactionToEdit!.uuid, // Mantém o UUID
          description: _descriptionController.text,
          amount: double.parse(_amountController.text.replaceAll(',', '.')),
          category: _selectedCategory!,
          date: _selectedDate,
          type: _transactionType,
          // Se já estava sincronizado, marca como 'edited'
          syncStatus: widget.transactionToEdit!.syncStatus == 'synced'
              ? 'edited'
              : 'new',
          lastModified: DateTime.now(),
        );
        await DatabaseHelper.instance.updateTransaction(updatedTransaction);
      } else {
        // LÓGICA DE CRIAÇÃO (já existente)
        final newTransaction = TransactionModel(
          uuid: const Uuid().v4(),
          description: _descriptionController.text,
          amount: double.parse(_amountController.text.replaceAll(',', '.')),
          category: _selectedCategory!,
          date: _selectedDate,
          type: _transactionType,
          syncStatus: 'new',
          lastModified: DateTime.now(),
        );
        await DatabaseHelper.instance.createTransaction(newTransaction);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Transação guardada com sucesso!'),
            backgroundColor: AppColors.successColor,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      // ... (código de tratamento de erro continua o mesmo)
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    final isEditing = widget.transactionToEdit != null;
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final categoriesToShow = _transactionType == 'expense'
        ? categoryProvider.expenseCategories
        : categoryProvider.receiptCategories;
    final uniqueCategoryNames = categoriesToShow
            .map((c) => c.name)
            .toSet()
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Transação' : 'Adicionar Transação'),
      ),
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
                  _selectedCategory = null; // Limpa a categoria selecionada para evitar conflitos
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
              // Constrói os itens a partir da lista de nomes únicos
              items: uniqueCategoryNames.map((name) {
                return DropdownMenuItem(value: name, child: Text(name));
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
