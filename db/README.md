# Base de datos de candidatos médicos (SQLite)

Este esquema está diseñado para una empresa de reclutamiento médico.

## Archivos

- `schema.sql`: estructura completa de la base de datos.
- `sample_data.sql`: datos de ejemplo para comenzar rápido.

## Crear la base de datos

```bash
sqlite3 reclutamiento_medico.db ".read db/schema.sql"
sqlite3 reclutamiento_medico.db ".read db/sample_data.sql"
```

## Consultas útiles

### 1) Candidatos por especialidad

```sql
SELECT c.id, c.nombres, c.apellidos, e.nombre AS especialidad, c.estatus
FROM candidatos c
JOIN candidato_especialidad ce ON ce.candidato_id = c.id
JOIN especialidades e ON e.id = ce.especialidad_id
ORDER BY e.nombre, c.apellidos;
```

### 2) Pipeline por vacante

```sql
SELECT v.titulo, p.etapa, COUNT(*) AS total
FROM postulaciones p
JOIN vacantes v ON v.id = p.vacante_id
GROUP BY v.titulo, p.etapa
ORDER BY v.titulo, p.etapa;
```

### 3) Candidatos disponibles para contratación pronta

```sql
SELECT id, nombres, apellidos, especialidad_requerida, disponibilidad
FROM (
    SELECT c.id, c.nombres, c.apellidos, c.disponibilidad,
           GROUP_CONCAT(e.nombre, ', ') AS especialidad_requerida
    FROM candidatos c
    LEFT JOIN candidato_especialidad ce ON ce.candidato_id = c.id
    LEFT JOIN especialidades e ON e.id = ce.especialidad_id
    WHERE c.estatus IN ('prospecto', 'entrevista')
    GROUP BY c.id
)
ORDER BY disponibilidad;
```
