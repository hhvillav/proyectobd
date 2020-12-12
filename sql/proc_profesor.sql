CREATE OR REPLACE FUNCTION verificar_libro()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
declare
	insbn_b numeric ;
begin
	if (TG_OP = 'INSERT' ) then
		select isbn from consulta_remota_libros
			where isbn = new.isbn into insbn_b;

	if insbn_b is not null then
			return new;
		else
			return null;
			end if;
	end if;
end
$function$;

-- Impide que se registre una referencia si el libro no existe
create trigger verificar_libro before insert or update on referencia for each row execute procedure verificar_libro();
