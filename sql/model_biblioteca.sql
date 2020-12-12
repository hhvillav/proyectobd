CREATE TABLE autores (
	id_a int4 NOT NULL,
	nom_autor varchar(50) NULL,
	nacionalidad varchar(50) NULL DEFAULT 0,
	CONSTRAINT autores_pk PRIMARY KEY (id_a)
);


CREATE TABLE ejemplares (
	isbn numeric(14) NOT NULL,
	num_ej int4 NOT NULL
);


CREATE TABLE escribe (
	isbn numeric NOT NULL,
	id_a int4 NOT NULL,
	CONSTRAINT escribe_pk PRIMARY KEY (isbn, id_a)
);

-- public.escribe foreign keys
ALTER TABLE public.escribe ADD CONSTRAINT escribe_fk_autores FOREIGN KEY (id_a) REFERENCES autores(id_a);
ALTER TABLE public.escribe ADD CONSTRAINT escribe_fk_libros FOREIGN KEY (isbn) REFERENCES libros(isbn);

CREATE TABLE presta (
	cod_e numeric NOT NULL,
	isbn numeric(14) NOT NULL,
	num_ej int4 NOT NULL,
	fech_p timestamp NOT NULL,
	fech_d timestamp NULL,
	CONSTRAINT presta_pk PRIMARY KEY (cod_e, isbn, num_ej, fech_p)
);

CREATE TABLE public.libros (
	isbn numeric NOT NULL,
	titulo varchar NOT NULL,
	edicion int4 NOT NULL,
	editorial varchar NOT NULL,
	CONSTRAINT libros_pk PRIMARY KEY (isbn)
);


-- ----------------------------------------------------------------------------
-- Vistas para consulta de libros
-- ----------------------------------------------------------------------------
CREATE VIEW consulta_libros AS
(
	select isbn, titulo, nom_autor, edicion from libros natural join escribe natural join autores
)


CREATE VIEW consulta_prestamos AS
(
	select cod_e,isbn, titulo, nom_autor, edicion,fech_p, fech_d from libros natural join escribe natural join autores natural join presta
)
