-- ------------------------------------------------------------------------------
-- Administración de conexiones
-- ------------------------------------------------------------------------------
-- Mantiene las conexiones en una vista para facilitar su matenimiento
CREATE OR REPLACE VIEW lista_bd_facultades
AS SELECT 'facultad_artes'AS nombre,
    'localhost' AS servidor,
    '5432' AS puerto
UNION
 SELECT 'facultad_ciencias_y_educacion'::text AS nombre,
    'localhost' AS servidor,
    '5432' AS puerto
UNION
 SELECT 'facultad_ingenieria'::text AS nombre,
    'localhost' AS servidor,
    '5432' AS puerto
UNION
 SELECT 'facultad_tecnologica'::text AS nombre,
    'localhost' AS servidor,
    '5432' AS puerto
UNION
 SELECT 'facultad_medio_ambiente'::text AS nombre,
    'localhost' AS servidor,
    '5432' AS puerto;



-- ------------------------------------------------------------------------------
-- Administración de prestamos
-- ------------------------------------------------------------------------------

-- Retorna la carrera de un estudiante. Validar que el estudiante se encuentre activo

CREATE OR REPLACE FUNCTION carrera_estudiante(codigo_estudiante integer)
  RETURNS integer AS
$carrera_estudiante$
declare c int;
declare consulta char(70);
declare reg_fac RECORD;
begin
	consulta := concat('select id_carr from estudiantes where cod_e =',codigo_estudiante);
    -- Hay que repetir este if por cada facultad
	for reg_fac in select	* from	lista_bd_facultades loop
	-- consulta por cada facultad
	select * from dblink(concat('dbname=', reg_fac.nombre, ' host=', reg_fac.servidor_bd, ' user=',current_user,' password=', current_user), consulta)
	as (carr int)into c;
       RETURN c;
	-- fin consulta por cada facultad
	end loop;
end $carrera_estudiante$ language plpgsql;


-- Verica un préstamo de lbros en la biblioteca,valida que el estudiante esté
-- inscrito en una carrera
CREATE OR REPLACE FUNCTION verificar_prestamo()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
declare
begin
	if (TG_OP = 'INSERT' ) then
		if carrera_estudiante(new.cod_e) is not null then
			return new;
		else
			return null;
			end if;
	end if;
end
$function$;

-- Impide que se registre un préstamo para un estudiante no registrado
create trigger verificar_prestamo before insert or update on presta for each row execute procedure verificar_prestamo();


-- Inserta un préstamo en la base de datos
create or replace function insertar_prestamo(cod_estudiante int, isbn_p numeric, num_ej_p int )
returns void as $insertar_prestamo$
declare
begin
	insert into presta(cod_e,isbn,num_ej, fech_p) values (cod_estudiante,isbn_p, num_ej_p, now());
end
$insertar_prestamo$ language plpgsql;

-- Retorna  un préstamo en la base de datos
create or replace function retornar_prestamo(cod_estudiante int, isbn_p numeric, num_ej_p int )
returns void as $verificar_estudiante$
declare
begin
	update  presta set
		fech_d = now()
	where
		cod_e = cod_estudiante and
		isbn = isbn_p and
		num_ej = num_ej_p and
		fech_d is null;
end
$verificar_estudiante$ language plpgsql;

-- ------------------------------------------------------------------------------
-- Administración de ejemplares
-- ------------------------------------------------------------------------------
-- Inserta un ejemplar en la base de datos
create or replace function insertar_ejemplar(isbn_n numeric, num_ej_n int )
returns void as $insertar_ejemplar$
declare
begin
	insert into ejemplares (isbn,num_ej) values (isbn_n, num_ej_n);
end
$insertar_ejemplar$ language plpgsql;


-- Elimina un ejemplar de la base de datos
create or replace function eliminar_ejemplar(isbn_e numeric, num_ej_e int )
returns void as $eliminar_ejemplar$
declare
begin
	delete from ejemplares where isbn = isbn_e and num_ej = num_ej_e;
end
$eliminar_ejemplar$ language plpgsql;

-- ------------------------------------------------------------------------------
-- Administración de libros
-- ------------------------------------------------------------------------------
create or replace function insertar_libro(isbn_n numeric,titulo_n varchar,edicion_n int,editorial_n varchar)
returns void as $insertar_libro$
declare
begin
	insert into libros (isbn ,titulo ,edicion ,editorial ) values (isbn_n ,titulo_n,edicion_n,editorial_n);
end
$insertar_libro$ language plpgsql;

-- Actualiza libro
create or replace function actualizar_libro(isbn_n numeric,titulo_n varchar,edicion_n int,editorial_n varchar)
returns void as $actualizar_libro$
declare
begin
	update  libros set
		titulo = titulo_n,
		edicion = edicion_n,
		editorial = editorial_n
	 where
		isbn = isbn_n;
end
$actualizar_libro$ language plpgsql;

-- Elimina un libro de la base de datos
create or replace function eliminar_libro(isbn_e numeric)
returns void as $eliminar_libro$
declare
begin
	delete from libros where isbn = isbn_e;
end
$eliminar_libro$ language plpgsql;

-- ------------------------------------------------------------------------------
-- Administración de autores
-- ------------------------------------------------------------------------------

create or replace function insertar_autor(id_a_n integer, nom_autor_n varchar, nacionalidad_n varchar)
returns void as $insertar_autor$
declare
begin
	insert into autores (id_a, nom_autor, nacionalidad ) values (id_a_n , nom_autor_n , nacionalidad_n);
end
$insertar_autor$ language plpgsql;

-- Actualiza libro
create or replace function actualizar_autor(id_a_n integer, nom_autor_n varchar, nacionalidad_n varchar)
returns void as $actualizar_autor$
declare
begin
	update  autores set
		nom_autor = nom_autor_n,
		nacionalidad = nacionalidad_n
	 where
		id_a = id_a_n;
end
$actualizar_autor$ language plpgsql;

-- Elimina un libro de la base de datos
create or replace function eliminar_autor(id_a_n integer)
returns void as $eliminar_autor$
declare
begin
	delete from autores where id_a = id_a_n;
end
$eliminar_autor$ language plpgsql;

-- ------------------------------------------------------------------------------
-- Accesos
-- ------------------------------------------------------------------------------
create role	bibliotecario;
GRANT ALL PRIVILEGES ON DATABASE biblioteca TO bibliotecario;
-- usuario de prueba
-- create user bib1  with password 'bib1' in role bibliotecario


-- Añade un bbibliotecario
create or replace function agregar_bibliotecario(nombre_usuario char(20))
returns void as $agregar_bibliotecario$
declare
consulta char(255);
reg_fac record;
begin
	consulta := concat('create user ',nombre_usuario,' with password ',nombre_usuario' in role bibliotecario');
  execute consulta;
	for reg_fac in select	* from	lista_bd_facultades loop
		-- consulta por cada facultad
		select dblink_exec(concat('dbname=', reg_fac.nombre, ' host=', reg_fac.servidor_bd, ' user=postgres password=postgres'), consulta);

		-- fin consulta por cada facultad
	end loop;
end
$agregar_bibliotecario$ language plpgsql;


-- retirar un bibliotecario
create or replace function retirar_bibliotecario(nombre_usuario char(20))
returns void as $retirar_bibliotecario$
declare
consulta char(255);
reg_fac record;
begin
	consulta := concat('drop user ',nombre_usuario);
  execute consulta;
	for reg_fac in select	* from	lista_bd_facultades loop
		select dblink_exec(concat('dbname=', reg_fac.nombre, ' host=', reg_fac.servidor_bd, ' user=postgres password=postgres'), consulta);
	end loop;
end
$retirar_bibliotecario$ language plpgsql;

--
