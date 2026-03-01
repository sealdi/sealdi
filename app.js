const form = document.getElementById("consulta-form");
const estado = document.getElementById("estado");
const mensajeEstado = document.getElementById("mensaje-estado");
const reimprimir = document.getElementById("reimprimir");

let ultimaConsulta = null;

function escapeHtml(value) {
  return String(value)
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;");
}

function buildDocumentoParaImprimir(data) {
  const ahora = new Date().toLocaleString("es-ES");
  return `
  <!doctype html>
  <html lang="es">
    <head>
      <meta charset="UTF-8" />
      <title>Prescripciones oftalmológicas</title>
      <style>
        body { font-family: Arial, sans-serif; margin: 24px; color: #222; }
        .bloque { border: 1px solid #999; border-radius: 8px; padding: 12px; margin-bottom: 18px; }
        h1, h2 { margin: 0 0 10px; }
        p { margin: 5px 0; }
        table { width: 100%; border-collapse: collapse; margin-top: 8px; }
        th, td { border: 1px solid #555; padding: 6px; text-align: left; }
        .footer { margin-top: 20px; font-size: 12px; color: #555; }
      </style>
    </head>
    <body>
      <h1>Consulta de oftalmología</h1>
      <p><strong>Paciente:</strong> ${escapeHtml(data.nombre)}</p>
      <p><strong>Documento:</strong> ${escapeHtml(data.documento)} | <strong>Edad:</strong> ${escapeHtml(data.edad)}</p>
      <p><strong>Fecha de consulta:</strong> ${escapeHtml(data.fecha)}</p>

      <section class="bloque">
        <h2>Prescripción de gafas</h2>
        <table>
          <thead>
            <tr>
              <th>Campo</th>
              <th>OD</th>
              <th>OI</th>
            </tr>
          </thead>
          <tbody>
            <tr><td>Esfera</td><td>${escapeHtml(data.gafas_od_esfera)}</td><td>${escapeHtml(data.gafas_oi_esfera)}</td></tr>
            <tr><td>Cilindro</td><td>${escapeHtml(data.gafas_od_cilindro)}</td><td>${escapeHtml(data.gafas_oi_cilindro)}</td></tr>
            <tr><td>Eje</td><td>${escapeHtml(data.gafas_od_eje)}</td><td>${escapeHtml(data.gafas_oi_eje)}</td></tr>
          </tbody>
        </table>
        <p><strong>Distancia pupilar:</strong> ${escapeHtml(data.gafas_dp)}</p>
        <p><strong>Observaciones:</strong> ${escapeHtml(data.gafas_obs || "Sin observaciones")}</p>
      </section>

      <section class="bloque">
        <h2>Prescripción de lentes de contacto</h2>
        <table>
          <thead>
            <tr>
              <th>Campo</th>
              <th>OD</th>
              <th>OI</th>
            </tr>
          </thead>
          <tbody>
            <tr><td>Base curva</td><td>${escapeHtml(data.lc_od_bc)}</td><td>${escapeHtml(data.lc_oi_bc)}</td></tr>
            <tr><td>Diámetro</td><td>${escapeHtml(data.lc_od_diametro)}</td><td>${escapeHtml(data.lc_oi_diametro)}</td></tr>
            <tr><td>Potencia</td><td>${escapeHtml(data.lc_od_potencia)}</td><td>${escapeHtml(data.lc_oi_potencia)}</td></tr>
          </tbody>
        </table>
        <p><strong>Marca:</strong> ${escapeHtml(data.lc_marca)}</p>
        <p><strong>Frecuencia de reemplazo:</strong> ${escapeHtml(data.lc_reemplazo)}</p>
      </section>

      <p class="footer">Generado automáticamente al abrir la consulta. Fecha/hora de impresión: ${escapeHtml(ahora)}</p>
      <script>
        window.onload = () => {
          window.print();
        };
      </script>
    </body>
  </html>
  `;
}

function imprimirConIframe(documento) {
  const iframe = document.createElement("iframe");
  iframe.style.position = "fixed";
  iframe.style.right = "0";
  iframe.style.bottom = "0";
  iframe.style.width = "0";
  iframe.style.height = "0";
  iframe.style.border = "0";
  document.body.appendChild(iframe);

  const doc = iframe.contentWindow.document;
  doc.open();
  doc.write(documento);
  doc.close();

  setTimeout(() => {
    iframe.contentWindow.focus();
    iframe.contentWindow.print();
    setTimeout(() => iframe.remove(), 3000);
  }, 250);
}

function imprimirPrescripciones(data) {
  const documento = buildDocumentoParaImprimir(data);

  try {
    const ventana = window.open("", "_blank", "width=900,height=700");

    if (!ventana) {
      mensajeEstado.textContent =
        "El navegador bloqueó la nueva ventana. Se usó un modo alternativo de impresión dentro de la página.";
      imprimirConIframe(documento);
      return;
    }

    ventana.document.open();
    ventana.document.write(documento);
    ventana.document.close();
  } catch (error) {
    console.error("No se pudo abrir la ventana de impresión, se usa iframe:", error);
    mensajeEstado.textContent =
      "Hubo un problema con la ventana de impresión. Se usó un modo alternativo de impresión.";
    imprimirConIframe(documento);
  }
}

form.addEventListener("submit", (event) => {
  event.preventDefault();
  const data = Object.fromEntries(new FormData(form).entries());
  ultimaConsulta = data;

  estado.classList.remove("hidden");
  mensajeEstado.textContent = `La consulta de ${data.nombre} está abierta y se envió la impresión de gafas y lentes de contacto.`;

  imprimirPrescripciones(data);
});

reimprimir.addEventListener("click", () => {
  if (!ultimaConsulta) return;
  imprimirPrescripciones(ultimaConsulta);
});

form.elements.fecha.value = new Date().toISOString().slice(0, 10);
