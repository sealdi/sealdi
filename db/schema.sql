PRAGMA foreign_keys = ON;

-- Empresas de reclutamiento / clientes finales
CREATE TABLE IF NOT EXISTS clientes (
    id              INTEGER PRIMARY KEY,
    nombre          TEXT NOT NULL,
    tipo_entidad    TEXT, -- Hospital, clínica, consultorio, etc.
    ciudad          TEXT,
    estado          TEXT,
    pais            TEXT DEFAULT 'México',
    telefono        TEXT,
    email           TEXT,
    fecha_registro  TEXT NOT NULL DEFAULT (datetime('now'))
);

-- Catálogo de especialidades médicas
CREATE TABLE IF NOT EXISTS especialidades (
    id              INTEGER PRIMARY KEY,
    nombre          TEXT NOT NULL UNIQUE,
    descripcion     TEXT
);

-- Datos principales del candidato médico
CREATE TABLE IF NOT EXISTS candidatos (
    id                      INTEGER PRIMARY KEY,
    nombres                 TEXT NOT NULL,
    apellidos               TEXT NOT NULL,
    fecha_nacimiento        TEXT,
    genero                  TEXT,
    telefono                TEXT NOT NULL,
    email                   TEXT NOT NULL UNIQUE,
    ciudad                  TEXT,
    estado                  TEXT,
    pais                    TEXT DEFAULT 'México',
    linkedin_url            TEXT,
    cedula_profesional      TEXT UNIQUE,
    anos_experiencia        INTEGER DEFAULT 0 CHECK (anos_experiencia >= 0),
    salario_actual_mxn      REAL CHECK (salario_actual_mxn >= 0),
    salario_esperado_mxn    REAL CHECK (salario_esperado_mxn >= 0),
    disponibilidad          TEXT, -- Inmediata, 15 días, 30 días, etc.
    modalidad_preferida     TEXT, -- Presencial, híbrido, remoto
    reubicacion             INTEGER NOT NULL DEFAULT 0 CHECK (reubicacion IN (0,1)),
    resumen_profesional     TEXT,
    fuente                  TEXT, -- Referido, LinkedIn, bolsa, etc.
    estatus                 TEXT NOT NULL DEFAULT 'prospecto',
    fecha_registro          TEXT NOT NULL DEFAULT (datetime('now')),
    fecha_actualizacion     TEXT NOT NULL DEFAULT (datetime('now'))
);

-- Relación N:N entre candidatos y especialidades
CREATE TABLE IF NOT EXISTS candidato_especialidad (
    candidato_id        INTEGER NOT NULL,
    especialidad_id     INTEGER NOT NULL,
    principal           INTEGER NOT NULL DEFAULT 0 CHECK (principal IN (0,1)),
    PRIMARY KEY (candidato_id, especialidad_id),
    FOREIGN KEY (candidato_id) REFERENCES candidatos(id) ON DELETE CASCADE,
    FOREIGN KEY (especialidad_id) REFERENCES especialidades(id) ON DELETE RESTRICT
);

-- Certificaciones y estudios relevantes
CREATE TABLE IF NOT EXISTS certificaciones (
    id                  INTEGER PRIMARY KEY,
    candidato_id        INTEGER NOT NULL,
    nombre              TEXT NOT NULL,
    institucion         TEXT,
    fecha_emision       TEXT,
    fecha_expiracion    TEXT,
    vigente             INTEGER NOT NULL DEFAULT 1 CHECK (vigente IN (0,1)),
    FOREIGN KEY (candidato_id) REFERENCES candidatos(id) ON DELETE CASCADE
);

-- Idiomas de cada candidato
CREATE TABLE IF NOT EXISTS candidato_idioma (
    id                  INTEGER PRIMARY KEY,
    candidato_id        INTEGER NOT NULL,
    idioma              TEXT NOT NULL,
    nivel               TEXT NOT NULL, -- Básico, intermedio, avanzado, nativo
    FOREIGN KEY (candidato_id) REFERENCES candidatos(id) ON DELETE CASCADE
);

-- Historial laboral del candidato
CREATE TABLE IF NOT EXISTS experiencia_laboral (
    id                  INTEGER PRIMARY KEY,
    candidato_id        INTEGER NOT NULL,
    institucion         TEXT NOT NULL,
    puesto              TEXT NOT NULL,
    ciudad              TEXT,
    estado              TEXT,
    pais                TEXT DEFAULT 'México',
    fecha_inicio        TEXT NOT NULL,
    fecha_fin           TEXT,
    descripcion         TEXT,
    actual              INTEGER NOT NULL DEFAULT 0 CHECK (actual IN (0,1)),
    FOREIGN KEY (candidato_id) REFERENCES candidatos(id) ON DELETE CASCADE
);

-- Vacantes gestionadas para clientes
CREATE TABLE IF NOT EXISTS vacantes (
    id                      INTEGER PRIMARY KEY,
    cliente_id              INTEGER NOT NULL,
    titulo                  TEXT NOT NULL,
    especialidad_requerida  TEXT,
    ciudad                  TEXT,
    estado                  TEXT,
    pais                    TEXT DEFAULT 'México',
    salario_min_mxn         REAL CHECK (salario_min_mxn >= 0),
    salario_max_mxn         REAL CHECK (salario_max_mxn >= 0),
    tipo_contrato           TEXT,
    descripcion             TEXT,
    estatus                 TEXT NOT NULL DEFAULT 'abierta',
    fecha_publicacion       TEXT NOT NULL DEFAULT (date('now')),
    fecha_cierre            TEXT,
    FOREIGN KEY (cliente_id) REFERENCES clientes(id) ON DELETE CASCADE
);

-- Pipeline de reclutamiento por candidato-vacante
CREATE TABLE IF NOT EXISTS postulaciones (
    id                      INTEGER PRIMARY KEY,
    candidato_id            INTEGER NOT NULL,
    vacante_id              INTEGER NOT NULL,
    etapa                   TEXT NOT NULL DEFAULT 'aplicado', -- aplicado, filtro, entrevista, oferta, contratado, rechazado
    score_tecnico           REAL CHECK (score_tecnico BETWEEN 0 AND 100),
    score_cultural          REAL CHECK (score_cultural BETWEEN 0 AND 100),
    expectativa_salarial    REAL CHECK (expectativa_salarial >= 0),
    fecha_aplicacion        TEXT NOT NULL DEFAULT (datetime('now')),
    fecha_ultima_etapa      TEXT NOT NULL DEFAULT (datetime('now')),
    notas                   TEXT,
    UNIQUE (candidato_id, vacante_id),
    FOREIGN KEY (candidato_id) REFERENCES candidatos(id) ON DELETE CASCADE,
    FOREIGN KEY (vacante_id) REFERENCES vacantes(id) ON DELETE CASCADE
);

-- Bitácora de contacto para seguimiento comercial/reclutamiento
CREATE TABLE IF NOT EXISTS interacciones (
    id                  INTEGER PRIMARY KEY,
    candidato_id        INTEGER NOT NULL,
    tipo                TEXT NOT NULL, -- llamada, whatsapp, email, entrevista
    resultado           TEXT,
    fecha_interaccion   TEXT NOT NULL DEFAULT (datetime('now')),
    reclutador          TEXT,
    notas               TEXT,
    FOREIGN KEY (candidato_id) REFERENCES candidatos(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_candidatos_estatus ON candidatos(estatus);
CREATE INDEX IF NOT EXISTS idx_candidatos_ciudad ON candidatos(ciudad, estado);
CREATE INDEX IF NOT EXISTS idx_vacantes_estatus ON vacantes(estatus);
CREATE INDEX IF NOT EXISTS idx_postulaciones_etapa ON postulaciones(etapa);
CREATE INDEX IF NOT EXISTS idx_postulaciones_vacante ON postulaciones(vacante_id);

-- Trigger para actualizar fecha_actualizacion en cada modificación
CREATE TRIGGER IF NOT EXISTS trg_candidatos_update
AFTER UPDATE ON candidatos
FOR EACH ROW
BEGIN
    UPDATE candidatos
    SET fecha_actualizacion = datetime('now')
    WHERE id = NEW.id;
END;
