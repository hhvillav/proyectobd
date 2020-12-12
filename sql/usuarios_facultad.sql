CREATE ROLE "Estudiante"
CREATE ROLE "Profesor"
CREATE ROLE "Coordinador"
CREATE ROLE "Bibliotecario";


GRANT USAGE ON SCHEMA "universidad" TO "coordinador";
grant USAGE ON VIEW "consultas_notas" TO "coordinador"
GRANT SELECT, UPDATE, DELETE ON universidad.inscribe TO "Coordinador";



-- añadir usuario
create or replace function agregar_usuario(nombre_usuario char(20), rol char(20))
returns void as $agregar_usuario$
declare
consulta char(255);
begin
	consulta := concat('create user ',nombre_usuario,' with password ',nombre_usuario' in role ', rol);
	execute consulta;
	select dblink_exec(concat('dbname=biblioteca host=localhost user=postgres password=postgres'), consulta);
end
$agregar_usuario$ language plpgsql;


-- retirar un usuario
create or replace function retirar_usuario(nombre_usuario char(20))
returns void as $retirar_usuario$
declare
consulta char(255);
begin
	consulta := concat('drop user ',nombre_usuario);
	execute consulta;
	select dblink_exec(concat('dbname=biblioteca host=localhost user=postgres password=postgres'), consulta);
end
$retirar_usuario$ language plpgsql;
