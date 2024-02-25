/*

EJERCICIO DE APLICACIÓN

Desarrolle el SP "sp_ventasanuales", que genera la tabla "tmp_ventasanuales" que contiene el total de ventas minoristas por
artículo. La tabla debe tener las columnas ARTICULO, CANTIDAD, IMPORTE. Tenga en cuenta los siguientes puntos:

	- Se deben excluir ventas anuladas.
	- Se debe tomar para el cálculo del importe CANTIDAD * PRECIO de la tabla VENDET.
	- El procedimiento debe recibir como parámetro de entrada el AÑO, y generar la tabla con las ventas de ese año solamente.
	- Se debe evaluar la existencia de la tabla. Si no existe usar SELECT..INTO, y si existe usar TRUNCATE con INSERT..SELECT.
	- Realizar control de errores, mostrando el mensaje "La tabla fue generada con éxito, se insertaron [n] filas." en caso de
	  éxito, o en caso contrario "Se produjo un error durante la inserción. Contacte con el administrador".

TIP: para evaluar si la tabla existe o no, utilice la función OBJECT_ID([nombre_objeto]), que retorna NULL si un objeto no
existe, o un número entero que identifica al objeto en caso contrario. Ver el ejemplo debajo.

--control de errores
--verificacion de tabla

*/

CREATE OR ALTER PROCEDURE sp_anuales_ventas
@año int
AS
DECLARE @filas int
BEGIN TRY
	BEGIN
		IF OBJECT_ID('temp_ventas_anuales') IS NOT NULL
			BEGIN
				TRUNCATE TABLE temp_ventas_anuales -- se trunca la tabla
				--se insertan datos
				INSERT temp_ventas_anuales
				SELECT
					a.articulo AS 'ARTICULOS',
					vt.cantidad AS 'CANTIDAD',
					SUM(vt.cantidad * vt.precio) AS 'IMPORTE'
				FROM
					articulos AS a 
					INNER JOIN vendet AS vt ON a.articulo = vt.articulo
					INNER JOIN  vencab AS vc ON (vc.factura = vt.factura AND vt.letra = vc.letra)
				WHERE
				 vc.anulada = 0 AND
				 YEAR(vc.fecha) = @año
				 GROUP BY
					a.articulo,vt.cantidad
				ORDER BY
					a.articulo
				--
				SET @filas = @@ROWCOUNT
			END
		ELSE
			BEGIN
				SELECT
					a.articulo AS 'ARTICULOS',
					vt.cantidad AS 'CANTIDAD',
					SUM(vt.cantidad * vt.precio) AS 'IMPORTE'
				INTO
					temp_ventas_anuales
				FROM
					articulos AS a 
					INNER JOIN vendet AS vt ON a.articulo = vt.articulo
					INNER JOIN  vencab AS vc ON (vc.factura = vt.factura AND vt.letra = vc.letra)
				WHERE
					vc.anulada = 0 AND
					YEAR(vc.fecha) = @año
					GROUP BY
					a.articulo,vt.cantidad
				ORDER BY
					a.articulo
					--
					SET @filas = @@ROWCOUNT
					
			END
		END
		--control en la insercion de filas
			IF @FILAS > 0
		PRINT' SE INSERTARON:' + TRIM(STR(@FILAS)) + ' FILAS'
	ELSE
		PRINT' NO HUBO INSERCION DE FILAS'
END TRY
BEGIN CATCH
	BEGIN
		PRINT'EL PROCESO FINALIZO CON ERRORES'
		PRINT'ERROR:' + CONVERT(NVARCHAR(50), ERROR_MESSAGE())
	END
END CATCH

EXEC sp_anuales_ventas 2008
SELECT * FROM temp_ventas_anuales
	