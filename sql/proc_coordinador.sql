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
 
