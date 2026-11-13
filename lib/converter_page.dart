import 'package:flutter/material.dart';

import 'state/converter_state.dart';

class ConverterPage extends StatefulWidget {
  const ConverterPage({super.key});

  @override
  State<ConverterPage> createState() => _ConverterPageState();
}

class _ConverterPageState extends State<ConverterPage> {
  final amountController = TextEditingController();
  final state = ConverterState();

  @override
  void dispose() {
    amountController.dispose();
    state.dispose();
    super.dispose();
  }

  String formatDate(DateTime date) {
    final d = date.toLocal();
    final minutes = d.minute.toString().padLeft(2, '0');
    return '${d.day}.${d.month}.${d.year} ${d.hour}:$minutes';
  }

  // Выпадающий список валют (используем для "из" и "в")
  Widget buildDropdown(String value, Function(String) onChanged) {
    return DropdownButton<String>(
      value: value,
      isExpanded: true,
      items: state.currencies.map((code) {
        return DropdownMenuItem(
          value: code,
          child: Row(
            children: [
              Text(code),
              const Spacer(),
              IconButton(
                icon: Icon(
                  state.isFavorite(code) ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                ),
                onPressed: () {
                  state.toggleFavorite(code);
                },
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: (newValue) {
        if (newValue != null) {
          onChanged(newValue);
        }
      },
    );
  }

  // Карточка с результатом
  Widget buildResultCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${state.amount!.toStringAsFixed(2)} ${state.from} ='),
            const SizedBox(height: 6),
            Text(
              '${state.result!.toStringAsFixed(2)} ${state.to}',
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Курс: 1 ${state.from} = ${state.rate!.toStringAsFixed(4)} ${state.to}',
            ),
            Text('Обновлено: ${formatDate(state.updated!)}'),
          ],
        ),
      ),
    );
  }

  Widget buildFavorites() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Избранные валюты',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: state.favorites.map((currency) {
            return ActionChip(
              avatar: const Icon(Icons.star, color: Colors.amber),
              label: Text(currency),
              onPressed: () {
                state.setFrom(currency);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Конвертер валют'), centerTitle: true),
      body: SafeArea(
        // прокрутка нужна, чтобы ничего не выходило за границы экрана
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          // ListenableBuilder перерисовывает всё внутри, когда state вызывает notifyListeners()
          child: ListenableBuilder(
            listenable: state,
            builder: (context, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (state.favorites.isNotEmpty) ...[
                    buildFavorites(),
                    const SizedBox(height: 20),
                  ],
                  // Поле ввода суммы
                  TextField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Сумма',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Выбор валют и кнопка "поменять местами"
                  Row(
                    children: [
                      Expanded(child: buildDropdown(state.from, state.setFrom)),
                      IconButton(
                        icon: const Icon(Icons.swap_horiz),
                        onPressed: () {
                          state.swap();
                          // если результат уже был, сразу пересчитываем
                          if (state.result != null) {
                            state.convert(amountController.text);
                          }
                        },
                      ),
                      Expanded(child: buildDropdown(state.to, state.setTo)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Кнопка (во время загрузки отключена)
                  FilledButton(
                    onPressed: state.isLoading
                        ? null
                        : () => state.convert(amountController.text),
                    child: const Padding(
                      padding: EdgeInsets.all(12),
                      child: Text('Конвертировать'),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Что показывать ниже - зависит от состояния
                  if (state.isLoading)
                    const Center(child: CircularProgressIndicator()),

                  if (state.errorMessage != null)
                    Text(
                      state.errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),

                  if (state.result != null) buildResultCard(),

                  // История конвертаций
                  if (state.history.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('История', style: TextStyle(fontSize: 18)),
                        TextButton(
                          onPressed: state.clearHistory,
                          child: const Text('Очистить'),
                        ),
                      ],
                    ),
                    for (final item in state.history) Text(item),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
