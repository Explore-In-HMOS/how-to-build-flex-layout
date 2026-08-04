export interface Metric {
  key: string;
  label: string;
  value: number;
  unit: string;
}

// Mock health data — no sensors, no network. Fixed numbers so every codelab
// step renders identically regardless of when or on what device it runs.
export class HealthStore {
  static tiles(): Metric[] {
    return [
      { key: 'hr', label: 'HR', value: 72, unit: 'bpm' },
      { key: 'steps', label: 'Steps', value: 6420, unit: '' },
      { key: 'kcal', label: 'Cal', value: 410, unit: 'kcal' },
      { key: 'spo2', label: 'SpO₂', value: 98, unit: '%' },
      { key: 'dist', label: 'Dist', value: 4, unit: 'km' },
      { key: 'sleep', label: 'Sleep', value: 7, unit: 'h' }
    ];
  }

  // Today vs. yesterday — used by the optional VitalsStrip interface.
  static readonly stepsToday: number = 6420;
  static readonly stepsYesterday: number = 8950;
  static readonly caloriesToday: number = 410;
  static readonly caloriesYesterday: number = 530;
}