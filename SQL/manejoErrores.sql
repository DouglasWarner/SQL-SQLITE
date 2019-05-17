delimiter #

drop procedure if exists insertarJugador#

create procedure insertarJugador(	unNombre varchar(50), 
									unApellido varchar(50), 
									unAltura decimal(3,2), 
									unPuesto varchar(15),
									unEquipo smallint
									)
comment 'Inserta un nuevo jugador en la tabla liga.jugador con gestion de excepciones'
begin
	declare unID smallint;
	declare puestoInvalido smallint default 0;
	declare unCapitan smallint;

	declare continue handler for 1265
	begin
		select concat('El jugador ',unNombre,' ', unApellido, ' no tiene un puesto válido') as Wornin;
	end;

	declare exit handler for 1452
	begin
		select concat('El jugador ',unNombre,' ', unApellido, ' no tiene un equipo válido') as Wornin;
	end;

	declare exit handler for 4025
	begin
		select concat('El jugador ',unNombre,' ', unApellido, ' excede la altura permitida') as Wornin;
	end;

	set unID = (select ifnull(max(id) +1, 1) from jugador);

	/* 
		Forma tradicional de manejar un error propio

	if unAltura > 2.72 then
		signal sqlstate '22003' set mysql_errno = 1264, message_text = 'Altura fuera de rango';
	end if;
	*/

	-- Excepcion NOMBRE VALIDO --> select ' ' rlike '^[a-zñáéíóú]+[ ]{1}[a-zñáéíóú]+$';
	set unCapitan = (select capitan from equipo where id = unEquipo);

	insert into jugador(id, nombre, apellido, altura, puesto, fecha_alta, equipo, capitan) 
	values (unID, unNombre, unApellido, unAltura, unPuesto, curdate(), unEquipo, unCapitan);


end#

delimiter ;
