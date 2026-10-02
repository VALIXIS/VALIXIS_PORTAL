import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/simulation_scenario.dart';
import '../../telemetry/providers/telemetry_provider.dart';

class TrafficSimulatorModal extends StatefulWidget {
  const TrafficSimulatorModal({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => const TrafficSimulatorModal(),
    );
  }

  @override
  State<TrafficSimulatorModal> createState() => _TrafficSimulatorModalState();
}

class _TrafficSimulatorModalState extends State<TrafficSimulatorModal> {
  late SimulationScenario _selectedScenario;
  double _eventRate = 100.0;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<TelemetryProvider>(context, listen: false);
    _selectedScenario = provider.activeSimulationScenario ?? SimulationScenario.blackFridaySurge;
    _eventRate = (provider.simulatedEventRate).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TelemetryProvider>(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 780, maxHeight: 680),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0D111A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF00E5FF).withOpacity(0.35),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00E5FF).withOpacity(0.15),
                blurRadius: 30,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF131B2A),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                  border: Border(
                    bottom: BorderSide(color: Colors.white.withOpacity(0.08)),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00E5FF).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.sensors_rounded, color: Color(0xFF00E5FF), size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Synthetic Traffic Simulator & Benchmark Injector',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Simulate high-concurrency traffic scenarios and observe live UI response',
                            style: TextStyle(color: Colors.white54, fontSize: 11),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white70),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              // Active Simulation Status Banner
              if (provider.isSimulating)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: const Color(0xFF00E5FF).withOpacity(0.15),
                  child: Row(
                    children: [
                      const Icon(Icons.bolt_rounded, color: Color(0xFF00E5FF), size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'LIVE STREAM ACTIVE: ${provider.activeSimulationScenario!.title.toUpperCase()} (${provider.simulatedEventRate} events/sec)',
                          style: const TextStyle(
                            color: Color(0xFF00E5FF),
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            letterSpacing: 0.8,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Events: ${provider.totalEventsInjected}',
                        style: const TextStyle(color: Colors.white70, fontSize: 11, fontFamily: 'monospace'),
                      ),
                    ],
                  ),
                ),

              // Content Body
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Select Operational Scenario Preset:',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Grid of Scenario Cards
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 2.2,
                        children: SimulationScenario.allScenarios.map((scenario) {
                          final isSelected = _selectedScenario.type == scenario.type;
                          return InkWell(
                            onTap: () {
                              setState(() {
                                _selectedScenario = scenario;
                                _eventRate = scenario.defaultEventRate.toDouble();
                              });
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? scenario.accentColor.withOpacity(0.12)
                                    : const Color(0xFF141A29),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? scenario.accentColor
                                      : Colors.white.withOpacity(0.08),
                                  width: isSelected ? 2.0 : 1.0,
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(scenario.icon, color: scenario.accentColor, size: 22),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          scenario.title,
                                          style: TextStyle(
                                            color: isSelected ? scenario.accentColor : Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          scenario.description,
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.6),
                                            fontSize: 10,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 20),

                      // Ingestion Rate Slider
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Synthetic Event Ingestion Rate:',
                            style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${_eventRate.round()} events / sec',
                            style: const TextStyle(
                              color: Color(0xFF00E5FF),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                      Slider(
                        value: _eventRate,
                        min: 10,
                        max: 1000,
                        divisions: 99,
                        activeColor: const Color(0xFF00E5FF),
                        inactiveColor: Colors.white.withOpacity(0.1),
                        onChanged: (val) {
                          setState(() => _eventRate = val);
                        },
                      ),

                      const SizedBox(height: 16),

                      // Preview Target Metrics
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF161E2E),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white.withOpacity(0.06)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildTargetStat('Target ARR', '\$${(_selectedScenario.targetArrUsd / 1000000).toStringAsFixed(2)}M'),
                            _buildTargetStat('Active Flows', '${_selectedScenario.targetActiveUsers}'),
                            _buildTargetStat('Simulated Latency', '${_selectedScenario.targetLatencyMs}ms'),
                            _buildTargetStat('Conversion Rate', '${_selectedScenario.targetConversionRate}%'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Action Buttons Footer
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF131B2A),
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(14)),
                  border: Border(top: BorderSide(color: Colors.white.withOpacity(0.08))),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (provider.isSimulating) ...[
                      OutlinedButton.icon(
                        onPressed: () {
                          provider.stopSimulation();
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFFF5252),
                          side: const BorderSide(color: Color(0xFFFF5252)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        icon: const Icon(Icons.stop_circle_rounded, size: 18),
                        label: const Text('Stop Simulation', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 12),
                    ],
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Close', style: TextStyle(color: Colors.white54)),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        provider.injectSyntheticScenario(
                          _selectedScenario,
                          ratePerSec: _eventRate.round(),
                        );
                        final messenger = ScaffoldMessenger.maybeOf(context);
                        Navigator.of(context).pop();
                        messenger?.showSnackBar(
                          SnackBar(
                            content: Text(
                              'Injected synthetic scenario: "${_selectedScenario.title}" at ${_eventRate.round()} events/sec!',
                            ),
                            backgroundColor: _selectedScenario.accentColor,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedScenario.accentColor,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.flash_on_rounded, size: 18),
                      label: const Text('Inject Events Now', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTargetStat(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }
}
