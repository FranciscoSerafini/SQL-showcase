-- Autor: Francisco Serafini Giorgi
-- Fecha: 24/02/2024
/*
-- Descripción: realiza un seguimiento de las ventas de un artículo específico en un rango de fechas dado, 
diferenciando entre ventas minoristas y mayoristas. El procedimiento incluye validaciones para garantizar que las fechas sean 
coherentes, que el artículo exista en la base de datos y que el tipo de venta sea válido (1 para minorista, 2 para mayorista).
Dependiendo del tipo de venta, se ejecutan consultas SQL para recuperar la cantidad total vendida por sucursal en el periodo 
especificado. Finalmente, se proporcionan mensajes informativos sobre el resultado de la consulta, y en caso de errores, 
se emite un mensaje detallado.
*/


/*

Crear el procedimiento almacenado "sp_cantidad_vendida", que presente el total de prendas vendidas (minorista) por sucursal para
un artículo determinado en un rango de fechas específico.

El procedimiento deberá recibir tres parámetros: el artículo (código), fecha desde, fecha hasta; y devolver como resultado
SUCURSAL (denominación) y CANTIDAD VENDIDA, ordenando por sucursal de forma ascendente.

Se deberá validar que la fecha desde sea menor o igual a la fecha hasta, y en caso contrario detener la ejecución y mostrar
el mensaje "El rango de fechas ingresado no es correcto!". Se deberá validar también que el artículo ingresado exista, y en caso 
contrario mostrar "El artículo [código] no existe!.".

*/

CREATE OR ALTER PROCEDURE sp_cantidad_vendida_minorista
@articulo VARCHAR(50),
@fechaDesde SMALLDATETIME,
@fechaHasta SMALLDATETIME
AS
DECLARE @mensaje VARCHAR(255) = '';
--
BEGIN TRY
		IF @fechaDesde > @fechaHasta --VALIDACIONES DE FECHAS
			BEGIN
				PRINT'EL RANGO DE FECHA ESTA MAL, POR FAVOR INGRESAR BIEN LAS FECHAS'
				GOTO FIN
			END
		--
		IF NOT EXISTS(SELECT * FROM articulos WHERE articulo = @articulo)
			BEGIN
				PRINT'EL ARTICULO QUE QUIERE INGRESAR NO EXISTE DENTRO DE LA BASE DE DATOS: ' + STR(@articulo)
				GOTO FIN
			END
		--
		SELECT
			s.denominacion AS 'NOMBRE DE SUCURSAL',
			SUM(vc.total) AS 'CANTIDAD VENDIDAD'
		FROM
			sucursales AS s 
			INNER JOIN vencab AS vc ON s.sucursal = vc.sucursal
			INNER JOIN vendet AS vt ON (vt.letra = vc.letra AND vt.factura = vc.factura)
			INNER JOIN articulos AS a ON vt.articulo = a.articulo
		WHERE
			vc.anulada = 0 AND
			vc.fecha BETWEEN @fechaDesde AND @fechaHasta AND
			a.articulo = @articulo
		GROUP BY
			s.denominacion
		ORDER BY
			s.denominacion ASC
		--
		PRINT'EL PROCEDIMIENTO SE EJECUTO SIN ERRORES'
		--
FIN:
END TRY
BEGIN CATCH
	PRINT 'EL PROCEDIMIENTO FINALIZO CON ERRORES, VERIFICAR CON EL ADMINISTRADOR'
	PRINT 'ERROR: ' + CONVERT(nvarchar(50), ERROR_MESSAGE())
END CATCH

EXEC sp_cantidad_vendida_minorista 'A206221002', '10/01/2004', '12/01/2006';


/*

Una vez resuelto lo anterior, deberá modificar el procedimiento para agregarle un nuevo parámetro donde se especifique el tipo
de venta a calcular, y que podrá tener dos valores: 1 - Minorista, 2 - Mayorista. En caso de ingresar otro valor que no sea 1 o 2
deberá detener la ejecución mostrando el mensaje  "El parámetro de tipo de venta debe ser 1 (Minorista) o 2 (Mayorista)!".

Deberá validar además si el artículo tuvo ventas, y en el caso contrario mostrar "El artículo [codigo] no registra ventas 
[minoristas o mayoristas] en el periodo especificado!"

*/

--validacion de fecha
--validacion de articulo
--validacion de categoria
--validacion de si existen compras (dentro de las categorias)
 
CREATE OR ALTER PROCEDURE sp_cantidad_vendida_minorista_mayorista
@articulo CHAR(50),
@fechaDesde SMALLDATETIME,
@fechaHasta SMALLDATETIME,
@tipo int
AS
BEGIN TRY
		IF @fechaDesde > @fechaHasta --VALIDACIONES DE FECHAS
			BEGIN
				PRINT'EL RANGO DE FECHA ESTA MAL, POR FAVOR INGRESAR BIEN LAS FECHAS'
				GOTO FIN
			END
		--
		IF NOT EXISTS(SELECT * FROM articulos WHERE articulo = @articulo)
			BEGIN
				PRINT'EL ARTICULO QUE QUIERE INGRESAR NO EXISTE DENTRO DE LA BASE DE DATOS: ' + STR(@articulo)
				GOTO FIN
			END
		--
		IF @tipo NOT IN(1,2)
			BEGIN
				PRINT'El parámetro de tipo de venta debe ser 1 (Minorista) o 2 (Mayorista)!'
				GOTO FIN
			END
		ELSE
			BEGIN
				IF @tipo = 1
					BEGIN
						IF EXISTS( SELECT articulo FROM vencab AS vc INNER JOIN vendet AS vt ON(vc.factura = vt.factura AND vc.letra = vt.letra) 
									WHERE vc.anulada = 0 AND vc.fecha BETWEEN @fechaDesde AND @fechaHasta AND vt.articulo = @articulo)
							--si existe
							BEGIN
								SELECT
									s.denominacion AS 'NOMBRE DE SUCURSAL',
									SUM(vc.total) AS 'CANTIDAD VENDIDAD'
								FROM
									sucursales AS s 
									INNER JOIN vencab AS vc ON s.sucursal = vc.sucursal
									INNER JOIN vendet AS vt ON (vt.letra = vc.letra AND vt.factura = vc.factura)
									INNER JOIN articulos AS a ON vt.articulo = a.articulo
								WHERE
									vc.anulada = 0 AND
									vc.fecha BETWEEN @fechaDesde AND @fechaHasta AND
									a.articulo = @articulo
								GROUP BY
									s.denominacion
								ORDER BY
									s.denominacion ASC
								--
								PRINT'EL ARTICULO CONSULTADO, SI TUVO VENTAS'
							END
						ELSE
							PRINT'EL ARTICULO CONSULTADO NO TUVO VENTAS: ' + trim(@articulo)
					END
				ELSE
					IF @tipo = 2
						BEGIN
							IF EXISTS( SELECT articulo FROM mayorcab AS mc INNER JOIN mayordet AS mt ON(mc.factura = mt.factura AND mc.letra = mt.letra) 
										WHERE mc.anulada = 0 AND mc.fecha BETWEEN @fechaDesde AND @fechaHasta AND mt.articulo = @articulo)
							--si existen ventas
								BEGIN
									SELECT
										s.denominacion AS 'NOMBRE DE SUCURSAL',
										SUM(vc.total) AS 'CANTIDAD VENDIDAD'
									FROM
										sucursales AS s 
										INNER JOIN mayorcab AS vc ON s.sucursal = vc.sucursal
										INNER JOIN mayordet AS vt ON (vt.letra = vc.letra AND vt.factura = vc.factura)
										INNER JOIN articulos AS a ON vt.articulo = a.articulo
									WHERE
										vc.anulada = 0 AND
										vc.fecha BETWEEN @fechaDesde AND @fechaHasta AND
										a.articulo = @articulo
									GROUP BY
										s.denominacion
									ORDER BY
										s.denominacion ASC
									--
									PRINT'EL ARTICULO CONSULTADO, SI TUVO VENTAS'
									--
								END
							ELSE
								PRINT'EL ARTICULO CONSULTADO NO TUVO VENTAS: ' + trim(@articulo)
						END
				END
FIN:
END TRY
BEGIN CATCH
	PRINT 'EL PROCEDIMIENTO FINALIZO CON ERRORES, VERIFICAR CON EL ADMINISTRADOR'
	PRINT 'ERROR: ' + CONVERT(nvarchar(50), ERROR_MESSAGE())
END CATCH

EXEC sp_cantidad_vendida_minorista_mayorista 'B107198001','10/01/2004','12/01/2004', 2
