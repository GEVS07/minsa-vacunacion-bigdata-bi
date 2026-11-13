import pandas as pd
df = pd.read_csv('results/raw_metrics_runs.csv')
print('=== RESUMEN ESTADISTICO DE ESCENARIOS EXPERIMENTALES (EXP-01, EXP-02, EXP-03) ===')
print(df.groupby(['escenario', 'configuracion'])[['latencia_s', 'throughput_filas_s', 'pico_ram_gb']].mean())
