import 'package:flutter/material.dart';
import 'package:power_diyala/settings/theme_control.dart';

class CpInput extends StatefulWidget {
  final String? cpValue;
  final TextEditingController cpController;
  final TextEditingController kwhController;
  final String cpHint;
  final String kwhHint;

  const CpInput({
    super.key,
    required this.cpValue,
    required this.cpController,
    required this.kwhController,
    required this.cpHint,
    required this.kwhHint,
  });

  @override
  CpInputState createState() => CpInputState();
}

class CpInputState extends State<CpInput> {
  @override
  Widget build(BuildContext context) {
    List<Widget> cpFields = [];
    if (widget.cpValue != null && widget.cpValue!.toLowerCase() == 'yes') {
      cpFields.add(
        Expanded(
          child: TextFormField(
            controller: widget.cpController,
            decoration: InputDecoration(
              labelText: 'CP',
              labelStyle:
                  TextStyle(color: ThemeControl.errorColor.withOpacity(0.8)),
              hintText: 'Last: ${widget.cpHint}',
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.tertiary, width: 2.0),
              ),
              filled: true,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: const BorderSide(color: Colors.grey, width: 1.5),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '*';
              }
              return null;
            },
          ),
        ),
      );
      cpFields.add(const SizedBox(width: 4));
      cpFields.add(
        Expanded(
          child: TextFormField(
            controller: widget.kwhController,
            decoration: InputDecoration(
              labelText: 'Kwh',
              labelStyle:
                  TextStyle(color: ThemeControl.errorColor.withOpacity(0.8)),
              hintText: 'Last: ${widget.kwhHint}',
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              filled: true,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.tertiary, width: 2.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: const BorderSide(color: Colors.grey, width: 1.5),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '*';
              }
              return null;
            },
          ),
        ),
      );
    }
    return Row(
      children: cpFields,
    );
  }
}

//====================================phase==========================
class CpPhaseInput extends StatefulWidget {
  final String? cpValue;
  final String? phase;
  final List<TextEditingController> voltageControllers;
  final List<TextEditingController> loadControllers;
  final bool isCpEnabled;
  final ValueChanged<bool> onCpEnabledChanged;

  CpPhaseInput({
    super.key,
    required this.cpValue,
    required this.phase,
    List<TextEditingController>? voltageControllers,
    List<TextEditingController>? loadControllers,
    required this.isCpEnabled,
    required this.onCpEnabledChanged,
  })  : voltageControllers = voltageControllers ?? [],
        loadControllers = loadControllers ?? [];

  @override
  CpPhaseInputWidgetState createState() => CpPhaseInputWidgetState();
}

class CpPhaseInputWidgetState extends State<CpPhaseInput> {
  bool isCpEnabled = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.cpValue == null || widget.cpValue!.toLowerCase() != 'yes') {
      return Container();
    }

    List<Widget> phaseFields = [];
    if (widget.phase != null && widget.phase!.isNotEmpty) {
      if (widget.phase!.toLowerCase() == 'three phase') {
        phaseFields = _buildThreePhaseInputs();
      } else if (widget.phase!.toLowerCase() == 'single phase') {
        phaseFields = _buildSinglePhaseInputs();
      }
    }

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Main',
                style: TextStyle(fontSize: 18),
              ),
              Switch(
                value: widget.isCpEnabled,
                onChanged: (bool value) {
                  widget.onCpEnabledChanged(value);
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...phaseFields,
        ],
      ),
    );
  }

  List<Widget> _buildThreePhaseInputs() {
    List<Widget> vInputs = [];
    List<Widget> loadInputs = [];

    for (int i = 0; i < 3; i++) {
      vInputs.add(Expanded(
        child: Padding(
          padding: const EdgeInsets.all(1.0),
          child: TextFormField(
              controller: widget
                  .voltageControllers[i], // Use the passed voltage controller
              decoration: InputDecoration(
                labelText: 'V${i + 1}',
                labelStyle: TextStyle(
                    color: ThemeControl.errorColor.withOpacity(0.8),
                    fontSize: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.secondary),
                ),
                filled: true,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.tertiary,
                      width: 2.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: const BorderSide(color: Colors.grey, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 16.0, horizontal: 12.0),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '*';
                }
                return null;
              },
              enabled: widget.isCpEnabled),
        ),
      ));

      loadInputs.add(Expanded(
        child: Padding(
          padding: const EdgeInsets.all(1.0),
          child: TextFormField(
              controller:
                  widget.loadControllers[i], // Use the passed load controller
              decoration: InputDecoration(
                labelText: 'Load $i',
                labelStyle: TextStyle(
                    color: ThemeControl.errorColor.withOpacity(0.8),
                    fontSize: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.secondary),
                ),
                filled: true,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.tertiary,
                      width: 2.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: const BorderSide(color: Colors.grey, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 16.0, horizontal: 12.0),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '*';
                }
                return null;
              },
              enabled: widget.isCpEnabled),
        ),
      ));
    }

    return [
      Row(children: vInputs),
      const SizedBox(height: 8),
      Row(children: loadInputs),
    ];
  }

  List<Widget> _buildSinglePhaseInputs() {
    return [
      Row(
        children: [
          Expanded(
            child: TextFormField(
                controller: widget.voltageControllers.isNotEmpty
                    ? widget.voltageControllers[0]
                    : TextEditingController(),
                decoration: InputDecoration(
                  labelText: 'V1',
                  labelStyle: TextStyle(
                      color: ThemeControl.errorColor.withOpacity(0.8),
                      fontSize: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.secondary),
                  ),
                  filled: true,
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.tertiary,
                        width: 2.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide:
                        const BorderSide(color: Colors.grey, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 16.0, horizontal: 12.0),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '*';
                  }
                  return null;
                },
                enabled: widget.isCpEnabled),
          )
        ],
      ),
      const SizedBox(height: 8), // Space between Phase and Load
      Row(
        children: [
          Expanded(
            child: TextFormField(
                controller: widget.loadControllers.isNotEmpty
                    ? widget.loadControllers[0]
                    : TextEditingController(), // Use the first load controller if available
                decoration: InputDecoration(
                  labelText: 'Load 1',
                  labelStyle: TextStyle(
                      color: ThemeControl.errorColor.withOpacity(0.8),
                      fontSize: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.secondary),
                  ),
                  filled: true,
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.tertiary,
                        width: 2.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide:
                        const BorderSide(color: Colors.grey, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 16.0, horizontal: 12.0),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '*';
                  }
                  return null;
                },
                enabled: widget.isCpEnabled),
          )
        ],
      ),
    ];
  }
}
