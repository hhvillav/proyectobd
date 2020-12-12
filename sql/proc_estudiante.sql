-- La primera funcion de consultar notas
CREATE VIEW consultas_notas AS
(
	Select cod_e,cod_a, id_p, n1, n2, n3, coalesce(n1,0)0.35+coalesce(n2,0).35+coalesce(n3,0)*.3 Promedio from estudiantes natural join inscribe
)
-- Segundafunciondeconsultarlibros
create or replace function consultas_estudiante() returns setof consultas_notas as $body$
declare
	r consultas_notas;
begin
for r in
  SELECT cod_e AS codigo, cod_a AS codigo_asignatura, n1, n2, n3,promedio FROM consultas_notas where cod_e =  (SELECT CURRENT_USER::integer)
loop
return next r;
end loop;
return;
end
$body$
language 'plpgsql';

CREATE OR REPLACE VIEW consulta_remota_libros AS
SELECT *
FROM dblink(concat('dbname=biblioteca port=5432 user=',current_user,' password=', current_user),
'select isbn, titulo, nom_autor, edicion from consulta_libros')
AS t1 (isbn int, titulo varchar, nom_autor varchar, edicion int );

create or replace function consultas_libros_autor_estudiante(autor varchar) returns setof consulta_remota_libros as $body$
declare
	r consulta_remota_libros;
begin
for r in
  SELECT isbn AS isbn, titulo AS titulo , nom_autor AS Nombre_Autor, edicion AS edicion FROM consulta_remota_libros where lower(nom_autor) like autor
loop
return next r;
end loop;
return;
end
$body$
language 'plpgsql';

-- CONSULTAR LIBRO POR TITULO

create or replace function consultas_libros_titulo_estudiante(titulo varchar) returns setof consulta_remota_libros as $body$
declare
	r consulta_remota_libros;
begin
for r in
  SELECT isbn AS isbn, titulo AS titulo , nom_autor AS Nombre_Autor, edicion AS edicion FROM consulta_remota_libros where lower(titutlo) like titulo
loop
return next r;
end loop;
return;
end
$body$
language 'plpgsql';

-- FUNCION de verificar los prestamos
create or replace function consultas_prestamo_estudiante() returns setof consulta_remota_prestamos as $body$
declare
	r consulta_remota_libros;
begin
for r in
  SELECT isbn AS isbn, titulo AS titulo , nom_autor AS Nombre_Autor, edicion AS edicion, fech_p, fech_d FROM consulta_remota_prestamos where cod_e =  (SELECT CURRENT_USER::integer)
loop
return next r;
end loop;
return;
end
$body$
language 'plpgsql';

CREATE OR REPLACE VIEW consulta_remota_libros AS
SELECT *
FROM dblink('dbname=biblioteca port=5432 user=',current_user,' password=', current_user),
'select isbn, titulo, nom_autor, edicion from consulta_libros')
AS t1 (isbn int, titulo varchar, nom_autor varchar, edicion int )
