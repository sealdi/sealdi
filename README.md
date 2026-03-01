# Consulta de Oftalmología

Aplicación web simple para abrir la consulta de un paciente y **enviar automáticamente a impresión**:

- Prescripción de gafas.
- Prescripción de lentes de contacto.

## Cómo usar

1. Inicia un servidor estático desde este directorio:
   ```bash
   python3 -m http.server 8000
   ```
2. Abre `http://localhost:8000`.
3. Completa los datos del paciente y de ambas prescripciones.
4. Haz clic en **"Abrir consulta e imprimir prescripciones"**.
5. Se abrirá una ventana con formato de impresión que dispara `window.print()` automáticamente.

> Si el navegador bloquea ventanas emergentes, habilítalas para permitir la impresión automática.


## Nota si ves pantalla en blanco

- Abre la app usando servidor (`python3 -m http.server 8000`) y no con doble clic del archivo.
- Si el navegador bloquea pop-ups, la app ahora usa un modo alternativo de impresión en `iframe`.
- Prueba en `http://localhost:8000` o `http://127.0.0.1:8000`.
