import 'package:flutter/material.dart';
import '../../theme/design_tokens.dart';

class DictionaryScreen extends StatefulWidget {
  const DictionaryScreen({super.key});

  @override
  State<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> {
  final TextEditingController _controller = TextEditingController();
  String? _word;
  String? _definition;
  String? _phonetic;
  String? _partOfSpeech;
  List<String>? _definitions;
  List<String>? _synonyms;
  bool _isLoading = false;

  static const _dictionary = <String, Map<String, dynamic>>{
    'eloquent': {
      'phonetic': '/ˈel.ə.kwənt/',
      'partOfSpeech': 'adjective',
      'definitions': [
        'Fluent or persuasive in speaking or writing.',
        'Clearly expressing or indicating something.',
      ],
      'synonyms': ['articulate', 'fluent', 'expressive', 'persuasive', 'silver-tongued'],
    },
    'ephemeral': {
      'phonetic': '/ɪˈfem.ər.əl/',
      'partOfSpeech': 'adjective',
      'definitions': [
        'Lasting for a very short time; transitory.',
        'Something that exists only briefly.',
      ],
      'synonyms': ['fleeting', 'transient', 'brief', 'momentary', 'passing'],
    },
    'serendipity': {
      'phonetic': '/ˌser.ənˈdɪp.ɪ.ti/',
      'partOfSpeech': 'noun',
      'definitions': [
        'The occurrence of events by chance in a happy or beneficial way.',
        'The faculty of making fortunate discoveries by accident.',
      ],
      'synonyms': ['luck', 'fortune', 'chance', 'accident', 'happy coincidence'],
    },
    'ubiquitous': {
      'phonetic': '/juːˈbɪk.wɪ.təs/',
      'partOfSpeech': 'adjective',
      'definitions': [
        'Present, appearing, or found everywhere.',
        'Being everywhere at once.',
      ],
      'synonyms': ['omnipresent', 'everywhere', 'pervasive', 'universal', 'all-over'],
    },
    'ethereal': {
      'phonetic': '/ɪˈθɪə.ri.əl/',
      'partOfSpeech': 'adjective',
      'definitions': [
        'Extremely delicate and light in a way that seems not of this world.',
        'Heavenly or spiritual in nature.',
      ],
      'synonyms': ['delicate', 'airy', 'light', 'celestial', 'heavenly'],
    },
    'quintessential': {
      'phonetic': '/ˌkwɪn.tɪˈsen.ʃəl/',
      'partOfSpeech': 'adjective',
      'definitions': [
        'Representing the most perfect or typical example of a quality or class.',
        'Of the pure and essential essence of something.',
      ],
      'synonyms': ['typical', 'archetypal', 'classic', 'essential', 'representative'],
    },
    'resilient': {
      'phonetic': '/rɪˈzɪl.i.ənt/',
      'partOfSpeech': 'adjective',
      'definitions': [
        'Able to withstand or recover quickly from difficult conditions.',
        'Springing back into shape after being stretched or compressed.',
      ],
      'synonyms': ['tough', 'hardy', 'strong', 'flexible', 'adaptable'],
    },
    'phenomenon': {
      'phonetic': '/fɪˈnɒm.ɪ.nɒn/',
      'partOfSpeech': 'noun',
      'definitions': [
        'A fact or situation that is observed to exist or happen.',
        'A remarkable person, thing, or event.',
      ],
      'synonyms': ['occurrence', 'event', 'happening', 'marvel', 'wonder'],
    },
    'surreptitious': {
      'phonetic': '/ˌsʌr.əpˈtɪʃ.əs/',
      'partOfSpeech': 'adjective',
      'definitions': [
        'Kept secret, especially because it would not be approved of.',
        'Acting in a stealthy or secretive way.',
      ],
      'synonyms': ['secret', 'stealthy', 'clandestine', 'covert', 'underhand'],
    },
    'hobbit': {
      'phonetic': '/ˈhɒb.ɪt/',
      'partOfSpeech': 'noun',
      'definitions': [
        'A member of an imaginary race of small, peaceful, furry-footed people who live in holes in the ground.',
        'A creature from J.R.R. Tolkien\'s Middle-earth legendarium.',
      ],
      'synonyms': ['halfling', 'little one', 'Bilbo', 'Frodo'],
    },
    'sherlock': {
      'phonetic': '/ˈʃɜː.lɒk/',
      'partOfSpeech': 'noun',
      'definitions': [
        'A fictional detective known for his keen observation and deductive reasoning.',
        'A person with great powers of observation and deduction.',
      ],
      'synonyms': ['detective', 'sleuth', 'investigator', 'deducer'],
    },
    'elementary': {
      'phonetic': '/ˌel.ɪˈmen.tər.i/',
      'partOfSpeech': 'adjective',
      'definitions': [
        'Relating to the most basic or simplest aspects of a subject.',
        'Easy to solve or understand.',
      ],
      'synonyms': ['basic', 'simple', 'fundamental', 'rudimentary', 'straightforward'],
    },
  };

  void _lookupWord() {
    final word = _controller.text.trim().toLowerCase();
    if (word.isEmpty) return;

    setState(() {
      _isLoading = true;
      _word = word;
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      final entry = _dictionary[word];
      setState(() {
        _isLoading = false;
        if (entry != null) {
          _phonetic = entry['phonetic'] as String;
          _partOfSpeech = entry['partOfSpeech'] as String;
          _definitions = List<String>.from(entry['definitions']);
          _synonyms = List<String>.from(entry['synonyms']);
          _definition = _definitions!.first;
        } else {
          _phonetic = null;
          _partOfSpeech = null;
          _definitions = null;
          _synonyms = null;
          _definition = null;
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ── Header with back button
            Padding(
              padding: const EdgeInsets.fromLTRB(
                DesignTokens.grid8,
                DesignTokens.grid16,
                DesignTokens.grid24,
                DesignTokens.grid8,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 4),
                  Text('Dictionary', style: theme.textTheme.displaySmall),
                ],
              ),
            ),

            // Search input
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: DesignTokens.grid16),
              child: Container(
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                ),
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'Search a word…',
                    prefixIcon: Icon(Icons.search,
                        color: theme.textTheme.bodyMedium?.color?.withAlpha(100)),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.volume_up, size: 18),
                      onPressed: _word != null && _phonetic != null
                          ? () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Pronunciation: $_phonetic'),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          : null,
                    ),
                    border: InputBorder.none,
                    filled: false,
                  ),
                  onSubmitted: (_) => _lookupWord(),
                ),
              ),
            ),
            const SizedBox(height: DesignTokens.grid16),

            // Quick actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: DesignTokens.grid16),
              child: Row(
                children: [
                  _actionChip(context, Icons.language, 'Wikipedia'),
                  const SizedBox(width: 8),
                  _actionChip(context, Icons.translate, 'Translate'),
                  const SizedBox(width: 8),
                  _actionChip(context, Icons.record_voice_over, 'Pronunciation'),
                ],
              ),
            ),

            const SizedBox(height: DesignTokens.grid24),

            // Results
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _word == null
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.menu_book, size: 56,
                                  color: theme.textTheme.bodySmall?.color?.withAlpha(60)),
                              const SizedBox(height: 16),
                              Text('Search for a word',
                                  style: theme.textTheme.bodyLarge),
                              const SizedBox(height: 8),
                              Text('Offline dictionary powered by WordNet',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.textTheme.bodySmall?.color?.withAlpha(120),
                                  )),
                            ],
                          ),
                        )
                      : _definition != null
                          ? SingleChildScrollView(
                              padding: const EdgeInsets.all(DesignTokens.grid24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _word!.toUpperCase(),
                                    style: theme.textTheme.displaySmall?.copyWith(
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Text(_phonetic ?? '/ˈ$_word/',
                                          style: theme.textTheme.bodyLarge?.copyWith(
                                            color: theme.textTheme.bodyLarge?.color?.withAlpha(150),
                                          )),
                                      const SizedBox(width: 12),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.primary.withAlpha(15),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          _partOfSpeech ?? '',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: theme.colorScheme.primary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      GestureDetector(
                                        onTap: () {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Pronunciation: $_phonetic'),
                                              duration: const Duration(seconds: 2),
                                            ),
                                          );
                                        },
                                        child: Row(
                                          children: [
                                            Icon(Icons.volume_up, size: 18,
                                                color: theme.colorScheme.primary),
                                            const SizedBox(width: 4),
                                            Text('Listen',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: theme.colorScheme.primary,
                                                )),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: DesignTokens.grid32),
                                  // Definitions
                                  ...(_definitions ?? []).asMap().entries.map(
                                    (entry) => Padding(
                                      padding: EdgeInsets.only(
                                        bottom: entry.key < (_definitions!.length - 1)
                                            ? DesignTokens.grid16
                                            : 0,
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets.all(DesignTokens.grid20),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.primary.withAlpha(8),
                                          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                                          border: Border.all(
                                            color: theme.colorScheme.primary.withAlpha(20),
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  width: 20,
                                                  height: 20,
                                                  decoration: BoxDecoration(
                                                    color: theme.colorScheme.primary,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      '${entry.key + 1}',
                                                      style: const TextStyle(
                                                        fontSize: 11,
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.bold,
                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text('Definition',
                                                    style: theme.textTheme.labelLarge),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Text(entry.value,
                                                style: theme.textTheme.bodyLarge?.copyWith(
                                                  height: 1.5,
                                                )),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: DesignTokens.grid24),
                                  if (_synonyms != null && _synonyms!.isNotEmpty) ...[                                    Text('Synonyms',
                                        style: theme.textTheme.labelLarge),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: _synonyms!
                                          .map((s) => Chip(
                                                label: Text(s, style: const TextStyle(fontSize: 12)),
                                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                              ))
                                          .toList(),
                                    ),
                                  ],
                                  const SizedBox(height: DesignTokens.grid24),
                                  // Full Definition button
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton.icon(
                                      onPressed: () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Full definition - coming soon'),
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.open_in_new, size: 16),
                                      label: const Text('Full Definition'),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.search_off, size: 48,
                                      color: Colors.orange[300]),
                                  const SizedBox(height: 16),
                                  Text('Word not found',
                                      style: theme.textTheme.bodyLarge),
                                  const SizedBox(height: 8),
                                  Text('"$_word" is not in our dictionary',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.textTheme.bodySmall?.color?.withAlpha(120),
                                      )),
                                  const SizedBox(height: 16),
                                  OutlinedButton.icon(
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Searching Wikipedia...'),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.language, size: 16),
                                    label: const Text('Search on Wikipedia'),
                                  ),
                                ],
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionChip(BuildContext context, IconData icon, String label) {
    final theme = Theme.of(context);
    return ActionChip(
      avatar: Icon(icon, size: 16, color: theme.colorScheme.primary),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      onPressed: () {},
    );
  }
}
