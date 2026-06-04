import 'package:flutter/material.dart';
import '../../core/constants/api_keys.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/recipe_model.dart';
import '../../data/repositories/recipe_repository.dart';
import '../../data/services/ai_recipe_service.dart';
import '../../app/routes.dart';
import '../../core/widgets/recipe_card.dart';

class AiRecommendationScreen extends StatefulWidget {
  const AiRecommendationScreen({super.key});

  @override
  State<AiRecommendationScreen> createState() => _AiRecommendationScreenState();
}

class _AiRecommendationScreenState extends State<AiRecommendationScreen> {
  final chatController = TextEditingController();
  final scrollController = ScrollController();
  final recipeRepository = RecipeRepository();
  late final AiRecipeService aiService;

  // Bahan yang tersedia sebagai quick chip
  final List<String> availableChips = [];

  // Bahan yang sudah dipilih user (tag)
  final List<String> selectedIngredients = [];

  List<_ChatMessage> messages = [
    const _ChatMessage(
      text:
          'Halo! Aku Tanya Dapur AI. Pilih bahan yang kamu punya atau ketik langsung, nanti aku rekomendasikan resep Nusantara yang cocok. Bisa juga tanya apa saja seputar masakan!',
      fromUser: false,
    ),
  ];

  List<Recipe> recipes = [];
  List<Recipe> matchedRecipes = [];
  bool loadingRecipes = true;
  bool aiTyping = false;

  @override
  void initState() {
    super.initState();
    aiService = AiRecipeService(apiKey: ApiKeys.gemini);
    _loadRecipes();
  }

  @override
  void dispose() {
    chatController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadRecipes() async {
    final data = await recipeRepository.getRecipes();
    if (!mounted) return;

    // Kata yang di-skip (opsional, ringan saja)
    const skipKeywords = [
      'garam',
      'gula',
      'air',
      'minyak',
      'kaldu',
      'bumbu rempah',
      'air panas',
      'daun pisang'
    ];

    // Hitung frekuensi bahan
    final ingredientCount = <String, int>{};

    for (final recipe in data) {
      final lines = recipe.ingredients.split('\n');

      for (final line in lines) {
        final parts = line.split('|');

        if (parts.length < 2) continue;

        final clean = parts.last.trim().toLowerCase();

        if (clean.isEmpty) continue;

        final cleanLower = clean.toLowerCase();

        // Skip bahan tidak penting
        final shouldSkip = skipKeywords.any((k) => cleanLower.startsWith(k));
        if (shouldSkip) continue;

        ingredientCount[clean] = (ingredientCount[clean] ?? 0) + 1;
      }
    }

    // Ambil bahan yang sering muncul (>=2 kali)
    final frequent = ingredientCount.entries.where((e) => e.value >= 2).toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    setState(() {
      recipes = data;

      availableChips
        ..clear()
        ..addAll(
          frequent.isEmpty
              ? (ingredientCount.keys.toList()..sort()).take(15).toList()
              : frequent.map((e) => e.key).take(20).toList(),
        );

      loadingRecipes = false;
    });

    // Kirim daftar resep ke AI
    final recipeNames = data.map((r) => r.name).join(', ');
    aiService.setAvailableRecipes(recipeNames);
  }

  void _toggleIngredient(String ingredient) {
    setState(() {
      if (selectedIngredients.contains(ingredient)) {
        selectedIngredients.remove(ingredient);
      } else {
        selectedIngredients.add(ingredient);
      }
    });
  }

  void _addCustomIngredient(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty || selectedIngredients.contains(trimmed)) return;
    setState(() => selectedIngredients.add(trimmed));
    chatController.clear();
  }

  Future<void> _searchByIngredients() async {
    if (selectedIngredients.isEmpty) return;
    FocusScope.of(context).unfocus();

    final ingredientText = selectedIngredients.join(', ');
    setState(() {
      messages = [
        ...messages,
        _ChatMessage(text: 'Aku punya: $ingredientText', fromUser: true),
        const _ChatMessage(text: '...', fromUser: false, isTyping: true),
      ];
      matchedRecipes = []; // reset dulu
      aiTyping = true;
    });
    _scrollToBottom();

    final response =
        await aiService.recommendFromIngredients(selectedIngredients);

    // Cocokkan dengan DB lokal
    final matched = aiService.extractMatchingRecipes(response, recipes);

    if (!mounted) return;
    setState(() {
      messages = [
        ...messages.where((m) => !m.isTyping),
        _ChatMessage(text: response, fromUser: false),
      ];
      matchedRecipes = matched;
      aiTyping = false;
    });
    _scrollToBottom();
  }

  Future<void> _sendChat() async {
    final text = chatController.text.trim();
    if (text.isEmpty || aiTyping) return;
    FocusScope.of(context).unfocus();
    chatController.clear();

    setState(() {
      matchedRecipes = [];
      messages = [
        ...messages,
        _ChatMessage(text: text, fromUser: true),
        const _ChatMessage(text: '...', fromUser: false, isTyping: true),
      ];
      aiTyping = true;
    });
    _scrollToBottom();

    final response = await aiService.chat(text);
    final matched = aiService.extractMatchingRecipes(response, recipes);

    if (!mounted) return;
    setState(() {
      messages = [
        ...messages.where((m) => !m.isTyping),
        _ChatMessage(text: response, fromUser: false),
      ];
      // Gabung dengan yang sudah ada, hindari duplikat
      final existingIds = matchedRecipes.map((r) => r.id).toSet();
      final newMatches =
          matched.where((r) => !existingIds.contains(r.id)).toList();
      matchedRecipes = [...matchedRecipes, ...newMatches];
      aiTyping = false;
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent + 100,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tanya Dapur AI'),
        actions: [
          // Reset tombol — bersihkan history dan pilihan
          IconButton(
            onPressed: () {
              setState(() {
                selectedIngredients.clear();
                matchedRecipes = [];
                messages = [
                  const _ChatMessage(
                    text: 'Sesi baru dimulai! Pilih bahan atau tanya apa saja.',
                    fromUser: false,
                  ),
                ];
              });
              aiService.clearHistory();
            },
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Mulai sesi baru',
          ),
        ],
      ),
      body: Column(
        children: [
          // Panel atas: pilih bahan
          _IngredientPanel(
            availableChips: availableChips,
            selectedIngredients: selectedIngredients,
            onToggle: _toggleIngredient,
            onRemove: (i) => setState(() => selectedIngredients.remove(i)),
            onSearch: selectedIngredients.isEmpty ? null : _searchByIngredients,
          ),
          const Divider(height: 1),
          // Area chat
          Expanded(
            child: loadingRecipes
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    itemCount:
                        messages.length + (matchedRecipes.isNotEmpty ? 1 : 0),
                    itemBuilder: (_, i) {
                      // Tampilkan bubble chat
                      if (i < messages.length) {
                        return _Bubble(message: messages[i]);
                      }
                      // Tampilkan kartu resep yang cocok setelah semua bubble
                      return _MatchedRecipesSection(
                        recipes: matchedRecipes,
                        onTap: (recipe) => Navigator.pushNamed(
                          context,
                          AppRoutes.recipeDetail,
                          arguments: recipe,
                        ),
                      );
                    },
                  ),
          ),
          // Input chat bebas
          _ChatInput(
            controller: chatController,
            disabled: aiTyping,
            onAddIngredient: _addCustomIngredient,
            onSend: _sendChat,
          ),
        ],
      ),
    );
  }
}

// Panel pilih bahan
class _IngredientPanel extends StatefulWidget {
  final List<String> availableChips;
  final List<String> selectedIngredients;
  final void Function(String) onToggle;
  final void Function(String) onRemove;
  final VoidCallback? onSearch;

  const _IngredientPanel({
    required this.availableChips,
    required this.selectedIngredients,
    required this.onToggle,
    required this.onRemove,
    required this.onSearch,
  });

  @override
  State<_IngredientPanel> createState() => _IngredientPanelState();
}

class _IngredientPanelState extends State<_IngredientPanel> {
  bool expanded = false;

  String formatIngredient(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      color: AppColors.cream,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header panel
          InkWell(
            onTap: () => setState(() => expanded = !expanded),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
              child: Row(
                children: [
                  const Icon(Icons.kitchen_rounded,
                      size: 18, color: AppColors.spiceBrown),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.selectedIngredients.isEmpty
                          ? 'Pilih bahan yang kamu punya'
                          : '${widget.selectedIngredients.length} bahan dipilih',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Icon(
                    expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: AppColors.muted,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          if (!expanded && widget.selectedIngredients.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                'Bahan: ${widget.selectedIngredients.map(formatIngredient).join(", ")}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.muted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          if (expanded) ...[
            // Tag bahan yang dipilih
            if (widget.selectedIngredients.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: widget.selectedIngredients.map((ingredient) {
                    return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.leaf.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: AppColors.leaf.withValues(alpha: 0.5)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              formatIngredient(ingredient),
                              style: const TextStyle(
                                color: AppColors.leaf,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: () => widget.onRemove(ingredient),
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: AppColors.leaf.withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  size: 14,
                                  color: AppColors.leaf,
                                ),
                              ),
                            ),
                          ],
                        ));
                  }).toList(),
                ),
              ),
            // Quick chips
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: widget.availableChips
                      .where((c) => !widget.selectedIngredients.contains(c))
                      .map((chip) => GestureDetector(
                            onTap: () => widget.onToggle(chip),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppColors.line),
                              ),
                              child: Text(
                                '+ $chip',
                                style: const TextStyle(
                                  color: AppColors.spiceBrown,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ),
            ),
            // Tombol cari
            if (widget.selectedIngredients.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: widget.onSearch,
                    icon: const Icon(Icons.auto_awesome_rounded, size: 18),
                    label: const Text('Cari Resep dari Bahan Ini'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.spiceBrown,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

// Input chat di bawah
class _ChatInput extends StatelessWidget {
  final TextEditingController controller;
  final bool disabled;
  final void Function(String) onAddIngredient;
  final VoidCallback onSend;

  const _ChatInput({
    required this.controller,
    required this.disabled,
    required this.onAddIngredient,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.darkBrown.withValues(alpha: 0.07),
            blurRadius: 18,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                enabled: !disabled,
                minLines: 1,
                maxLines: 3,
                onSubmitted: (_) => onSend(),
                decoration: InputDecoration(
                  hintText: disabled
                      ? 'AI sedang berpikir...'
                      : 'Tanya seputar masakan atau ketik bahan...',
                ),
              ),
            ),
            const SizedBox(width: 10),
            FilledButton(
              onPressed: disabled ? null : onSend,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.spiceBrown,
                minimumSize: const Size(52, 52),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: disabled
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.send_rounded),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool fromUser;
  final bool isTyping;

  const _ChatMessage({
    required this.text,
    required this.fromUser,
    this.isTyping = false,
  });
}

class _Bubble extends StatelessWidget {
  final _ChatMessage message;

  const _Bubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final fromUser = message.fromUser;
    return Align(
      alignment: fromUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints:
            BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.78),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: fromUser ? AppColors.spiceBrown : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: fromUser ? null : Border.all(color: AppColors.line),
        ),
        child: message.isTyping
            ? const _TypingIndicator()
            : Text(
                message.text,
                style: TextStyle(
                  color: fromUser ? Colors.white : AppColors.ink,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
      ),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final delay = i * 0.2;
            final opacity = (_controller.value - delay).clamp(0.2, 1.0);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: AppColors.muted.withValues(alpha: opacity),
                shape: BoxShape.circle,
              ),
            );
          }),
        );
      },
    );
  }
}

class _MatchedRecipesSection extends StatelessWidget {
  final List<Recipe> recipes;
  final void Function(Recipe) onTap;

  const _MatchedRecipesSection({
    required this.recipes,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.cream,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.auto_awesome_rounded,
                  size: 14, color: AppColors.spiceBrown),
              SizedBox(width: 6),
              Text(
                'Resep dari koleksi Nusantara',
                style: TextStyle(
                  color: AppColors.spiceBrown,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        ...recipes.map(
          (recipe) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: RecipeCard(
              recipe: recipe,
              onTap: () => onTap(recipe),
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
