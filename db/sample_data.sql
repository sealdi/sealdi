INSERT INTO clientes (nombre, tipo_entidad, ciudad, estado, email)
VALUES
    ('Hospital San Miguel', 'Hospital privado', 'Guadalajara', 'Jalisco', 'rh@hsm.mx'),
    ('Clínica Vida Integral', 'Clínica', 'Monterrey', 'Nuevo León', 'talento@vida.mx');

INSERT INTO especialidades (nombre, descripcion)
VALUES
    ('Cardiología', 'Diagnóstico y tratamiento de enfermedades cardiovasculares'),
    ('Pediatría', 'Atención médica de recién nacidos, niños y adolescentes'),
    ('Anestesiología', 'Manejo perioperatorio y control del dolor');

INSERT INTO candidatos (
    nombres, apellidos, telefono, email, ciudad, estado, cedula_profesional,
    anos_experiencia, salario_esperado_mxn, disponibilidad, modalidad_preferida,
    reubicacion, resumen_profesional, fuente, estatus
)
VALUES
    ('Laura', 'Sánchez Ortega', '3312345678', 'laura.sanchez.med@example.com', 'Guadalajara', 'Jalisco', 'CED-9876543',
     9, 85000, '30 días', 'Híbrido', 1, 'Cardióloga con experiencia en hemodinamia y urgencias.', 'LinkedIn', 'prospecto'),
    ('Diego', 'Martínez Ruiz', '8111122233', 'diego.martinez.ped@example.com', 'Monterrey', 'Nuevo León', 'CED-1234567',
     6, 70000, 'Inmediata', 'Presencial', 0, 'Pediatra enfocado en cuidados intensivos neonatales.', 'Referido', 'entrevista');

INSERT INTO candidato_especialidad (candidato_id, especialidad_id, principal)
VALUES
    (1, 1, 1),
    (2, 2, 1);

INSERT INTO certificaciones (candidato_id, nombre, institucion, fecha_emision)
VALUES
    (1, 'ACLS', 'American Heart Association', '2023-01-15'),
    (2, 'PALS', 'American Heart Association', '2022-09-01');

INSERT INTO vacantes (
    cliente_id, titulo, especialidad_requerida, ciudad, estado,
    salario_min_mxn, salario_max_mxn, tipo_contrato, descripcion
)
VALUES
    (1, 'Médico Especialista en Cardiología', 'Cardiología', 'Guadalajara', 'Jalisco',
     75000, 95000, 'Tiempo completo', 'Consulta externa y atención hospitalaria.'),
    (2, 'Pediatra de Guardia Nocturna', 'Pediatría', 'Monterrey', 'Nuevo León',
     60000, 80000, 'Turno nocturno', 'Cobertura de guardias en hospital pediátrico.');

INSERT INTO postulaciones (candidato_id, vacante_id, etapa, score_tecnico, score_cultural, expectativa_salarial, notas)
VALUES
    (1, 1, 'entrevista', 92, 88, 85000, 'Buen ajuste para hemodinamia.'),
    (2, 2, 'filtro', 86, 91, 70000, 'Disponibilidad inmediata, buen fit cultural.');
