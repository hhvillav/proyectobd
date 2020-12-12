CREATE TABLE public.asignaturas (
	cod_a int4 NOT NULL,
	nom_a varchar(50) NULL,
	int_h int4 NULL,
	creditos int4 NULL,
	CONSTRAINT asignaturas_pk PRIMARY KEY (cod_a)
);

CREATE TABLE public.carreras (
	id_carr numeric NOT NULL,
	nom_carr varchar(50) NULL,
	reg_calif varchar(50) NULL,
	creditos int4 NULL,
	id_p int4 NULL,
	CONSTRAINT carreras_pk PRIMARY KEY (id_carr)
);

CREATE TABLE public.estudiantes (
	cod_e numeric NOT NULL,
	nom_e varchar(50) NULL,
	dir_e varchar(50) NULL,
	tel_e varchar(50) NULL,
	id_carr numeric NULL,
	fech_nac date NULL,
	CONSTRAINT estudiantes_pk PRIMARY KEY (cod_e)
);



CREATE TABLE public.imparte (
	id_p int4 NULL,
	cod_a int4 NULL,
	grupo int4 NULL,
	horario varchar(64) NULL
);


CREATE TABLE public.inscribe (
	cod_e numeric NOT NULL,
	cod_a int4 NOT NULL,
	id_p int4 NOT NULL,
	grupo bpchar(10) NOT NULL,
	n1 float8 NULL,
	n2 float8 NULL,
	n3 float8 NULL,
	CONSTRAINT inscribe_check_n1 CHECK (((n1 >= (0)::double precision) AND (n1 <= (5)::double precision))),
	CONSTRAINT inscribe_check_n2 CHECK (((n2 >= (0)::double precision) AND (n2 <= (5)::double precision))),
	CONSTRAINT inscribe_check_n3 CHECK (((n3 >= (0)::double precision) AND (n3 <= (5)::double precision))),
	CONSTRAINT inscribe_pk PRIMARY KEY (cod_e, cod_a, id_p, grupo)
);

CREATE TABLE public.log_notas (
	id_usuario varchar NOT NULL,
	ts timestamp(0) NOT NULL,
	cod_e int4 NOT NULL,
	id_a int4 NOT NULL,
	id_p int4 NOT NULL,
	grupo bpchar(1) NOT NULL,
	CONSTRAINT log_notas_pk PRIMARY KEY (id_usuario, ts, cod_e, id_a, id_p, grupo)
);


CREATE TABLE public.profesores (
	id_p int4 NOT NULL,
	nom_p varchar(50) NULL,
	profesion varchar(50) NULL,
	tel_p bpchar(12) NULL,
	CONSTRAINT profesores_pk PRIMARY KEY (id_p)
);

-- isbn se
CREATE TABLE referencia (
	cod_a int4 NOT NULL,
	isbn numeric(14) NOT NULL,
	CONSTRAINT referencia_pk PRIMARY KEY (cod_a, isbn)
);


---------------------------------------------------

###FUNCION modificar notas coordinador
create or replace function actualizar_notas_estudiante(id_e_n int, cod_a_n int, n1_n real, n2_n real, n3_n real)
returns void as $actualizar_notas_estudiante$
declare
begin
	update universidad.inscribe set
		n1 = n1_n,
		n2 = n2_n,
		n3 = n3_n
	WHERE
		cod_e=id_e_n AND
		cod_a=cod_a_n AND
		cod_e = (SELECT cod_e from universidad.estudiantes natural join universidad.carreras where (SELECT CURRENT_USER::int) = Carreras.id_p and cod_e = id_e_n) ;
end
$actualizar_notas_estudiante$ language plpgsql;

CREATE OR REPLACE FUNCTION grabar_operaciones() RETURNS
TRIGGER AS $grabar_operaciones$
DECLARE
BEGIN
	INSERT INTO universidad.cambios (
	nombre_disparador,
	tipo_disparador,
	nivel_disparador,
	comando)
	VALUES (
	TG_NAME,
	(SELECT CURRENT_USER),
	TG_LEVEL,
	TG_OP
	);
RETURN NULL;
END;
$grabar_operaciones$ LANGUAGE plpgsql;

CREATE TRIGGER grabar_operaciones AFTER INSERT OR UPDATE OR
DELETE
ON universidad.inscribe FOR EACH STATEMENT
EXECUTE PROCEDURE grabar_operaciones();
